import 'dart:core';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:cookowt/layout/full_page_layout.dart';
import 'package:cookowt/models/clients/api_client.dart';
import 'package:cookowt/models/responses/chat_api_get_verifications_response.dart';
import 'package:cookowt/models/spreadsheet_member.dart';
import 'package:cookowt/models/spreadsheet_member_verification.dart';
import 'package:cookowt/shared_components/menus/home_page_menu.dart';
import 'package:cookowt/wrappers/app_scaffold_wrapper.dart';
import 'package:cookowt/wrappers/hashtag_collection.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../models/app_user.dart';
import '../models/controllers/auth_inherited.dart';
import '../shared_components/bug_reporter/bug_reporter_content.dart';
import 'chapter_member_content.dart';
import 'create_post_page.dart';

class ChapterRosterPage extends StatefulWidget {
  const ChapterRosterPage({
    super.key,
  });

  @override
  State<ChapterRosterPage> createState() => _ChapterRosterPageState();
}

class _ChapterRosterPageState extends State<ChapterRosterPage> {
  bool isPanelOpen = false;
  PanelController panelController = PanelController();
  List<SpreadsheetMember> spreadSheetMembers = [];
  late ApiClient client;

  List<String> selectedRows = [];

  List<SpreadsheetMemberVerification> verificationStatuses = [];
  SpreadsheetMemberVerification? myVerificationStatus;

  @override
  didChangeDependencies() async {
    var theClient = AuthInherited.of(context)?.chatController?.profileClient;
    if (theClient != null) {
      client = theClient;
      spreadSheetMembers = await theClient.fetchChapterRoster() ?? [];
      ChatApiGetVerificationsResponse? theVerificationStatuses =
          await theClient.fetchVerificationStatuses();
      if (theVerificationStatuses != null) {
        theVerificationStatuses.list.map((status) {
          print(status.spreadsheetMemberRef?.spreadsheetId);
        });
        verificationStatuses = theVerificationStatuses.list;
        myVerificationStatus = theVerificationStatuses.amIInThisList;
      }
    }

    setState(() {});
    super.didChangeDependencies();
  }

