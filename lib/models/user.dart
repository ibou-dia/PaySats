enum UserStatus {
  active,
  inactive,
  suspended
}

class User {
  final String id;
  final String phoneNumber;
  final String? firstName;
  final String? lastName;
  final String? email;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final UserStatus status;
  final String? profileImageUrl;
  final String? countryCode;
  final bool isPhoneVerified;
  final bool hasOptionalKYC;
  final Map<String, dynamic>? kycData;

  const User({
    required this.id,
    required this.phoneNumber,
    this.firstName,
    this.lastName,
    this.email,
    required this.createdAt,
    this.lastLoginAt,
    this.status = UserStatus.active,
    this.profileImageUrl,
    this.countryCode,
    this.isPhoneVerified = false,
    this.hasOptionalKYC = false,
    this.kycData,
  });

  // Create a copy of the user with updated properties
  User copyWith({
    String? id,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? email,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    UserStatus? status,
    String? profileImageUrl,
    String? countryCode,
    bool? isPhoneVerified,
    bool? hasOptionalKYC,
    Map<String, dynamic>? kycData,
  }) {
    return User(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      status: status ?? this.status,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      countryCode: countryCode ?? this.countryCode,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      hasOptionalKYC: hasOptionalKYC ?? this.hasOptionalKYC,
      kycData: kycData ?? this.kycData,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'status': status.name,
      'profileImageUrl': profileImageUrl,
      'countryCode': countryCode,
      'isPhoneVerified': isPhoneVerified,
      'hasOptionalKYC': hasOptionalKYC,
      'kycData': kycData,
    };
  }

  // Create from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      phoneNumber: json['phoneNumber'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      createdAt: DateTime.parse(json['createdAt']),
      lastLoginAt: json['lastLoginAt'] != null 
          ? DateTime.parse(json['lastLoginAt']) 
          : null,
      status: UserStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => UserStatus.active,
      ),
      profileImageUrl: json['profileImageUrl'],
      countryCode: json['countryCode'],
      isPhoneVerified: json['isPhoneVerified'] ?? false,
      hasOptionalKYC: json['hasOptionalKYC'] ?? false,
      kycData: json['kycData'],
    );
  }

  // Get full name
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    }
    return phoneNumber;
  }

  // Get display name for UI
  String get displayName {
    return fullName.isNotEmpty ? fullName : phoneNumber;
  }
}