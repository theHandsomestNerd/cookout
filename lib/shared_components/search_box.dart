import 'dart:developer';

import 'package:cookowt/models/app_user.dart';
import 'package:easy_search_bar/easy_search_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/clients/api_client.dart';
import '../models/controllers/auth_inherited.dart';
import '../models/hash_tag.dart';
import '../pages/search_type_enum.dart';
import 'logo.dart';

class SearchBox extends StatefulWidget {
  const SearchBox(
      {super.key,
      required this.searchTerms,
      required this.setTerms,
      required this.searchType});

  final String searchTerms;
  final Function setTerms;

  final SEARCH_TYPE_ENUM searchType;

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  String _searchTerms = "";

  Future<List<String?>> setTerms(String terms) async {
    if (kDebugMode) {
      print(terms);
    }
    setState(() {
      _searchTerms = terms;
    });
    await _getHashtagSuggestions(terms);
    await widget.setTerms(terms);

    return [terms];
  }

  void _clearSearch() async {
    log("clear search");
    await setTerms("");
  }

  @override
  void initState() {
    super.initState();
    _searchTerms = widget.searchTerms;
  }

  ApiClient? client;

  // final AlertSnackbar _alertSnackbar = AlertSnackbar();

  @override
  didChangeDependencies() async {
    var theClient = AuthInherited.of(context)?.chatController?.profileClient;
    if (theClient != null) {
      client = theClient;
    }

    setState(() {});
    super.didChangeDependencies();
  }

  List<String> _suggestions = [];

  _getHashtagSuggestions(terms) async {
    switch (widget.searchType) {
      case SEARCH_TYPE_ENUM.profiles:
        List<String> theSuggestions = (await client?.search(
                terms, widget.searchType, "", 500) as List<AppUser>)
            .map((AppUser suggestedHashtag) {
          return suggestedHashtag.displayName ?? "";
        }).toList();

        _suggestions = theSuggestions;
        setState(() {});
        return theSuggestions;
      case SEARCH_TYPE_ENUM.hashtagRelations:
        List<String> theSuggestions = (await client?.search(
                terms, SEARCH_TYPE_ENUM.hashtags, "", 500) as List<Hashtag>)
            .map((Hashtag suggestedHashtag) {
          return suggestedHashtag.tag ?? "";
        }).toList();
        _suggestions = theSuggestions;
        setState(() {});
        return theSuggestions;
        break;
      case SEARCH_TYPE_ENUM.hashtags:
        // TODO: Handle this case.
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return EasySearchBar(
      backgroundColor: Colors.white.withOpacity(.80),
      title: Row(
        children: [
          Logo(
            disableLink: false,
          ),
        ],
      ),
      onSearch: (value) {
        return setTerms(value);
        // return [''];
      },
      suggestions: _suggestions,
    );
  }
}
