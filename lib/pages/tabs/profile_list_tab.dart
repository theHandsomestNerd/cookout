import 'package:cookowt/layout/search_and_list.dart';
import 'package:cookowt/pages/search_type_enum.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../models/app_user.dart';
import '../../models/clients/api_client.dart';
import '../../models/controllers/auth_inherited.dart';
import '../../shared_components/profile/profile_grid.dart';

class ProfileListTab extends StatefulWidget {
  const ProfileListTab({
    super.key,
  });

  @override
  State<ProfileListTab> createState() => _ProfileListTabState();
}

class _ProfileListTabState extends State<ProfileListTab> {
  static const _pageSize = 40;
  late ApiClient client;

  @override
  didChangeDependencies() async {
    var theClient = AuthInherited.of(context)?.chatController?.profileClient;
    if (theClient != null) {
      client = theClient;
    }

    setState(() {});
    super.didChangeDependencies();
  }

  final PagingController<String, AppUser> _pagingController =
      PagingController(firstPageKey: "");

  Future<void> _fetchPage(String pageKey) async {
    // print("Retrieving page with pagekey $pageKey  and size $_pageSize $client");
    try {
      List<AppUser>? newItems;
      newItems = await client.search(searchTerms, SEARCH_TYPE_ENUM.profiles, pageKey, _pageSize) as List<AppUser>;

      // print("Got more items ${newItems.length}");
      final isLastPage = (newItems.length) < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = newItems.last.userId;
        if (nextPageKey != null) {
          _pagingController.appendPage(newItems, nextPageKey);
        }
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void initState() {
    _pagingController.addPageRequestListener((theLastId) async {
      return _fetchPage(theLastId);
    });

    super.initState();
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  String? searchTerms;

  // late List<AppUser> profileList = [];
  @override
  Widget build(BuildContext context) {
    return SearchAndList(
      searchType: SEARCH_TYPE_ENUM.profiles,
      searchBoxSearchTerms: searchTerms ?? "",
      searchBoxSetTerms: (terms) async {
        //search hashtags
        searchTerms = terms;
        _pagingController.refresh();
        await _fetchPage(_pagingController.firstPageKey);
        // searchResults = await client.searchHashtags(terms, "", 10);
      },
      isSearchEnabled: true,
      listChild: ProfileGrid(pagingController: _pagingController),
    );
  }
}
