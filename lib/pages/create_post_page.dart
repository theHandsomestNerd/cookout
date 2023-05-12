import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sanity_image_url/flutter_sanity_image_url.dart';
import 'package:go_router/go_router.dart';
import 'package:hashtagable/hashtagable.dart';
import 'package:cookowt/models/controllers/auth_inherited.dart';
import 'package:cookowt/wrappers/alerts_snackbar.dart';
import 'package:cookowt/wrappers/analytics_loading_button.dart';

import '../../platform_dependent/image_uploader.dart'
    if (dart.library.io) '../../platform_dependent/image_uploader_io.dart'
    if (dart.library.html) '../../platform_dependent/image_uploader_html.dart';
import '../models/controllers/analytics_controller.dart';
import '../models/controllers/auth_controller.dart';
import '../models/controllers/post_controller.dart';
import '../platform_dependent/image_uploader_abstract.dart';
import '../shared_components/app_image_uploader.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key, this.onClose, required this.onPost});

  final Function? onClose;
  final Function onPost;

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final AlertSnackbar _alertSnackbar = AlertSnackbar();
  ImageUploader? imageUploader;
  AuthController? authController;
  PostController? postController;
  AnalyticsController? analyticsController;

  String? _postBody;
  List<String> _postBodies = [];
  bool? _isPosting;
  ImageProvider? imageToBeUploaded;
  late SanityImage? profileImage;

  Uint8List? theFileBytes;

  @override
  initState() {
    super.initState();

    var theUploader = ImageUploaderImpl();
    imageUploader = theUploader;
    theUploader.addListener(() async {
      if (kDebugMode) {
        print("image uploader change");
      }
      if (theUploader.croppedFile != null) {
        if (kDebugMode) {
          print("there iz a cropped");
        }
        theFileBytes = await theUploader.croppedFile?.readAsBytes();
      } else {
        if (kDebugMode) {
          print("there iz a file");
        }
        theFileBytes = await theUploader.file?.readAsBytes();
      }
      setState(() {});
    });
    // imageToBeUploaded = _getMyProfileImage(null);
  }

  @override
  didChangeDependencies() async {
    AuthController? theAuthController =
        AuthInherited.of(context)?.authController;
    authController = theAuthController;
    PostController? thePostController =
        AuthInherited.of(context)?.postController;
    postController = thePostController;

    AnalyticsController? theAnalyticsController =
        AuthInherited.of(context)?.analyticsController;

    theAnalyticsController?.logScreenView('Upload Photos');

    analyticsController = theAnalyticsController;

    if (!((_postBody?.length ?? -1) <= 0) && (_postBody?.length ?? 0) < 5) {
      await analyticsController
          ?.sendAnalyticsEvent('post-form-enabled', {"body": _postBody});
    }
    setState(() {});
    super.didChangeDependencies();
  }

  void _setPostBody(String newPostBody, int index) async {
    if (_postBodies.length < (imageUploader?.files?.length ?? 0)) {
      _postBodies = List.filled(imageUploader?.files?.length ?? 0, "");
    }
    setState(() {
      _postBodies[index] = newPostBody;
      _postBody = newPostBody;
    });
  }

  List<bool> isPostingArr = [];
  List<String?> postResponse = [];

  _makePost(context) async {
    if (imageUploader?.files != null) {
      var counter = 0;
      isPostingArr = List.filled(imageUploader?.files?.length ?? 0, false);
      postResponse = List.filled(imageUploader?.files?.length ?? 0, "");

      for (var element in imageUploader!.files!) {
        setState(() {
          _isPosting = true;
          isPostingArr[counter] = true;
        });

        var thePostBody = "";
        if (_postBodies.length >= (counter + 1)) {
          thePostBody = _postBodies[counter];
        }

        // print(" make post");
        try {
          postResponse[counter] = await postController?.createPost(thePostBody,
              element?.name ?? "", await element?.readAsBytes(), context);
        } catch (e) {
          postResponse[counter] = "FAIL";
        }

        setState(() {
          isPostingArr[counter] = false;
          _isPosting = false;
        });
        counter++;
      }
    }
    // setState(() {
    //   _isPosting = true;
    // });
    // String? postResponse;
    //
    // // print(" make post");
    // postResponse = await postController?.createPost(_postBody ?? "",
    //     imageUploader?.file?.name ?? "", theFileBytes, context);
    //
    // setState(() {
    //   _isPosting = false;
    // });

    if (postResponse.contains('FAIL')) {
      return "FAIL";
    } else {
      return "SUCCESS";
    }
    // print(" post response $postResponse");
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    sendSuccess() async {
      await _alertSnackbar.showSuccessAlert("Post created:", context);
    }

    sendError() async {
      await _alertSnackbar.showErrorAlert(
          "Post creation failed. Try again.", context);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Flex(
            direction: Axis.horizontal,
            children: [
              Flexible(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        AppImageUploader(
                          height: 250,
                          width: 250,
                          text: "Add Photo(s)",
                          imageUploader: imageUploader!,
                          uploadImage: (uploader) {
                            imageUploader = uploader;
                          },
                        ),
                        Column(
                          children: postResponse
                              .asMap()
                              .entries
                              .map((thePostingResponse) {
                            if (isPostingArr[thePostingResponse.key] == true) {
                              return SizedBox(
                                  height: 289,
                                  child: Container(
                                      color: Colors.black87.withOpacity(.5),
                                      child: Center(
                                          child: CircularProgressIndicator())));
                            }
                            return SizedBox(
                                height: 289,
                                child: Container(
                                    color: Colors.black87.withOpacity(.5),
                                    child: Center(
                                        child: Text(
                                      postResponse[thePostingResponse.key] ??
                                          "Pending",
                                      style: TextStyle(color: Colors.white70),
                                    ))));
                          }).toList(),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              if ((imageUploader?.files?.length ?? -1) > 0)
                Flexible(
                  flex: 1,
                  child: Column(
                    children: imageUploader?.files?.asMap().entries.map((e) {
                          return SizedBox(
                            height: 250,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                HashTagTextField(
                                  decoratedStyle: TextStyle(
                                      fontSize: 14, color: Colors.blue),
                                  basicStyle: TextStyle(
                                      fontSize: 14, color: Colors.black),
                                  onChanged: (element) {
                                    _setPostBody(element, e.key);
                                  },
                                  decorateAtSign: true,
                                  minLines: 2,
                                  maxLines: 4,
                                  decoration: const InputDecoration(
                                    border: UnderlineInputBorder(),
                                    labelText: 'Hashtags & Description:',
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList() ??
                        [],
                  ),
                ),
            ],
          ),
        ),
        AnalyticsLoadingButton(
          analyticsEventName: 'create-post',
          analyticsEventData: {"body": _postBody.toString(), "author": ""},
          action: (innerContext) async {
            var status = await _makePost(innerContext);

            if (status == "SUCCESS") {
              await sendSuccess();
            } else if (status == "FAIL") {
              await sendError();
            }

            await widget.onPost();
            setState(() {});
            if (!postResponse.contains("FAIL")) {
              _postBodies = [];
              imageUploader?.clear();
              // GoRouter.of(innerContext).go('/postsPage');
            }

            // Navigator.popAndPushNamed(context, '/postsPage');
          },
          text: "Post",
        ),
        SizedBox(height:70),
      ],
    );
  }
}
