import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String role;
  final Timestamp createdAt;
  final Timestamp? lastLogin;
  final String status;

  AppUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.createdAt,
    this.lastLogin,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
      'status': status,
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'],
      email: map['email'],
      role: map['role'],
      createdAt: map['createdAt'],
      lastLogin: map['lastLogin'],
      status: map['status'],
    );
  }
}
