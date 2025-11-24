class UserModel {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? profileImageUrl;
  final bool isAdmin;
  final DateTime createdAt;
  final String? vehicleId; // ID of the vehicle assigned to this user

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.profileImageUrl,
    this.isAdmin = false,
    required this.createdAt,
    this.vehicleId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'profileImageUrl': profileImageUrl,
      'isAdmin': isAdmin,
      'createdAt': createdAt.toIso8601String(),
      'vehicleId': vehicleId,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'],
      profileImageUrl: map['profileImageUrl'],
      isAdmin: map['isAdmin'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      vehicleId: map['vehicleId'],
    );
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? profileImageUrl,
    bool? isAdmin,
    DateTime? createdAt,
    String? vehicleId,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isAdmin: isAdmin ?? this.isAdmin,
      createdAt: createdAt ?? this.createdAt,
      vehicleId: vehicleId ?? this.vehicleId,
    );
  }
}

