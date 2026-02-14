import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/exif_data.dart';
import '../../domain/entities/image_evidence.dart';
import '../../domain/repositories/exif_repository.dart';
import '../providers/exif_tools_providers.dart';

/// EXIF Tools State
class ExifToolsState {
  final bool isLoading;
  final ExifData? currentExif;
  final ImageEvidence? currentEvidence;
  final File? selectedImage;
  final File? modifiedImage;
  final String? errorMessage;
  final String? successMessage;
  
  const ExifToolsState({
    this.isLoading = false,
    this.currentExif,
    this.currentEvidence,
    this.selectedImage,
    this.modifiedImage,
    this.errorMessage,
    this.successMessage,
  });
  
  ExifToolsState copyWith({
    bool? isLoading,
    ExifData? currentExif,
    ImageEvidence? currentEvidence,
    File? selectedImage,
    File? modifiedImage,
    String? errorMessage,
    String? successMessage,
  }) {
    return ExifToolsState(
      isLoading: isLoading ?? this.isLoading,
      currentExif: currentExif ?? this.currentExif,
      currentEvidence: currentEvidence ?? this.currentEvidence,
      selectedImage: selectedImage ?? this.selectedImage,
      modifiedImage: modifiedImage ?? this.modifiedImage,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
  
  ExifToolsState clearMessages() {
    return copyWith(
      errorMessage: null,
      successMessage: null,
    );
  }
}

/// EXIF Tools Controller
class ExifToolsController extends StateNotifier<ExifToolsState> {
  final ExifRepository _repository;
  
  ExifToolsController(this._repository) : super(const ExifToolsState());
  
  /// Set selected image
  void setSelectedImage(File image) {
    state = state.copyWith(selectedImage: image);
  }
  
  /// Analyze image and extract EXIF
  Future<void> analyzeImage(File imageFile) async {
    state = state.copyWith(isLoading: true).clearMessages();
    
    final result = await _repository.analyzeImage(imageFile);
    
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
      (exifData) {
        state = state.copyWith(
          isLoading: false,
          currentExif: exifData,
          selectedImage: imageFile,
          successMessage: 'EXIF data extracted successfully',
        );
      },
    );
  }
  
  /// Modify GPS coordinates
  Future<bool> modifyGPS({
    required double latitude,
    required double longitude,
    String? reason,
  }) async {
    if (state.selectedImage == null) {
      state = state.copyWith(
        errorMessage: 'No image selected',
      );
      return false;
    }
    
    state = state.copyWith(isLoading: true).clearMessages();
    
    final result = await _repository.modifyGPS(
      imageFile: state.selectedImage!,
      latitude: latitude,
      longitude: longitude,
      reason: reason,
    );
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (modifiedFile) {
        state = state.copyWith(
          isLoading: false,
          modifiedImage: modifiedFile,
          successMessage: 'GPS coordinates modified successfully',
        );
        return true;
      },
    );
  }
  
  /// Modify camera information
  Future<bool> modifyCameraInfo({
    String? make,
    String? model,
    String? reason,
  }) async {
    if (state.selectedImage == null) {
      state = state.copyWith(
        errorMessage: 'No image selected',
      );
      return false;
    }
    
    state = state.copyWith(isLoading: true).clearMessages();
    
    final result = await _repository.modifyCameraInfo(
      imageFile: state.selectedImage!,
      make: make,
      model: model,
      reason: reason,
    );
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (modifiedFile) {
        state = state.copyWith(
          isLoading: false,
          modifiedImage: modifiedFile,
          successMessage: 'Camera information modified successfully',
        );
        return true;
      },
    );
  }
  
  /// Modify timestamp
  Future<bool> modifyTimestamp({
    required DateTime newDateTime,
    String? reason,
  }) async {
    if (state.selectedImage == null) {
      state = state.copyWith(
        errorMessage: 'No image selected',
      );
      return false;
    }
    
    state = state.copyWith(isLoading: true).clearMessages();
    
    final result = await _repository.modifyTimestamp(
      imageFile: state.selectedImage!,
      newDateTime: newDateTime,
      reason: reason,
    );
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (modifiedFile) {
        state = state.copyWith(
          isLoading: false,
          modifiedImage: modifiedFile,
          successMessage: 'Timestamp modified successfully',
        );
        return true;
      },
    );
  }
  
  /// Modify software tag
  Future<bool> modifySoftware({
    required String software,
    String? reason,
  }) async {
    if (state.selectedImage == null) {
      state = state.copyWith(
        errorMessage: 'No image selected',
      );
      return false;
    }
    
    state = state.copyWith(isLoading: true).clearMessages();
    
    final result = await _repository.modifySoftware(
      imageFile: state.selectedImage!,
      software: software,
      reason: reason,
    );
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (modifiedFile) {
        state = state.copyWith(
          isLoading: false,
          modifiedImage: modifiedFile,
          successMessage: 'Software tag modified successfully',
        );
        return true;
      },
    );
  }
  
  /// Generate EXIF from template
  Future<bool> generateExif(String templateType) async {
    if (state.selectedImage == null) {
      state = state.copyWith(
        errorMessage: 'No image selected',
      );
      return false;
    }
    
    state = state.copyWith(isLoading: true).clearMessages();
    
    final result = await _repository.generateExif(
      imageFile: state.selectedImage!,
      templateType: templateType,
    );
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (modifiedFile) {
        state = state.copyWith(
          isLoading: false,
          modifiedImage: modifiedFile,
          successMessage: 'EXIF generated successfully',
        );
        return true;
      },
    );
  }
  
  /// Create evidence record
  Future<bool> createEvidence({
    String? caseId,
    String? description,
    List<String>? tags,
  }) async {
    if (state.selectedImage == null) {
      state = state.copyWith(
        errorMessage: 'No image selected',
      );
      return false;
    }
    
    state = state.copyWith(isLoading: true).clearMessages();
    
    final result = await _repository.createEvidence(
      imageFile: state.selectedImage!,
      caseId: caseId,
      description: description,
      tags: tags,
    );
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return false;
      },
      (evidence) {
        state = state.copyWith(
          isLoading: false,
          currentEvidence: evidence,
          successMessage: 'Evidence created successfully',
        );
        return true;
      },
    );
  }
  
  /// Export evidence as PDF
  Future<File?> exportEvidencePdf() async {
    if (state.currentEvidence == null) {
      state = state.copyWith(
        errorMessage: 'No evidence to export',
      );
      return null;
    }
    
    state = state.copyWith(isLoading: true).clearMessages();
    
    final result = await _repository.exportEvidencePdf(state.currentEvidence!);
    
    return result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        return null;
      },
      (pdfFile) {
        state = state.copyWith(
          isLoading: false,
          successMessage: 'PDF report generated successfully',
        );
        return pdfFile;
      },
    );
  }
  
  /// Clear current state
  void clearState() {
    state = const ExifToolsState();
  }
  
  /// Clear messages
  void clearMessages() {
    state = state.clearMessages();
  }
}

/// EXIF Tools Controller Provider
final exifToolsControllerProvider = StateNotifierProvider<ExifToolsController, ExifToolsState>((ref) {
  final repository = ref.watch(exifRepositoryProvider);
  return ExifToolsController(repository);
});
