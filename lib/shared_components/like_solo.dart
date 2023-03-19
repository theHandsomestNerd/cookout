import 'package:chat_line/shared_components/user_block_text.dart';
import 'package:flutter/material.dart';

import '../models/like.dart';
import 'package:timeago/timeago.dart' as timeago;

class LikeSolo extends StatelessWidget {
  const LikeSolo({
    super.key,
    required this.like,
  });

  final Like like;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(),
      child: Flexible(
        child: ListTile(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(flex:1,child: UserBlockText(user: like.liker)),
              Expanded(flex:3,child: Center(child: Icon(
                Icons.thumb_up,
                size: 24.0,
                semanticLabel: 'Likes',
              ),),),
              Expanded(flex:1,child: UserBlockText(user: like.likee)),
            ],
          ),
        ),
      ),
    );
  }
}
