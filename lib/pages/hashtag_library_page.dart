import 'package:flutter/material.dart';
import 'package:cookowt/layout/full_page_layout.dart';
import 'package:cookowt/shared_components/menus/home_page_menu.dart';
import 'package:cookowt/wrappers/app_scaffold_wrapper.dart';
import 'package:cookowt/wrappers/hashtag_collection.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'create_post_page.dart';


class HashtagLibraryPage extends StatefulWidget {
  const HashtagLibraryPage({
    super.key,
  });

  @override
  State<HashtagLibraryPage> createState() => _HashtagLibraryPageState();
}

class _HashtagLibraryPageState extends State<HashtagLibraryPage> {
  bool isPanelOpen = false;
  PanelController panelController = PanelController();
  @override
  Widget build(BuildContext context) {
    final List<String> hashtagList = [
      "the-lines",
      "numbers",
      "theta-chi",
      "other-bruhs",
      "other-greeks"
    ];
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return AppScaffoldWrapper(
      key: widget.key,
      floatingActionMenu: HomePageMenu(
        updateMenu: () {},
      ),
      child: FullPageLayout(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0,0,0,48.0,),
              child: ListView(
                children: hashtagList.map((element) {
                  return Hashtag_Collection_Block(
                    collectionSlug: element,
                  );
                }).toList(),
              ),
            ),
            SlidingUpPanel(
              onPanelClosed: () {
                isPanelOpen = false;
              },
              onPanelOpened: () {
                isPanelOpen = true;
              },
              collapsed: MaterialButton(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                color: Colors.red,
                onPressed: () {
                  if (isPanelOpen) {
                    panelController.close();
                    // isPanelOpen = false;
                  } else {
                    panelController.open();
                    // isPanelOpen = true;
                  }
                  setState(() {});
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        8.0,
                        8.0,
                        8.0,
                        16.0,
                      ),
                      child: Container(
                        color: Colors.white,
                        width: 80,
                        height: 3,
                      ),
                    ),
                    const Text(
                      "Upload Photo(s)",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ],
                ),
              ),
              controller: panelController,
              backdropEnabled: true,
              isDraggable: true,
              parallaxEnabled: false,
              maxHeight: 500,
              color: Colors.transparent,
              minHeight: 64,
              panelBuilder: (scrollController) => SingleChildScrollView(
                // controller: scrollController,
                child: Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(0),
                          bottomLeft: Radius.circular(0))),
                  margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                  child: Flex(
                    direction: Axis.horizontal,
                    children: [
                      // MaterialButton(
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.all(Radius.circular(20)),
                      //   ),
                      //   color: Colors.white,
                      //   onPressed: () {
                      //     panelController.close();
                      //   },
                      //   child: Flex(
                      //     direction: Axis.vertical,
                      //     children: [
                      //       Flexible(
                      //         flex: 1,
                      //         child: Padding(
                      //           padding: const EdgeInsets.fromLTRB(
                      //             8.0,
                      //             8.0,
                      //             8.0,
                      //             8.0,
                      //           ),
                      //           child: Container(
                      //             color: Colors.white,
                      //             width: 80,
                      //             height: 3,
                      //           ),
                      //         ),
                      //       ),
                      //       Expanded(
                      //         flex: 2,
                      //         child: Column(
                      //           mainAxisAlignment: MainAxisAlignment.center,
                      //           children: [
                      //             Text(
                      //               "Create a Post",
                      //               style: TextStyle(color: Colors.black, fontSize: 18),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ],
                      //   ),
                      // ),

                      Expanded(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 48,
                              child: Flex(
                                  direction: Axis.horizontal,
                                  children: [
                                    Expanded(
                                      child: MaterialButton(
                                        elevation: 0,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(20)),
                                        ),
                                        color: Colors.white,
                                        onPressed: () {
                                          panelController.hide();
                                        },
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                              const EdgeInsets.fromLTRB(
                                                8.0,
                                                8.0,
                                                8.0,
                                                8.0,
                                              ),
                                              child: Container(
                                                color: Colors.black,
                                                width: 80,
                                                height: 3,
                                              ),
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                              MainAxisAlignment.center,
                                              children: const [
                                                Text(
                                                  "Upload Photo(s)",
                                                  style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 18),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ]),
                            ),
                            CreatePostPage(
                              onPost: () {
                                panelController.close();
                                // _pagingController.firstPageKey
                              },
                              onClose: () {
                                panelController.close();
                                setState(() {});
                              },
                            ),
                            const SizedBox(
                              height: 24,
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
