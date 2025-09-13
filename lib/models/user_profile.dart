import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String? displayName;
  final DateTime createdAt;
  final bool hasCompletedOnboarding;
  final bool localOnlyMode;

  UserProfile({
    required this.uid,
    this.displayName,
    required this.createdAt,
    this.hasCompletedOnboarding = false,
    this.localOnlyMode = false,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      hasCompletedOnboarding: data['hasCompletedOnboarding'] ?? false,
      localOnlyMode: data['localOnlyMode'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'createdAt': Timestamp.fromDate(createdAt),
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'localOnlyMode': localOnlyMode,
    };
  }

  UserProfile copyWith({
    String? displayName,
    bool? hasCompletedOnboarding,
    bool? localOnlyMode,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt,
      hasCompletedOnboarding: hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      localOnlyMode: localOnlyMode ?? this.localOnlyMode,
    );
  }
}
