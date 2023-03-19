import 'dart:developer';

import 'package:flutter/material.dart';

class SearchBox extends StatefulWidget {
  const SearchBox({super.key, required this.searchTerms, this.setTerms});

  final String searchTerms;
  final setTerms;

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  String _searchTerms = "";
  void setTerms(terms) {
    print(terms);
    widget.setTerms(terms);
    setState(() {
      _searchTerms = terms;
    });
  }

  void _openFilterMenu() {
    log('open filter menu');
  }

  void _clearSearch() {
    log("clear search");
    setTerms("");
  }

  // initState(){
  // }

  @override
  void initState() {
    super.initState();
    _searchTerms = widget.searchTerms;
    // if (widget == null) {
    //   _controller = new TextEditingController(text: widget.initialValue);
    // } else {
    //   widget.controller.addListener(_handleControllerChanged);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: <Widget>[
          Expanded(
            flex: 10,
            child: TextFormField(
              key: ObjectKey(_searchTerms),
              autofocus: true,
              initialValue: _searchTerms,
              onChanged: (e) {
                setTerms(e);
              },
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Enter your search',
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: IconButton(
              onPressed: _clearSearch,
              icon: const Icon(
                Icons.close,
                size: 24.0,
                semanticLabel: 'Clear Search',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
