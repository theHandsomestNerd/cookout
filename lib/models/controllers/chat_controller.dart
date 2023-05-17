import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../config/default_config.dart';
import '../app_user.dart';
import '../block.dart';
import '../clients/api_client.dart';
import '../extended_profile.dart';
import '../like.dart';
import '../timeline_event.dart';

class ChatController {
  ExtendedProfile? myExtProfile;
  // List<AppUser> profileList = [];
  List<Block> myBlockedProfiles = [];
  List<TimelineEvent> timelineOfEvents = [];

  late ApiClient profileClient;

  updateChatController() async {
    myExtProfile = await profileClient
        .getExtendedProfile(FirebaseAuth.instance.currentUser?.uid ?? "");
    // profileList = await profileClient.fetchProfiles();
    myBlockedProfiles = await profileClient.getMyBlockedProfiles();
    timelineOfEvents = await profileClient.retrieveTimelineEvents();
    return;
  }

  ChatController.init() {
    profileClient = ApiClient(DefaultConfig.theAuthBaseUrl);

    if (FirebaseAuth.instance.currentUser != null) {
      // updateChatController().then(() {
      //   print("Done init chat controll");
      // });
    }

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
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
    print("theEXT profile $theExtProfile ");
    return theExtProfile;
  }

  updateTimelineEvents() async {
    var theTimelineEvents = await profileClient.retrieveTimelineEvents();
    myBlockedProfiles = await profileClient.getMyBlockedProfiles();
    timelineOfEvents = theTimelineEvents;
    return theTimelineEvents;
  }

  updateMyBlocks() async {
    List<Block> theNewBlocks = await profileClient.getMyBlockedProfiles();
    myBlockedProfiles = theNewBlocks;
    timelineOfEvents = await profileClient.retrieveTimelineEvents();
    // profileList = await profileClient.fetchProfiles();
    return theNewBlocks;
  }

  Future<AppUser?> fetchHighlightedProfile() async {
    var theProfiles = await profileClient.fetchProfiles();
    // profileList = [...theProfiles];

    theProfiles.removeWhere((element) {
      if (element.profileImage == null) {
        return true;
      }
      return false;
    });


    if (theProfiles.isNotEmpty) {
      var rng = Random();
      rng.nextInt(theProfiles.length);
      return theProfiles[rng.nextInt(theProfiles.length)];
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
