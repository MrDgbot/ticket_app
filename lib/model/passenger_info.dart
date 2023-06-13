enum IDType {
  identityCard, // 身份证
  passport, // 护照
}

class PassengerInfo {
  String firstName;
  String lastName;
  String phoneRegionCode;
  String phoneNumber;
  IDType idType;
  String idNumber;
  double additionalFee;
  String base64Image;

  PassengerInfo({
    required this.firstName,
    required this.lastName,
    required this.phoneRegionCode,
    required this.phoneNumber,
    required this.idType,
    required this.idNumber,
    required this.base64Image,
    this.additionalFee = 0.0,
  });

  /// 获取姓名
  String get name => firstName + lastName;

  factory PassengerInfo.fromJson(Map<String, dynamic> json) {
    return PassengerInfo(
      firstName: json['first_name'],
      lastName: json['last_name'],
      phoneRegionCode: json['phone_region_code'],
      phoneNumber: json['phone_number'],
      idType: IDType.values[json['id_type']],
      idNumber: json['id_number'],
      additionalFee: json['additional_fee'],
      base64Image: json['base64_image'],
    );
  }

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'phone_region_code': phoneRegionCode,
        'phone_number': phoneNumber,
        'id_type': idType.index,
        'id_number': idNumber,
        'additional_fee': additionalFee,
        'base64_image': base64Image,
      };
}
