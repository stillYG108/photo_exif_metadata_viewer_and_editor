import 'package:cloud_firestore/cloud_firestore.dart';

class ForensicService {
  final String id;
  final String name;
  final String description;
  final bool enabled;
  final Timestamp createdAt;

  ForensicService({
    required this.id,
    required this.name,
    required this.description,
    required this.enabled,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'enabled': enabled,
      'createdAt': createdAt,
    };
  }

  factory ForensicService.fromMap(String id, Map<String, dynamic> map) {
    return ForensicService(
      id: id,
      name: map['name'],
      description: map['description'],
      enabled: map['enabled'],
      createdAt: map['createdAt'],
    );
  }
}
