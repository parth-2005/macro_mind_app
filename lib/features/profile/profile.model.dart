class ProfileModel {
  final String? id;
  final String name;
  final String phoneNumber;
  final String email;
  final List<String> preferences;
  final String location;

  ProfileModel({
    this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.preferences,
    required this.location,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['_id'] ?? json['id'],
      name: json['name'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      email: json['email'] ?? '',
      preferences: json['preferences'] != null
          ? List<String>.from(json['preferences'])
          : [],
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'preferences': preferences,
      'location': location,
    };
  }

  ProfileModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    List<String>? preferences,
    String? location,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      preferences: preferences ?? this.preferences,
      location: location ?? this.location,
    );
  }
}
