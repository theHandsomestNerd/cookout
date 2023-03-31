import 'dart:math';

import 'package:chat_line/models/block.dart';
import 'package:chat_line/models/extended_profile.dart';
import 'package:chat_line/models/clients/chat_client.dart';
import 'package:chat_line/models/timeline_event.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../app_user.dart';
import '../like.dart';

class ChatController {
  ExtendedProfile? myExtProfile;
  List<AppUser> profileList = [];
  List<Block> myBlockedProfiles = [];
  List<TimelineEvent> timelineOfEvents = [];

  ChatClient profileClient = ChatClient();

  updateChatController() async {
    myExtProfile = await profileClient
        .getExtendedProfile(FirebaseAuth.instance.currentUser?.uid ?? "");
    profileList = await profileClient.fetchProfiles();
    myBlockedProfiles = await profileClient.getMyBlockedProfiles();
    timelineOfEvents = await profileClient.retrieveTimelineEvents();
    return;
  }

  ChatController.init() {
    if (FirebaseAuth.instance.currentUser != null) {
      // updateChatController().then(() {
      //   print("Done init chat controll");
      // });
    }

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        if (kDebugMode) {
          print('chatController: User is currently signed out!');
        }
      } else {
        if (kDebugMode) {
          print('chatController: User is signed in!');
        }

        await updateChatController();
      }
    });
  }

  updateExtProfile(String userId) async {
    var theExtProfile = await profileClient.getExtendedProfile(userId);

    myExtProfile = theExtProfile;
    profileList = await profileClient.fetchProfiles();
    return theExtProfile;
  }

  updateTimelineEvents() async {
    var theTimelineEvents = await profileClient.retrieveTimelineEvents();
    myBlockedProfiles = await profileClient.getMyBlockedProfiles();
    timelineOfEvents = theTimelineEvents;
    profileList = await profileClient.fetchProfiles();
    return theTimelineEvents;
  }

  updateProfiles() async {
    var aListOfProfiles = await profileClient.fetchProfiles();
    profileList = aListOfProfiles;
    return aListOfProfiles;
  }

  updateMyBlocks() async {
    List<Block> theNewBlocks = await profileClient.getMyBlockedProfiles();
    myBlockedProfiles = theNewBlocks;
    timelineOfEvents = await profileClient.retrieveTimelineEvents();
    profileList = await profileClient.fetchProfiles();
    return theNewBlocks;
  }

  Future<AppUser?> fetchHighlightedProfile() async {
    var theProfiles = await profileClient.fetchProfiles();
    profileList = [...theProfiles];

    theProfiles.removeWhere((element){
      if(element.profileImage == null){
        return true;
      }
      return false;
    });

    var rng = Random();
    rng.nextInt(theProfiles.length - 1);

    if (theProfiles.isNotEmpty) {
      return theProfiles[rng.nextInt(theProfiles.length - 1)];
    }

    return null;
  }

  bool isProfileBlockedByMe(String userId) {
    bool foundBlock = false;

    for (var element in myBlockedProfiles) {
      if (element.blocked?.userId == userId) {
        foundBlock = true;
      }
    }

    return foundBlock;
  }

  unblockProfile(Block block) async {
    String? unblockResponse = await profileClient.unblockProfile(block);
    if (unblockResponse == "SUCCESS") {
      await updateMyBlocks();
    }
    return unblockResponse;
  }

  bool isProfileLikedByMe(String userId, List<Like> theLikesPassed) {
    bool foundLike = false;

    for (var element in theLikesPassed) {
      if (element.liker?.userId == userId) {
        foundLike = true;
      }
    }

    return foundLike;
  }
}
