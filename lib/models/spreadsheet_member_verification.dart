import 'package:cookowt/models/app_user.dart';
import 'package:cookowt/models/spreadsheet_member.dart';

class SpreadsheetMemberVerification {
  String? id;
  AppUser? userRef;
  SpreadsheetMember? spreadsheetMemberRef;
  bool? isApproved;

  SpreadsheetMemberVerification.fromJson(Map<String, dynamic> json) {
    if (json['_id'] != null && json['_id'] != "null") {
      id = json["_id"];
    }
    if (json['userRef'] != null && json['userRef'] != "null") {
      userRef = AppUser.fromJson(json["userRef"]);
    }
    if (json['spreadsheetMemberRef'] != null && json['spreadsheetMemberRef'] != "null") {
      spreadsheetMemberRef = SpreadsheetMember.fromJson(json["spreadsheetMemberRef"]);
    }
    if (json['isApproved'] != null) {
      isApproved = json["isApproved"];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userRef'] = userRef?.toJson();
    data['amIInThisList'] = spreadsheetMemberRef;
    data['_id'] = id;
    data['isApproved'] = isApproved;
    return data;
  }

// @override
// toString(){
//   return '\n______________Hashtag
//   :${id}______________\n'
//       '\nliker:${liker?.userId} '
//       '\nlikee:${likee?.userId} '
//       '\nlikeCategory:$likeCategory '
//       '\n-----------------------------\n';
// }
}
