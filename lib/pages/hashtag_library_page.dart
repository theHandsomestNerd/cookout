import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../layout/search_and_list.dart';
import '../models/clients/api_client.dart';
import '../models/controllers/analytics_controller.dart';
import '../models/controllers/auth_inherited.dart';
import '../models/post.dart';
import '../shared_components/bug_reporter/bug_reporter.dart';
import '../shared_components/menus/home_page_menu.dart';
import '../wrappers/hashtag_collection.dart';
import 'posts_content.dart';
import 'search_type_enum.dart';

class HashtagLibraryPage extends StatefulWidget {
  const HashtagLibraryPage({
    super.key,
  });

  @override
  State<HashtagLibraryPage> createState() => _HashtagLibraryPageState();
}

class _HashtagLibraryPageState extends State<HashtagLibraryPage> {
  PanelController panelController = PanelController();

  final PagingController<String, Post> _pagingController =
      PagingController(firstPageKey: "");

  // AuthController? authController;
  ApiClient? client;
  AnalyticsController? analyticsController;

  static const _pageSize = 25;
  String? lastId = "";

  @override
  void initState() {
    _pagingController.addPageRequestListener((theLastId) async {
      if (theLastId != null && theLastId != "") {
        lastId = theLastId;
      }

      // if(lastId != "" && lastId != null) {
      //   return _fetchPage(lastId!);
      // }
      return _fetchPage(theLastId);
    });

    super.initState();
  }

  @override
  didChangeDependencies() async {
    var theAnalyticsController = AuthInherited.of(context)?.analyticsController;
    if (theAnalyticsController != null && analyticsController == null) {
      analyticsController = theAnalyticsController;
      setState(() {});
    }
    var theClient = AuthInherited.of(context)?.chatController?.profileClient;

    if (client == null && theClient != null) {
      client = theClient;
      setState(() {});
    }

    super.didChangeDependencies();
  }

  String? searchTerms = "";

  Future<void> _fetchPage(String pageKey) async {
    try {
      List<Post>? newItems;
      newItems = await client?.search(searchTerms,
          SEARCH_TYPE_ENUM.hashtagRelations, pageKey, _pageSize) as List<Post>;

      final isLastPage = (newItems.length) < _pageSize;
      if (isLastPage) {
        print("Appending last page");
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = newItems.last.id;
        if (nextPageKey != null) {
          _pagingController.appendPage(newItems, nextPageKey);
        }
      }
      setState(() {});
    } catch (error) {
      // print(error);
      _pagingController.error = error;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> hashtagList = [
      "popular",
    ];

    return BugReporter(
      child: Flex(
        direction: Axis.vertical,
        children: [
          Flexible(
            flex: 1,
            fit: FlexFit.loose,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              floatingActionButton: HomePageMenu(
                updateMenu: () {},
              ),
              // appBar: AppBar(
              //   backgroundColor: Colors.white.withOpacity(0.5),
              //   title: const Logo(),
              // ),
              body: Flex(
                direction: Axis.vertical,
                children: [
                  Flexible(
                    fit: FlexFit.loose,
                    child: SearchAndList(
                      searchType: SEARCH_TYPE_ENUM.hashtagRelations,
                      searchBoxSearchTerms: searchTerms ?? "",
                      searchBoxSetTerms: (terms) async {
                        //search hashtags
                        searchTerms = terms;
                        _pagingController.refresh();
                        await _fetchPage(_pagingController.firstPageKey);
                        // searchResults = await client.searchHashtags(terms, "", 10);
                      },
                      isSearchEnabled: true,
                      listChild: Flex(
                        direction: Axis.vertical,
                        children: List.from(hashtagList.map((element) {
                          return Hashtag_Collection_Block(
                            collectionSlug: element,
                          );
                        }).toList())
                          ..addAll([
                            Expanded(
                              child: PostsContent(
                                  pagingController: _pagingController),
                            ),
                          ]),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
