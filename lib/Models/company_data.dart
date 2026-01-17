class Company {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? address;
  String? city;
  String? town;
  String? postalCode;
  String? logo;
  DateTime? subscriptionEndDate;
  dynamic latitude;
  dynamic longitude;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? logoUrl;
  String? subscriptionStatus;
  int? daysRemaining;

  Company({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.town,
    this.postalCode,
    this.logo,
    this.subscriptionEndDate,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
    this.logoUrl,
    this.subscriptionStatus,
    this.daysRemaining,
  });

  // ---------------- FROM JSON ----------------
  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as int?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      town: json['town'] as String?,
      postalCode: json['postalCode'] as String?,
      logo: json['logo'] as String?,
      subscriptionEndDate: json['subscriptionEndDate'] != null
          ? DateTime.parse(json['subscriptionEndDate'])
          : null,
      latitude: json['latitude'],
      longitude: json['longitude'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      logoUrl: json['logoUrl'] as String?,
      subscriptionStatus: json['subscriptionStatus'] as String?,
      daysRemaining: json['daysRemaining'] as int?,
    );
  }

  // ---------------- TO JSON ----------------
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'town': town,
      'postalCode': postalCode,
      'logo': logo,
      'subscriptionEndDate': subscriptionEndDate?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'logoUrl': logoUrl,
      'subscriptionStatus': subscriptionStatus,
      'daysRemaining': daysRemaining,
    };
  }
}
