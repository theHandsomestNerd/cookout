import 'package:flutter/material.dart';

import '../models/block.dart';
import '../models/controllers/analytics_controller.dart';
import '../models/controllers/auth_controller.dart';
import '../models/controllers/auth_inherited.dart';
import '../models/controllers/chat_controller.dart';
import '../shared_components/bug_reporter/bug_reporter.dart';
import '../shared_components/menus/profile_page_menu.dart';
import 'tabs/blocks_tab.dart';
import 'tabs/profile_list_tab.dart';
import 'tabs/timeline_events_tab.dart';

class ProfilesPage extends StatefulWidget {
  const ProfilesPage({
    super.key,
  });

  @override
  State<ProfilesPage> createState() => _ProfilesPageState();
}

class _ProfilesPageState extends State<ProfilesPage> {
  int _selectedIndex = 0;
  String myUserId = "";
  AnalyticsController? analyticsController;

  AuthController? authController;
  ChatController? chatController;
  List<Block>? myBlockedProfiles = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  didChangeDependencies() async {
    var theChatController = AuthInherited.of(context)?.chatController;
    var theAuthController = AuthInherited.of(context)?.authController;
    myUserId =
        AuthInherited.of(context)?.authController?.myAppUser?.userId ?? "";
    AnalyticsController? theAnalyticsController =
        AuthInherited.of(context)?.analyticsController;

    if (analyticsController == null && theAnalyticsController != null) {
      await theAnalyticsController.logScreenView('profiles-page');
      analyticsController = theAnalyticsController;
    }
    if (authController == null && theAuthController != null) {
      authController = authController;
    }
    chatController = theChatController;
    myBlockedProfiles = await chatController?.updateMyBlocks();
    setState(() {});
    super.didChangeDependencies();
  }

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);

  Widget _widgetOptions(selectedIndex) {
    var theOptions = <Widget>[
      const ProfileListTab(),
      TimelineEventsTab(
          timelineEvents: chatController?.timelineOfEvents,
          id: authController?.myAppUser?.userId ?? ""),
      const Text(
        'Index 3: Likes and Follows',
        style: optionStyle,
      ),
      BlocksTab(
        blocks: myBlockedProfiles ?? [],
        unblockProfile: (context) async {
          await analyticsController?.sendAnalyticsEvent('profile-unblock',
              {"unblocker": authController?.myAppUser?.userId});

          myBlockedProfiles = await chatController?.updateMyBlocks();
          setState(() {});
        },
      ),
    ];

    return theOptions.elementAt(selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return BugReporter(
      child: Flex(
        direction: Axis.vertical,
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.loose,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              floatingActionButton: ProfilePageMenu(),
              // appBar: AppBar(
              //   backgroundColor: Colors.white.withOpacity(0.5),
              //   title: const Logo(),
              // ),
              body: Flex(
                direction: Axis.vertical,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(),
                      child: _widgetOptions(_selectedIndex),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    // return ConstrainedBox(
    //     constraints: const BoxConstraints(),
    //     child: _widgetOptions(
    //         _selectedIndex));
  }
}