  isMemberVerified(String memberRosterNumber) {
    SpreadsheetMemberVerification? isVerified =
        verificationStatuses.firstWhereOrNull((element) {
      var test = element.spreadsheetMemberRef?.spreadsheetId.toString() ==
          memberRosterNumber.toString();
      return test;
    });

    if (isVerified != null) {
      if (isVerified.isApproved == true) {
        return "VERIFIED";
      } else if (isVerified.isApproved == false) {
        return "PENDING";
      }
    }
    return "NOT_VERIFIED";
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffoldWrapper(
      floatingActionMenu: HomePageMenu(
        updateMenu: () {},
      ),
      child: FullPageLayout(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                0,
                0,
                0,
                48.0,
              ),
              child: Container(
                padding: const EdgeInsets.all(15),
                child: PlutoGrid(
                  rowColorCallback: (rowColorContext) {
                    if (rowColorContext
                            .row.cells['status']?.value['isChapterInvisible'] ==
                        true) {
                      return Colors.red[50]!;
                    }
                    if (rowColorContext
                        .row.cells['status']?.value['onCampusPosition'] !=
                        "" && rowColorContext
                        .row.cells['status']?.value['onCampusPosition'] !=
                        null) {
                      return Colors.yellow[50]!;
                    }
                    if (rowColorContext
                        .row.cells['status']?.value['isOnTheYard'] ==
                        true) {
                      return Colors.green[50]!;
                    }

                    return rowColorContext.rowIdx % 2 == 0
                        ? Colors.white
                        : Colors.grey[50]!;
                  },
                  onRowDoubleTap: (e) {
                    showDialog<String>(
                      context: context,
                      barrierDismissible: false,
                      builder: (context) {
                        return ChapterMemberContent(
                          chapterMember: e.row,
                        );
                      },
                    );
                  },
                  configuration: PlutoGridConfiguration(
                      style: PlutoGridStyleConfig(rowHeight: 56,)),
                  key: ObjectKey(spreadSheetMembers),
                  columns: [
                    PlutoColumn(
                        readOnly: true,
                        title: 'Verified',
                        width: PlutoGridSettings.minColumnWidth,
                        field: 'verified',
                        type: PlutoColumnType.text(),
                        renderer: (rendererContext) {
                          if (rendererContext.row.cells['verified']?.value !=
                              null) {
                            if (rendererContext.row.cells['verified']?.value ==
                                "VERIFIED") {
                              return Icon(Icons.verified, color:  Colors.red[900],);
                            } else if (rendererContext
                                    .row.cells['verified']?.value ==
                                "NOT_VERIFIED") {
                              return Icon(Icons.verified_outlined, color: Colors.grey,);
                            } else if (rendererContext
                                    .row.cells['verified']?.value ==
                                "PENDING") {
                              return Icon(Icons.access_time, color: Colors.red[900],);
                            }
                          }

                          return Icon(Icons.verified_outlined);
                        }),
                    PlutoColumn(
                        readOnly: true,
                        title: 'ID',
                        width: PlutoGridSettings.minColumnWidth,
                        field: 'spreadsheetId',
                        type: PlutoColumnType.number()),
                    PlutoColumn(
                        readOnly: true,
                        title: 'Full Name',
                        field: 'name',
                        width: 230,
                        type: PlutoColumnType.text(),
                        renderer: (renderContext) {
                          var firstName =
                              renderContext.row.cells['firstName']?.value;
                          var middle =
                              renderContext.row.cells['middleName']?.value;
                          var lastName =
                              renderContext.row.cells['lastName']?.value;
                          var title = renderContext.row.cells['title']?.value;

                          return Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (firstName != "") Text(firstName),
                              SizedBox(
                                width: 2,
                              ),
                              if (middle != "") Text(middle),
                              SizedBox(
                                width: 2,
                              ),
                              if (lastName != "") Text("$lastName"),
                              if (title != "" && title != null)
                                Text(", $title"),
                            ],
                          );
                        }),
                    PlutoColumn(
                        readOnly: true,
                        width: 180,
                        title: 'Status',
                        field: 'status',
                        type: PlutoColumnType.text(),
                        renderer: (renderContext) {
                          var chapterInvisible = renderContext
                              .row.cells['status']?.value['isChapterInvisible'];
                          var livesOnCampus = renderContext
                              .row.cells['status']?.value['isLivesOnCampus'];
                          var isOnYard = renderContext
                              .row.cells['status']?.value['isOnTheYard'];
                          var campusPosition = renderContext
                              .row.cells['status']?.value['onCampusPosition'];

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (chapterInvisible == true)
                                Text('Chapter Invisible'),
                              if (livesOnCampus == true)
                                Text('Lives On Campus'),
                              if (isOnYard == true) Text('On the Yard'),
                              if (campusPosition != null)
                                Text('Campus Position: ${campusPosition}')
                            ],
                          );
                        }),
                    PlutoColumn(
                      readOnly: true,
                      title: 'Chapter Affiliation',
                      field: 'chapterAffiliation',
                      type: PlutoColumnType.text(),
                    ),
                    PlutoColumn(
                      readOnly: true,
                      title: 'Crossed On',
                      field: 'crossingDate',
                      type: PlutoColumnType.date(),
                    ),
                    PlutoColumn(
                      width: PlutoGridSettings.minColumnWidth,
                      readOnly: true,
                      title: 'Semester',
                      field: 'semester',
                      type: PlutoColumnType.text(),
                    ),
                    PlutoColumn(
                      width: PlutoGridSettings.minColumnWidth,
                      readOnly: true,
                      title: 'Year',
                      field: 'year',
                      type: PlutoColumnType.text(),
                    ),
                    PlutoColumn(
                      readOnly: true,
                      title: 'DOP',
                      field: 'dop',
                      type: PlutoColumnType.text(),
                    ),
                    PlutoColumn(
                      readOnly: true,
                      title: 'Name of Line',
                      field: 'nameOfLine',
                      type: PlutoColumnType.text(),
                    ),
                    PlutoColumn(
                      readOnly: true,
                      title: 'Line Name',
                      field: 'lineName',
                      type: PlutoColumnType.text(),
                    ),
                    PlutoColumn(
                      width: 100,
                      readOnly: true,
                      title: 'First Name',
                      field: 'firstName',
                      type: PlutoColumnType.text(),
                    ),
                    PlutoColumn(
                      width: 100,
                      readOnly: true,
                      title: 'Middle Name',
                      field: 'middleName',
                      type: PlutoColumnType.text(),
                    ),
                    PlutoColumn(
                      width: 180,
                      readOnly: true,
                      title: 'Last Name',
                      field: 'lastName',
                      type: PlutoColumnType.text(),
                    ),
                    PlutoColumn(
                      width: 120,
                      readOnly: true,
                      title: 'Nick Name',
                      field: 'nickName',
                      type: PlutoColumnType.text(),
                    ),
                    PlutoColumn(
                      width: 120,
                      readOnly: true,
                      title: 'Title(Jr,Sr)',
                      field: 'title',
                      type: PlutoColumnType.text(),
                    ),
                    PlutoColumn(
                        readOnly: true,
                        title: 'phone',
                        field: 'phoneNumbers',
                        type: PlutoColumnType.text(),
                        renderer: (renderContext) {
                          var homePhone = renderContext
                              .row.cells['phoneNumbers']?.value['homeNumber'];
                          var workPhone = renderContext
                              .row.cells['phoneNumbers']?.value['workNumber'];
                          var cellPhone = renderContext
                              .row.cells['phoneNumbers']?.value['cellNumber'];
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (cellPhone?.trim() != "" && cellPhone != null)
                                Text(
                                  "Cell: $cellPhone",
                                  style: TextStyle(fontSize: 10),
                                ),
                              if (homePhone?.trim() != "" && homePhone != null)
                                Text(
                                  "Home: $homePhone",
                                  style: TextStyle(fontSize: 10),
                                ),
                              if (workPhone?.trim() != "" && workPhone != null)
                                Text(
                                  "Work: $workPhone",
                                  style: TextStyle(fontSize: 10),
                                ),
                            ],
                          );
                        }),
                    PlutoColumn(
                        readOnly: true,
                        title: 'email',
                        field: 'email',
                        type: PlutoColumnType.text(),
                        renderer: (renderContext) {
                          var emails = renderContext.row.cells['email']?.value;

                          print(emails);

                          return emails != null
                              ? Column(
                                  children: emails?.map<Widget>((e) {
                                        return Text(
                                          e,
                                          style: TextStyle(fontSize: 12),
                                        );
                                      }).toList() ??
                                      <Widget>[])
                              : Container();
                        }),
                    PlutoColumn(
                        readOnly: true,
                        title: 'Address',
                        field: 'address',
                        type: PlutoColumnType.text(),
                        renderer: (renderContext) {
                          var address = renderContext
                              .row.cells['address']?.value['address'];
                          var city =
                              renderContext.row.cells['address']?.value['city'];
                          var state = renderContext
                              .row.cells['address']?.value['state'];
                          var zip =
                              renderContext.row.cells['address']?.value['zip'];
                          return Column(
                            children: [
                              if (address != null)
                                Text(
                                  "$address",
                                  style: TextStyle(fontSize: 10),
                                ),
                              if (city != null)
                                Text(
                                  "$city${state != null ? ", $state" : ""} ${zip != null ? zip : ""}",
                                  style: TextStyle(fontSize: 10),
                                ),
                            ],
                          );
                        }),
                    PlutoColumn(
                      width: PlutoGridSettings.minColumnWidth,
                      readOnly: true,
                      title: 'lineNumber',
                      field: 'lineNumber',
                      type: PlutoColumnType.text(),
                    ),
                    PlutoColumn(
                      readOnly: true,
                      title: 'dob',
                      field: 'dob',
                      type: PlutoColumnType.date(),
                    ),
                    PlutoColumn(
                      readOnly: true,
                      title: 'Occupation',
                      field: 'occupation',
                      type: PlutoColumnType.text(),
                    ),
                  ],
                  rows: spreadSheetMembers.map((member) {
                    var theVerification =
                        isMemberVerified(member.spreadsheetId ?? "");

                    return PlutoRow(cells: {
                      'verified': PlutoCell(value: theVerification),
                      'name': PlutoCell(value: member.firstName),
                      'spreadsheetId': PlutoCell(value: member.spreadsheetId),
                      'status': PlutoCell(value: {
                        'isChapterInvisible': member.isChapterInvisible,
                        'isOnTheYard': member.isOnTheYard,
                        'isLivesOnCampus': member.isLivesOnCampus,
                        'onCampusPosition': member.onCampusPosition,
                        'id': member.id
                      }),
                      'chapterAffiliation':
                          PlutoCell(value: member.otherChapterAffiliation),
                      'crossingDate':
                          PlutoCell(value: member.crossingDate ?? ""),
                      'semester': PlutoCell(value: member.semester),
                      'year': PlutoCell(value: member.year),
                      'dop': PlutoCell(value: member.dopName ?? ""),
                      'nameOfLine': PlutoCell(value: member.nameOfLine ?? ""),
                      'lineName': PlutoCell(value: member.lineName ?? ""),
                      'firstName': PlutoCell(value: member.firstName ?? ""),
                      'middleName': PlutoCell(value: member.middleName ?? ""),
                      'lastName': PlutoCell(value: member.lastName ?? ""),
                      'nickName': PlutoCell(value: member.nickName ?? ""),
                      'title': PlutoCell(value: member.title ?? ""),
                      'phoneNumbers': PlutoCell(value: {
                        'homeNumber': member.homePhone,
                        'workNumber': member.workPhone,
                        'cellNumber': member.cellPhone,
                      }),
                      'email': PlutoCell(value: member.email),
                      'address': PlutoCell(value: {
                        'address': member.address,
                        'city': member.city,
                        'state': member.state,
                        'zip': member.postalCode,
                      }),
                      'lineNumber': PlutoCell(value: member.lineNumber ?? ""),
                      'dob': PlutoCell(value: member.dob ?? ""),
                      'occupation': PlutoCell(value: member.occupation ?? ""),
                    });
                  }).toList(),
                ),
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
                              child:
                                  Flex(direction: Axis.horizontal, children: [
                                Expanded(
                                  child: MaterialButton(
                                    elevation: 0,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(20)),
                                    ),
                                    color: Colors.white,
                                    onPressed: () {
                                      panelController.hide();
                                    },
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
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
