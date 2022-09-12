class OrganModel {
  final String organId;
  final String organName;
  final bool isNoReserve;
  final String? organAddress;
  final String? organPhone;
  final String? organComment;
  final String? organImage;
  final String? organZipCode;
  final String? distance;
  final String? snsurl;
  final int checkTicketConsumtion;

  const OrganModel(
      {required this.organId,
      required this.organName,
      required this.isNoReserve,
      this.organAddress,
      this.organPhone,
      this.organComment,
      this.organImage,
      this.organZipCode,
      this.distance,
      this.snsurl,
      required this.checkTicketConsumtion});

  factory OrganModel.fromJson(Map<String, dynamic> json) {
    return OrganModel(
        organId: json['organ_id'],
        organName: json['organ_name'],
        isNoReserve: json['is_no_reserve'] == null
            ? false
            : json['is_no_reserve'].toString() == '1',
        organAddress: json['address'] == null ? '' : json['address'],
        organPhone: json['phone'],
        organComment: json['comment'] ?? '',
        organImage: json['image'],
        organZipCode: json['zip_code'],
        snsurl: json['sns_url'],
        distance: json['distance'].toString(),
        checkTicketConsumtion: (json['checkin_ticket_consumption'] == null ||
                json['checkin_ticket_consumption'] == '')
            ? 0
            : int.parse(json['checkin_ticket_consumption']));
  }
}
