class UserModel {
  final String? id;
  final String email;
  final String? displayName;
  final String role;
  final DateTime createdAt;
  final DateTime? lastLogin;
  final bool isActive;

  UserModel({
    this.id,
    required this.email,
    this.displayName,
    required this.role,
    DateTime? createdAt,
    this.lastLogin,
    this.isActive = true,
  }) : this.createdAt = createdAt ?? DateTime.now();

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      email: map['email'],
      displayName: map['displayName'],
      role: map['role'],
      createdAt: map['createdAt']?.toDate(),
      lastLogin: map['lastLogin']?.toDate(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
      'isActive': isActive,
    };
  }
}
