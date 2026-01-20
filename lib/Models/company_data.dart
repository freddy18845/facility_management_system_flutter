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
  num? daysRemaining;

  // New Fields added here
  String? senderId;
  int? smsCount;

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
    this.senderId,
    this.smsCount,
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
      // Note: mapping snake_case from Laravel to camelCase for Flutter
      postalCode: json['postal_code'] as String?,
      logo: json['logo'] as String?,
      subscriptionEndDate: json['subscription_end_date'] != null
          ? DateTime.parse(json['subscription_end_date'].toString())
          : null,
      latitude: json['latitude'],
      longitude: json['longitude'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
      logoUrl: json['logo_url'] as String?,
      subscriptionStatus: json['subscription_status'] as String?,
      daysRemaining: json['days_remaining'] as num?,

      // New mappings
      senderId: json['sender_id'] as String?,
      smsCount: json['sms_count'] as int?,
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
      'postal_code': postalCode,
      'logo': logo,
      'subscription_end_date': subscriptionEndDate?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'logo_url': logoUrl,
      'subscription_status': subscriptionStatus,
      'days_remaining': daysRemaining,

      // New mappings
      'sender_id': senderId,
      'sms_count': smsCount,
    };
  }
}