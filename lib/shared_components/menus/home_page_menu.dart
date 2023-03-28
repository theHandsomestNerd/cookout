import 'package:flutter/material.dart';

import '../../models/controllers/auth_inherited.dart';
import '../../sanity/image_url_builder.dart';
import '../../wrappers/expanding_fab.dart';

class HomePageMenu extends StatefulWidget {
  const HomePageMenu({Key? key, required this.updateMenu, this.selected})
      : super(key: key);
  final updateMenu;
  final selected;

  @override
  State<HomePageMenu> createState() => _HomePageMenuState();
}

enum ProfileMenuOptions {
  TIMELINE,
  LIKES_AND_FOLLOWS,
  BLOCKS,
  ALBUMS,
}

class _HomePageMenuState extends State<HomePageMenu> {
  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      distance: 158.0,
      children: [
        ActionButton(
          tooltip: "Settings",
          onPressed: () {
            Navigator.popAndPushNamed(context, '/settings');
          },
          icon: const Icon(Icons.settings),
        ),
        ActionButton(
          tooltip: "Album",
          onPressed: () {
            widget.updateMenu(ProfileMenuOptions.ALBUMS.index);
          },
          icon: const Icon(Icons.photo_album),
        ),
        ActionButton(
          tooltip: "Inbox",
          onPressed: () {
            widget.updateMenu(ProfileMenuOptions.LIKES_AND_FOLLOWS.index);
          },
          icon: const Icon(Icons.inbox),
        ),
        ActionButton(
          tooltip: "Timeline",
          onPressed: () {
            widget.updateMenu(ProfileMenuOptions.TIMELINE.index);
          },
          icon: const Icon(Icons.timeline),
        ),
        ActionButton(
          tooltip: "My Profile",
          onPressed: () {
            Navigator.pushNamed(context, '/myProfile');
          },
          icon: CircleAvatar(
            backgroundImage: NetworkImage(
              MyImageBuilder()
                      .urlFor(AuthInherited.of(context)
                          ?.authController
                          ?.myAppUser
                          ?.profileImage)
                      ?.height(100)
                      .width(100)
                      .url() ??
                  "",
            ),
          ),
        ),
      ],
    );
  }
}
