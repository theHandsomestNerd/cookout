import 'package:cookowt/shared_components/bug_reporter/bug_reporter.dart';
import 'package:cookowt/shared_components/logo.dart';
import 'package:flutter/material.dart';

class AppScaffoldWrapper extends StatelessWidget {
  const AppScaffoldWrapper({Key? key, this.floatingActionMenu, required this.child, this.isAppBar})
      : super(key: key);

  final Widget? floatingActionMenu;
  final bool? isAppBar;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BugReporter(
      child: Flex(
        direction: Axis.vertical,
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.loose,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              floatingActionButton: floatingActionMenu,
              appBar: isAppBar == true ? AppBar(
                backgroundColor: Colors.white.withOpacity(0.5),
                title: const Logo(),
              ): null,
              body: Flex(
                direction: Axis.vertical,
                children: [
                  Flexible(fit:FlexFit.loose, child: child),
                ],
              ),
            ),
          ),
        ],
      ),
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }
}
