import 'package:cookowt/models/like.dart';
import 'package:cookowt/models/spreadsheet_member_verification.dart';

class ChatApiGetVerificationsResponse {
  final List<SpreadsheetMemberVerification> list;
  final SpreadsheetMemberVerification? amIInThisList;

  ChatApiGetVerificationsResponse({required this.list, this.amIInThisList,});

  factory ChatApiGetVerificationsResponse.fromJson(Map<String, dynamic> json) {
    getListOfVerifications(List<dynamic> parsedJson) {
      return parsedJson.map((i) => SpreadsheetMemberVerification.fromJson(i)).toList();
    }

    List<SpreadsheetMemberVerification> theList = <SpreadsheetMemberVerification>[];
    SpreadsheetMemberVerification? amIInThisList;

    // if (kDebugMode) {
    //   print("get-likes-response $json");
    // }
    theList = getListOfVerifications(json['verifications']);

    if (json['amIInThisList'] != null && json['amIInThisList'] != "null") {
      amIInThisList = SpreadsheetMemberVerification.fromJson(json['amIInThisList']);
    }

    return ChatApiGetVerificationsResponse(
        list: theList, amIInThisList: amIInThisList);
  }
}
