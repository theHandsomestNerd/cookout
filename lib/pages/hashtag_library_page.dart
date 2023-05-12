import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../models/clients/api_client.dart';
import '../models/controllers/analytics_controller.dart';
import '../models/controllers/auth_inherited.dart';
import '../models/post.dart';
import '../shared_components/menus/home_page_menu.dart';
import '../shared_components/search_box.dart';
import '../wrappers/app_scaffold_wrapper.dart';
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
  bool isPanelOpen = false;
  PanelController panelController = PanelController();

  final PagingController<String, Post> _pagingController =
  PagingController(firstPageKey: "");

  // AuthController? authController;
  late ApiClient client;
  AnalyticsController? analyticsController;

  static const _pageSize = 20;
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
    // var theChatController = AuthInherited.of(context)?.chatController;
    // var theAuthController = AuthInherited.of(context)?.authController;
    var theAnalyticsController = AuthInherited.of(context)?.analyticsController;
    var theClient = AuthInherited.of(context)?.chatController?.profileClient;
    if (theClient != null) {
      client = theClient;
      setState(() {});
    }

    if (theAnalyticsController != null && analyticsController == null) {
      analyticsController = theAnalyticsController;
      setState(() {});
    }

    // AnalyticsController? theAnalyticsController =
    //     AuthInherited.of(context)?.analyticsController;

    // if(analyticsController == null && theAnalyticsController != null) {
    //   await theAnalyticsController.logScreenView('profiles-page');
    //   analyticsController = theAnalyticsController;
    // }
    // if (authController == null && theAuthController != null) {
    //   authController = theAuthController;
    //   setState(() {});
    // }
    // myUserId =
    //     AuthInherited.of(context)?.authController?.myAppUser?.userId ?? "";
    // if((widget.profiles?.length??-1) > 0){
    //
    // // profiles = theAuthController;
    //
    // } else {
    //   profiles = await chatController?.updateProfiles();
    // }

    // profiles = await chatController?.updateProfiles();
    // setState(() {});
    super.didChangeDependencies();
  }

  String? searchTerms="";

  Future<void> _fetchPage(String pageKey) async {
    // print(
    //     "Retrieving post page with pagekey $pageKey  and size $_pageSize $client");
    try {
      List<Post>? newItems;
      newItems = await client.searchHashtags(searchTerms,pageKey, _pageSize);

      // print("Got more items ${newItems.length}");
      final isLastPage = (newItems.length) < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = newItems.last.id;
        if (nextPageKey != null) {
          _pagingController.appendPage(newItems, nextPageKey);
        }
      }
      setState(() {

      });
    } catch (error) {
      print(error);
      // _pagingController.error = error;
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
      // "the-lines",
      // "numbers",
      // "theta-chi",
      // "other-bruhs",
      // "other-greeks"
    ];

    List<Post> searchResults;
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
      child: Flex(
        direction: Axis.vertical,
        children: List.from([
          SearchBox(
            searchType: SEARCH_TYPE_ENUM.hashtag,
            searchTerms: searchTerms??"",
            setTerms: (terms) async {
              //search hashtags
              searchTerms = terms;
              _pagingController.refresh();
              await _fetchPage(_pagingController.firstPageKey);
              // searchResults = await client.searchHashtags(terms, "", 10);
            },
          )
        ])..addAll(hashtagList.map((element) {
            return Hashtag_Collection_Block(
              collectionSlug: element,
            );
          }).toList())
          ..addAll([Expanded(
              child: PostsContent(pagingController: _pagingController))]),
      ),
    );
  }
}
