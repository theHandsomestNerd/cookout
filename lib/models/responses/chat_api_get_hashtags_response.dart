

import 'package:cookowt/models/hash_tag.dart';

class ChatApiGetHashtagsResponse {
  final List<Hashtag> list;

  ChatApiGetHashtagsResponse({
    required this.list,
  });

  factory ChatApiGetHashtagsResponse.fromJson(List<dynamic> parsedJson) {
    List<Hashtag> list = <Hashtag>[];

    // if (kDebugMode) {
    //   print("get-posts-response $parsedJson");
    // }

    list = parsedJson.map((i) => Hashtag.fromJson(i)).toList();

    return ChatApiGetHashtagsResponse(list: list);
  }
}
