import 'package:cookowt/models/hash_tag.dart';
import 'package:cookowt/models/spreadsheet_member.dart';

import 'hash_tag.dart';

import 'hash_tag.dart';

class ChapterRoster {
  List<SpreadsheetMember> theMembers = <SpreadsheetMember>[];

  ChapterRoster.fromJson(List<dynamic> parsedJson) {
    List<SpreadsheetMember> list = <SpreadsheetMember>[];

    list = parsedJson.map((i) => SpreadsheetMember.fromJson(i)).toList();
    theMembers = list;
  }

  List<dynamic> toJson() {
    // final Map<String, dynamic> data = <String, dynamic>{};
    return theMembers;
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
