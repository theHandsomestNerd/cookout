import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../wrappers/expanding_fab.dart';
enum SettingsMenuOptions {
  EDIT_PROFILE,
  TIMELINE,
  BLOCKS,
  PEOPLE,
}
class SettingsPageMenu extends StatefulWidget {
  const SettingsPageMenu({Key? key, required this.updateMenu})
      : super(key: key);
  final Function updateMenu;

  @override
  State<SettingsPageMenu> createState() => _SettingsPageMenuState();
}

class _SettingsPageMenuState extends State<SettingsPageMenu> {
  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      distance: 158.0,
      children: [
          ActionButton(
            tooltip: "Logout",
            onPressed: () {
              GoRouter.of(context).go('/logout');
            },
            icon: const Icon(Icons.logout),
          ),
        ActionButton(
          tooltip: "Hashtags",
          onPressed: () {
            GoRouter.of(context).go('/hashtagCollections');
          },
          icon: const Icon(Icons.tag),
        ),
        ActionButton(
          tooltip: "Chapter Roster",
          onPressed: () {
            GoRouter.of(context).go('/chapterRoster');
          },
          icon: const Icon(Icons.list),
        ),
        ActionButton(
          tooltip: "Edit Profile",
          onPressed: () {
            widget.updateMenu(SettingsMenuOptions.EDIT_PROFILE.index);
          },
          icon: const Icon(Icons.edit),
        ),
        ActionButton(
          tooltip: "Timeline",
          onPressed: () {
            widget.updateMenu(SettingsMenuOptions.TIMELINE.index);
          },
          icon: const Icon(Icons.timeline),
        ),
        ActionButton(
          tooltip: "Blocked Users",
          onPressed: () {
            widget.updateMenu(SettingsMenuOptions.BLOCKS.index);
          },
          icon: const Icon(Icons.block),
        ),
        ActionButton(
          tooltip: "Home",
          onPressed: () {
            GoRouter.of(context).go('/home');
          },
          icon: const Icon(Icons.home),
        ),
      ],
    );
  }
}
