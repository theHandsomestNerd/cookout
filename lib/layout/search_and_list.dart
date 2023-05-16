import 'package:cookowt/pages/search_type_enum.dart';
import 'package:flutter/material.dart';

import '../shared_components/search_box.dart';

class SearchAndList extends StatefulWidget {
  const SearchAndList({
    super.key,
    required this.listChild,
    this.isSearchEnabled,
    required this.searchBoxSearchTerms,
    required this.searchBoxSetTerms,
    required this.searchType,
  });

  final Widget listChild;
  final bool? isSearchEnabled;
  final String searchBoxSearchTerms;
  final SEARCH_TYPE_ENUM searchType;

  final Function searchBoxSetTerms;
  @override
  State<SearchAndList> createState() => _SearchAndListState();
}

class _SearchAndListState extends State<SearchAndList> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(),
        child: Flex(direction: Axis.vertical, children: [
          widget.isSearchEnabled != false
              ? SizedBox(
                  height: 64,
                  child: SearchBox(
                    searchTerms: widget.searchBoxSearchTerms,
                    setTerms: widget.searchBoxSetTerms,
                    searchType: widget.searchType,
                  ),
                )
              : const Text(""),
          Expanded(
            child: widget.listChild,
          ),
        ]),
      ),
    );
  }
}
