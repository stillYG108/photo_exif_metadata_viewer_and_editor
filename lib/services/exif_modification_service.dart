import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Service for modifying EXIF data in images and saving locally.
///
/// Uses a pure-Dart JPEG EXIF injection approach — works on ALL platforms
/// (Android, iOS, Windows, macOS, Linux, Web) without native platform channels.
class ExifModificationService {
  // ─────────────────────────────────────────────────────────────────────────
  // Public API
  // ─────────────────────────────────────────────────────────────────────────

  /// Download image, embed modified EXIF metadata, and save to Downloads.
  Future<Map<String, dynamic>> modifyAndDownloadImage({
    required String imageUrl,
    required String originalFilename,
    required Map<String, String> modifiedMetadata,
  }) async {
    try {
      // Step 1: Download the raw JPEG bytes.
      print('Downloading image from: $imageUrl');
      final imageBytes = await _downloadImage(imageUrl);

      // Step 2: Inject / replace EXIF data directly in the JPEG byte stream.
      print('Injecting EXIF metadata into JPEG bytes...');
      final modifiedBytes = _injectExifIntoJpeg(imageBytes, modifiedMetadata);
      print('EXIF injection complete — output size: ${modifiedBytes.length} bytes');

      // Step 3: Save the modified bytes to the Downloads folder.
      print('Saving to downloads...');
      final result = await _saveToDownloads(
        modifiedBytes,
        originalFilename,
        modifiedMetadata,
      );

      return result;
    } catch (e, stackTrace) {
      print('Error in modifyAndDownloadImage: $e');
      print('Stack trace: $stackTrace');
      return {'success': false, 'error': e.toString()};
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // EXIF injection — pure Dart, cross-platform
  // ─────────────────────────────────────────────────────────────────────────

  /// Take a JPEG byte buffer, strip any existing APP1/EXIF segment, build a
  /// new one from [metadata], and splice it back in right after the SOI marker.
  ///
  /// The resulting file is a valid JPEG that any EXIF reader can parse.
  Uint8List _injectExifIntoJpeg(
      Uint8List jpegBytes, Map<String, String> metadata) {
    // Verify SOI marker (FFD8).
    if (jpegBytes.length < 4 ||
        jpegBytes[0] != 0xFF ||
        jpegBytes[1] != 0xD8) {
      print('Warning: not a JPEG — returning bytes unchanged');
      return jpegBytes;
    }

    // Strip ALL existing APP0 (FFE0) and APP1 (FFE1) segments so we start
    // with a clean slate.  We keep everything from the first non-APP segment
    // onwards (typically SOF0 / DQT / …).
    final strippedBody = _stripAppSegments(jpegBytes);

    // Build a fresh EXIF APP1 segment from the user-supplied metadata.
    final exifApp1 = _buildExifApp1(metadata);

    // Reassemble: SOI | [APP0 if needed] | APP1 | rest of body
    final out = BytesBuilder();
    out.addByte(0xFF);
    out.addByte(0xD8); // SOI
    out.add(exifApp1); // Our new EXIF block
    out.add(strippedBody); // Original image data (without old APP segments)
    return out.toBytes();
  }

  /// Remove APP0 (FFE0) and APP1 (FFE1) markers and their payload from a JPEG.
  /// Returns the bytes starting after all leading APP segments.
  Uint8List _stripAppSegments(Uint8List bytes) {
    int offset = 2; // Skip SOI (FF D8)
    while (offset + 3 < bytes.length) {
      final marker = bytes[offset];
      final type = bytes[offset + 1];

      if (marker != 0xFF) break; // Lost sync — stop stripping

      // Skip APP0 (E0) and APP1 (E1); keep everything else.
      if (type == 0xE0 || type == 0xE1) {
        // Segment length is big-endian uint16 at offset+2, includes the 2 length bytes.
        final segLen = (bytes[offset + 2] << 8) | bytes[offset + 3];
        offset += 2 + segLen; // Jump over the whole segment
      } else {
        break; // First non-APP segment — rest is image data
      }
    }
    return bytes.sublist(offset);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // EXIF APP1 builder
  // Build a minimal but spec-correct EXIF structure:
  //
  //   FF E1             — APP1 marker
  //   LL LL             — segment length (big-endian, includes these 2 bytes)
  //   45 78 69 66 00 00 — "Exif\0\0" header
  //   <TIFF IFD0>       — little-endian TIFF data
  // ─────────────────────────────────────────────────────────────────────────

  Uint8List _buildExifApp1(Map<String, String> metadata) {
    // Build the TIFF/EXIF IFD data (little-endian).
    final tiffData = _buildTiffData(metadata);

    // APP1 payload = "Exif\0\0" (6 bytes) + TIFF data
    final exifHeader = Uint8List.fromList([0x45, 0x78, 0x69, 0x66, 0x00, 0x00]);
    final payload = Uint8List(exifHeader.length + tiffData.length);
    payload.setRange(0, exifHeader.length, exifHeader);
    payload.setRange(exifHeader.length, payload.length, tiffData);

    // APP1 marker + big-endian length (length includes its own 2 bytes)
    final segLen = payload.length + 2; // +2 for the length field itself
    final out = BytesBuilder();
    out.addByte(0xFF);
    out.addByte(0xE1);
    out.addByte((segLen >> 8) & 0xFF);
    out.addByte(segLen & 0xFF);
    out.add(payload);
    return out.toBytes();
  }

  /// Build a little-endian TIFF structure with IFD0 containing standard EXIF tags.
  Uint8List _buildTiffData(Map<String, String> meta) {
    // We write everything into a ByteData builder (little-endian).
    // Layout:
    //   [0]  TIFF header (8 bytes)  — "II" + magic 42 + offset to IFD0
    //   [8]  IFD0 entries
    //   [?]  Sub-IFD (Exif IFD, GPS IFD) entries
    //   [?]  Value data area (strings, rationals, etc.)

    // Collect IFD0 tags we will write.
    final ifd0Tags = <_ExifTag>[];
    final exifSubTags = <_ExifTag>[];
    final gpsTags = <_ExifTag>[];

    // ── Helper to add an ASCII tag ─────────────────────────────────────────
    void addAscii(List<_ExifTag> target, int tagId, String? value) {
      if (value == null || value.isEmpty) return;
      final bytes = Uint8List.fromList([...value.codeUnits, 0]); // null-terminated
      target.add(_ExifTag(tagId, _TYPE_ASCII, bytes.length, bytes));
    }

    // ── Helper to add a SHORT (uint16) tag ────────────────────────────────
    void addShort(List<_ExifTag> target, int tagId, int value) {
      final data = Uint8List(2);
      data.buffer.asByteData().setUint16(0, value, Endian.little);
      target.add(_ExifTag(tagId, _TYPE_SHORT, 1, data));
    }

    // ── Helper to add a RATIONAL (two uint32) tag ─────────────────────────
    void addRational(List<_ExifTag> target, int tagId, int num, int den) {
      final data = Uint8List(8);
      final bd = data.buffer.asByteData();
      bd.setUint32(0, num, Endian.little);
      bd.setUint32(4, den, Endian.little);
      target.add(_ExifTag(tagId, _TYPE_RATIONAL, 1, data));
    }

    // ── Helper to add a GPS DMS coordinate (3 rationals) ──────────────────
    void addGpsDms(List<_ExifTag> target, int tagId, double decimal) {
      final abs = decimal.abs();
      final deg = abs.truncate();
      final minFrac = (abs - deg) * 60;
      final min = minFrac.truncate();
      final sec = ((minFrac - min) * 60);
      // Encode seconds with 100 denominator for two decimal places
      final secNum = (sec * 100).round();

      final data = Uint8List(24); // 3 × 8 bytes
      final bd = data.buffer.asByteData();
      bd.setUint32(0, deg, Endian.little);
      bd.setUint32(4, 1, Endian.little);
      bd.setUint32(8, min, Endian.little);
      bd.setUint32(12, 1, Endian.little);
      bd.setUint32(16, secNum, Endian.little);
      bd.setUint32(20, 100, Endian.little);
      target.add(_ExifTag(tagId, _TYPE_RATIONAL, 3, data));
    }

    // ── Populate IFD0 tags from metadata map ──────────────────────────────
    //
    // We accept keys in TWO formats:
    //   a) The `exif` package convention: "Image Make", "EXIF FNumber", etc.
    //   b) Plain lowercase: "make", "model", "software", etc.
    //
    // This makes the service robust regardless of how the UI passes keys.

    String? _v(String exifKey, [String? shortKey]) {
      return meta[exifKey] ??
          meta[shortKey ?? ''] ??
          meta[exifKey.toLowerCase()] ??
          meta[exifKey.split(' ').last] ?? // e.g. "Make" from "Image Make"
          null;
    }

    addAscii(ifd0Tags, 0x010F, _v('Image Make', 'make'));      // Make
    addAscii(ifd0Tags, 0x0110, _v('Image Model', 'model'));    // Model
    addAscii(ifd0Tags, 0x0131, _v('Image Software', 'software')); // Software

    // DateTime in IFD0
    final dtRaw = _v('Image DateTime', 'datetime') ??
        _v('EXIF DateTimeOriginal', 'date');
    if (dtRaw != null && dtRaw.isNotEmpty) {
      addAscii(ifd0Tags, 0x0132, dtRaw); // DateTime (IFD0)
    }

    // Orientation
    final oriStr = _v('Image Orientation', 'orientation');
    if (oriStr != null) {
      final ori = int.tryParse(oriStr);
      if (ori != null) addShort(ifd0Tags, 0x0112, ori);
    }

    // ── Exif SubIFD tags ───────────────────────────────────────────────────
    final dtOriginal = _v('EXIF DateTimeOriginal') ?? dtRaw;
    if (dtOriginal != null && dtOriginal.isNotEmpty) {
      addAscii(exifSubTags, 0x9003, dtOriginal); // DateTimeOriginal
    }

    final isoStr = _v('EXIF ISOSpeedRatings', 'iso');
    if (isoStr != null) {
      final iso = int.tryParse(isoStr);
      if (iso != null) addShort(exifSubTags, 0x8827, iso);
    }

    final focalStr = _v('EXIF FocalLength', 'focal_length');
    if (focalStr != null) {
      final focal = double.tryParse(focalStr);
      if (focal != null) {
        addRational(exifSubTags, 0x920A, (focal * 100).round(), 100);
      }
    }

    // ── GPS SubIFD tags ────────────────────────────────────────────────────
    final latStr = _v('GPS GPSLatitude', 'latitude');
    final lonStr = _v('GPS GPSLongitude', 'longitude');
    final latRefStr = _v('GPS GPSLatitudeRef', 'lat_ref');
    final lonRefStr = _v('GPS GPSLongitudeRef', 'lon_ref');
    final altStr = _v('GPS GPSAltitude', 'altitude');

    bool hasGps = false;

    if (latStr != null && lonStr != null) {
      final lat = double.tryParse(latStr);
      final lon = double.tryParse(lonStr);
      if (lat != null && lon != null) {
        hasGps = true;
        // GPSVersionID
        gpsTags.add(_ExifTag(0x0000, _TYPE_BYTE, 4,
            Uint8List.fromList([2, 3, 0, 0])));
        // LatitudeRef
        final latRef = latRefStr ??
            (lat >= 0 ? 'N' : 'S');
        addAscii(gpsTags, 0x0001, '$latRef\x00'); // GPSLatitudeRef
        addGpsDms(gpsTags, 0x0002, lat);          // GPSLatitude
        // LongitudeRef
        final lonRef = lonRefStr ??
            (lon >= 0 ? 'E' : 'W');
        addAscii(gpsTags, 0x0003, '$lonRef\x00'); // GPSLongitudeRef
        addGpsDms(gpsTags, 0x0004, lon);          // GPSLongitude
      }
    }

    if (altStr != null) {
      final alt = double.tryParse(altStr);
      if (alt != null) {
        if (!hasGps) {
          // Need GPSVersionID even if only altitude is set
          gpsTags.add(_ExifTag(0x0000, _TYPE_BYTE, 4,
              Uint8List.fromList([2, 3, 0, 0])));
          hasGps = true;
        }
        addShort(gpsTags, 0x0005, alt >= 0 ? 0 : 1); // GPSAltitudeRef
        addRational(gpsTags, 0x0006, (alt.abs() * 100).round(), 100); // GPSAltitude
      }
    }

    // ── Sort all tag lists by tag ID (TIFF spec requirement) ──────────────
    ifd0Tags.sort((a, b) => a.tagId.compareTo(b.tagId));
    exifSubTags.sort((a, b) => a.tagId.compareTo(b.tagId));
    gpsTags.sort((a, b) => a.tagId.compareTo(b.tagId));

    // ── Layout calculation ─────────────────────────────────────────────────
    //
    //  TIFF header  :  8 bytes  (II, 42, offset-to-IFD0)
    //  IFD0 entries : (2 + n*12 + 4) bytes  [entry count + entries + next-IFD ptr]
    //  ExifIFD      : same structure
    //  GPSІFD       : same structure
    //  Value area   : variable (strings, 3-rational GPS, etc.)
    //
    //  We build a flat byte buffer and patch offsets after we know sizes.

    const tiffHeaderSize = 8;

    int ifd0Size = 2 + ifd0Tags.length * 12 + 4;
    // Add placeholder tags for sub-IFD pointers if needed
    bool needExifIfd = exifSubTags.isNotEmpty;
    bool needGpsIfd = gpsTags.isNotEmpty;
    if (needExifIfd) ifd0Size += 12; // ExifIFD pointer tag
    if (needGpsIfd) ifd0Size += 12; // GPSIFD pointer tag

    int exifIfdSize =
        needExifIfd ? (2 + exifSubTags.length * 12 + 4) : 0;
    int gpsIfdSize =
        needGpsIfd ? (2 + gpsTags.length * 12 + 4) : 0;

    // Offsets from the start of the TIFF header (byte 0 = 'I')
    const ifd0Offset = tiffHeaderSize; // 8
    final exifIfdOffset = ifd0Offset + ifd0Size;
    final gpsIfdOffset = exifIfdOffset + exifIfdSize;
    final valueAreaOffset = gpsIfdOffset + gpsIfdSize;

    // ── Allocate value area ────────────────────────────────────────────────
    // Values > 4 bytes go into the value area; ≤4 bytes are stored inline.
    // We pre-compute the total value area size.
    int valueAreaSize = 0;

    void _measure(_ExifTag tag) {
      if (tag.valueBytes.length > 4) valueAreaSize += tag.valueBytes.length;
    }

    for (final t in ifd0Tags) {
      _measure(t);
    }
    if (needExifIfd) {
      for (final t in exifSubTags) {
        _measure(t);
      }
    }
    if (needGpsIfd) {
      for (final t in gpsTags) {
        _measure(t);
      }
    }
    // Sub-IFD pointers themselves are 4-byte LONG inline — no extra value area.

    final totalSize = tiffHeaderSize +
        ifd0Size +
        exifIfdSize +
        gpsIfdSize +
        valueAreaSize;

    final buf = Uint8List(totalSize);
    final bd = buf.buffer.asByteData();
    int valPtr = valueAreaOffset; // Running pointer into value area

    // ── Write TIFF header (little-endian) ─────────────────────────────────
    buf[0] = 0x49; // 'I'
    buf[1] = 0x49; // 'I'  → little-endian
    bd.setUint16(2, 42, Endian.little); // TIFF magic
    bd.setUint32(4, ifd0Offset, Endian.little); // Offset to IFD0

    // ── Helper: write one IFD entry ────────────────────────────────────────
    int writeEntry(int pos, _ExifTag tag) {
      bd.setUint16(pos, tag.tagId, Endian.little);
      bd.setUint16(pos + 2, tag.type, Endian.little);
      bd.setUint32(pos + 4, tag.count, Endian.little);

      if (tag.valueBytes.length <= 4) {
        // Value fits inline — left-justify in the 4-byte field
        for (int i = 0; i < tag.valueBytes.length; i++) {
          buf[pos + 8 + i] = tag.valueBytes[i];
        }
      } else {
        // Value goes into the value area — store offset
        bd.setUint32(pos + 8, valPtr, Endian.little);
        buf.setRange(valPtr, valPtr + tag.valueBytes.length, tag.valueBytes);
        valPtr += tag.valueBytes.length;
      }
      return pos + 12;
    }

    // ── Helper: write a full IFD ──────────────────────────────────────────
    int writeIfd(int pos, List<_ExifTag> tags, int nextIfdOffset) {
      bd.setUint16(pos, tags.length, Endian.little);
      pos += 2;
      for (final tag in tags) {
        pos = writeEntry(pos, tag);
      }
      bd.setUint32(pos, nextIfdOffset, Endian.little); // next IFD pointer (0 = none)
      return pos + 4;
    }

    // ── Build effective IFD0 tag list (with sub-IFD pointers inserted) ─────
    final effectiveIfd0 = <_ExifTag>[...ifd0Tags];
    if (needExifIfd) {
      // Tag 0x8769 = ExifIFD pointer (LONG, value is offset)
      final ptrData = Uint8List(4);
      ptrData.buffer.asByteData().setUint32(0, exifIfdOffset, Endian.little);
      effectiveIfd0.add(_ExifTag(0x8769, _TYPE_LONG, 1, ptrData));
    }
    if (needGpsIfd) {
      // Tag 0x8825 = GPSIFD pointer (LONG, value is offset)
      final ptrData = Uint8List(4);
      ptrData.buffer.asByteData().setUint32(0, gpsIfdOffset, Endian.little);
      effectiveIfd0.add(_ExifTag(0x8825, _TYPE_LONG, 1, ptrData));
    }
    effectiveIfd0.sort((a, b) => a.tagId.compareTo(b.tagId));

    // ── Write IFD0 ────────────────────────────────────────────────────────
    writeIfd(ifd0Offset, effectiveIfd0, 0 /* no thumbnail IFD */);

    // ── Write ExifIFD ─────────────────────────────────────────────────────
    if (needExifIfd) {
      writeIfd(exifIfdOffset, exifSubTags, 0);
    }

    // ── Write GPS IFD ─────────────────────────────────────────────────────
    if (needGpsIfd) {
      writeIfd(gpsIfdOffset, gpsTags, 0);
    }

    return buf;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TIFF type constants
  // ─────────────────────────────────────────────────────────────────────────
  static const int _TYPE_BYTE = 1;
  static const int _TYPE_ASCII = 2;
  static const int _TYPE_SHORT = 3;
  static const int _TYPE_LONG = 4;
  static const int _TYPE_RATIONAL = 5;

  // ─────────────────────────────────────────────────────────────────────────
  // Network & IO helpers
  // ─────────────────────────────────────────────────────────────────────────

  Future<Uint8List> _downloadImage(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) return response.bodyBytes;
    throw Exception('Failed to download image: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> _saveToDownloads(
    Uint8List imageBytes,
    String originalFilename,
    Map<String, String> metadata,
  ) async {
    try {
      print('=== SAVE TO DOWNLOADS DEBUG ===');
      print('Platform: ${Platform.operatingSystem}');
      print('Image size: ${imageBytes.length} bytes');

      // Request storage permission on Android
      if (Platform.isAndroid) {
        print('Requesting storage permissions...');
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          final manageStatus =
              await Permission.manageExternalStorage.request();
          if (!manageStatus.isGranted) {
            print('ERROR: Storage permission denied');
            return {'success': false, 'error': 'Storage permission denied'};
          }
        }
      }

      // Resolve the Downloads directory for each platform
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else if (Platform.isWindows) {
        final userProfile = Platform.environment['USERPROFILE'];
        downloadsDir = Directory('$userProfile\\Downloads');
      } else if (Platform.isIOS || Platform.isMacOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      } else {
        downloadsDir = await getDownloadsDirectory();
      }

      if (downloadsDir == null || !await downloadsDir.exists()) {
        // Fallback: use app temp dir
        downloadsDir = await getTemporaryDirectory();
        print('Using temp dir as fallback: ${downloadsDir.path}');
      }

      print('Downloads dir: ${downloadsDir.path}');

      // Build filename with _EXIF_MODIFIED suffix
      final nameWithoutExt =
          originalFilename.replaceAll(RegExp(r'\.[^.]+$'), '');
      final extension = originalFilename.split('.').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newFilename = '${nameWithoutExt}_EXIF_MODIFIED_$timestamp.$extension';

      final destinationPath = '${downloadsDir.path}${Platform.pathSeparator}$newFilename';
      print('Saving to: $destinationPath');

      final file = File(destinationPath);
      await file.writeAsBytes(imageBytes, flush: true);
      print('✓ Image saved with embedded EXIF data!');

      return {
        'success': true,
        'imagePath': destinationPath,
        'downloadFolder': downloadsDir.path,
        'modifiedFields': metadata.length,
      };
    } catch (e, stackTrace) {
      print('ERROR in _saveToDownloads: $e');
      print('Stack: $stackTrace');
      return {'success': false, 'error': e.toString()};
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal data model
// ─────────────────────────────────────────────────────────────────────────────

/// Represents one entry in a TIFF IFD.
class _ExifTag {
  final int tagId;
  final int type; // TIFF type constant
  final int count; // Number of values
  final Uint8List valueBytes; // Raw little-endian bytes

  const _ExifTag(this.tagId, this.type, this.count, this.valueBytes);
}
