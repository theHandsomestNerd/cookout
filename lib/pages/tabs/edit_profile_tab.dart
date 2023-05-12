import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sanity_image_url/flutter_sanity_image_url.dart';
import 'package:go_router/go_router.dart';
import 'package:cookowt/models/controllers/analytics_controller.dart';
import 'package:cookowt/models/controllers/auth_controller.dart';
import 'package:cookowt/wrappers/analytics_loading_button.dart';
import 'package:cookowt/wrappers/date_input_wrapped.dart';
import 'package:cookowt/wrappers/text_field_wrapped.dart';
import 'package:phone_form_field/phone_form_field.dart';

import '../../models/app_user.dart';
import '../../models/clients/api_client.dart';
import '../../models/controllers/auth_inherited.dart';
import '../../models/controllers/chat_controller.dart';
import '../../models/extended_profile.dart';
import '../../models/submodels/height.dart';
import '../../platform_dependent/image_uploader.dart'
    if (dart.library.io) '../../platform_dependent/image_uploader_io.dart'
    if (dart.library.html) '../../platform_dependent/image_uploader_html.dart';
import '../../platform_dependent/image_uploader_abstract.dart';
import '../../sanity/sanity_image_builder.dart';
import '../../shared_components/app_image_uploader.dart';
import '../../shared_components/height_input.dart';
import '../../wrappers/alerts_snackbar.dart';
import '../../wrappers/dropdown_input_wrapped.dart';

class EditProfileTab extends StatefulWidget {
  const EditProfileTab({
    Key? key,
    this.analyticsController,
  }) : super(key: key);

  final AnalyticsController? analyticsController;

  @override
  State<EditProfileTab> createState() => _EditProfileTabState();
}

class _EditProfileTabState extends State<EditProfileTab> {
  ExtendedProfile? extProfile;
  AppUser? _myAppUser;

  ApiClient? apiClient;
  AuthController? authController;

  String? _loginUsername;
  String? _displayName;
  late ImageUploader imageUploader;

  String? _shortBio;
  String? _longBio;

  String? _facebook;
  String? _twitter;
  String? _instagram;
  String? _tiktok;

  String? _ethnicity;
  String? _iAm;
  String? _imInto;
  String? _imOpenTo;
  String? _whatIDo;
  String? _whatImLookingFor;
  String? _whatInterestsMe;
  String? _whereILive;
  String? _sexPreferences;

  bool isUpdating = false;
  SanityImage? profileImage;

  String? _age;
  Height? _height = null;
  String? _weight;
  final AlertSnackbar _alertSnackbar = AlertSnackbar();

  Uint8List? theFileBytes;

  @override
  initState() {
    super.initState();
    widget.analyticsController
        ?.logScreenView('set-username-field-edit-profile');
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
  }

  @override
  didChangeDependencies() async {
    super.didChangeDependencies();

    var theAuthController = AuthInherited.of(context)?.authController;
    var theChatController = AuthInherited.of(context)?.chatController;
    var theUser = AuthInherited.of(context)?.authController?.myAppUser;
    var theClient = AuthInherited.of(context)?.chatController?.profileClient;

    if (theAuthController != null && authController == null) {
      authController = theAuthController;
    }
    if (theClient != null && apiClient == null) {
      apiClient = theClient;
    }

    if (theUser != null && _myAppUser == null) {
      _myAppUser = theUser;
      _displayName = theUser.displayName;
      _loginUsername = theUser.email;
      profileImage = theUser.profileImage;
      setState(() {});
    }

    if (theUser?.userId != null && extProfile == null) {
      var theProfile =
          await theChatController?.updateExtProfile((theUser?.userId)!);
      setStateFromExtProfile(theProfile);
    }
  }

  setStateFromExtProfile(ExtendedProfile? aUser) {
    setState(() {
      if (aUser != null) {
        extProfile = aUser;
        _shortBio = aUser.shortBio;
        _longBio = aUser.longBio;
        _age = aUser.age.toString();
        _height = aUser.height;
        _weight = aUser.weight.toString();
        _facebook = aUser.facebook;
        _twitter = aUser.twitter;
        _instagram = aUser.instagram;
        _facebook = aUser.facebook;
        _ethnicity = aUser.ethnicity;
        _iAm = aUser.iAm;
        _imInto = aUser.imInto;
        _imOpenTo = aUser.imOpenTo;
        _whatIDo = aUser.whatIDo;
        _whatImLookingFor = aUser.whatImLookingFor;
        _whatInterestsMe = aUser.whatInterestsMe;
        _whereILive = aUser.whereILive;
        _sexPreferences = aUser.sexPreferences;
      }
      isUpdating = false;
    });
  }

  Future<void> _updateProfile(context) async {
    setState(() {
      isUpdating = true;
    });
    try {
      var authUser = await authController?.updateUser(_loginUsername,
          _displayName, imageUploader.file?.name ?? "", theFileBytes, context);
      if (kDebugMode) {
        print("updated fields in authuser result: $authUser");

        print("id to create ${authUser?.uid}");
      }

      processLineNumber(String? number) {
        print("Linenumber is $number");

        if (number != null) {
          String theNumber = number;
          return int.parse(theNumber);
        }

        return null;
      }

      ExtendedProfile newProfile = ExtendedProfile(
        shortBio: _shortBio,
        height: _height,
        longBio: _longBio,
        age: _age != null ? int.parse(_age!) : null,
        weight: _weight != null ? int.parse(_weight!) : null,
        ethnicity: _ethnicity,
        facebook: _facebook,
       instagram: _instagram,
        twitter: _twitter,
        iAm: _iAm,
        imInto: _imInto,
        imOpenTo: _imOpenTo,
        whatIDo: _whatIDo,
        whatImLookingFor: _whatImLookingFor,
        whatInterestsMe: _whatInterestsMe,
        whereILive: _whereILive,
        sexPreferences: _sexPreferences,
      );

      if (kDebugMode) {
        print("parsed request from user form: $newProfile");
      }

      var aUser = await apiClient?.updateExtProfileChatUser(
          authUser?.uid ?? "", context, newProfile);
      if (kDebugMode) {
        print("updated extended profile $aUser");
      }

      setStateFromExtProfile(aUser);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
    _alertSnackbar.showSuccessAlert(
        "Profile Updated. Now get out there in crowd.", context);
    GoRouter.of(context).go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text(
            'Edit Profile',
          ),
          Flexible(
            child: ListView(
              children: [
                ListTile(
                  title: AppImageUploader(
                    height: 350,
                    width: 350,
                    image: SanityImageBuilder.imageProviderFor(
                            sanityImage: profileImage, showDefaultImage: true)
                        .image,
                    text: "Change Profile Photo",
                    imageUploader: imageUploader,
                    uploadImage: (theImageUploader) {
                      imageUploader = theImageUploader;
                      setState(() {});
                    },
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(_myAppUser),
                    initialValue: _loginUsername,
                    enabled: false,
                    setField: (e) {
                      setState(() {
                        _loginUsername = e;
                      });
                    },
                    labelText: 'E-mail',
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(_myAppUser),
                    initialValue: _displayName,
                    setField: (e) {
                      _displayName = e;
                    },
                    labelText: 'Display Name',
                  ),
                ),
                ListTile(
                  title: Row(
                    children: [
                      Flexible(
                        flex: 1,
                        child: TextFieldWrapped(
                          isNumberInput: true,
                          key: ObjectKey(_age),
                          initialValue: _age?.toString(),
                          setField: (e) {
                            if (e != null) {
                              _age = e;
                            }
                          },
                          labelText: "Age",
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      Flexible(
                        flex: 2,
                        child: TextFieldWrapped(
                          isNumberInput: true,
                          key: ObjectKey(extProfile),
                          initialValue: _weight,
                          setField: (e) {
                            if (e != null) {
                              _weight = e;
                            }
                          },
                          labelText: 'Weight',
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                  title: Flex(direction: Axis.horizontal, children: [
                    Flexible(
                      child: HeightInput(
                        key: ObjectKey(extProfile),
                        initialValue: _height,
                        updateHeight: (newFt, newIn) {
                          setState(() {
                            _height = Height.withValues(newFt, newIn);
                          });
                        },
                      ),
                    ),
                  ]),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _shortBio ?? "",
                    setField: (e) {
                      setState(() {
                        _shortBio = e;
                      });
                    },
                    labelText: "Short Bio",
                    minLines: 2,
                    maxLines: 4,
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _longBio ?? "",
                    setField: (e) {
                      setState(() {
                        _longBio = e;
                      });
                    },
                    minLines: 3,
                    maxLines: 5,
                    labelText: "Long Bio",
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _whereILive ?? "",
                    setField: (e) {
                      setState(() {
                        _whereILive = e;
                      });
                    },
                    minLines: 3,
                    maxLines: 5,
                    labelText: "Where I Live",
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _facebook ?? "",
                    setField: (e) {
                      setState(() {
                        _facebook = e;
                      });
                    },
                    labelText: "Facebook",
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _instagram ?? "",
                    setField: (e) {
                      setState(
                        () {
                          _instagram = e;
                        },
                      );
                    },
                    labelText: "Instagram",
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _twitter ?? "",
                    setField: (e) {
                      setState(
                        () {
                          _twitter = e;
                        },
                      );
                    },
                    labelText: "Twitter",
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _iAm ?? "",
                    setField: (e) {
                      setState(
                        () {
                          _iAm = e;
                        },
                      );
                    },
                    labelText: "I Am",
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _imOpenTo ?? "",
                    setField: (e) {
                      setState(
                        () {
                          _imOpenTo = e;
                        },
                      );
                    },
                    labelText: "I'm Open To",
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _whatImLookingFor ?? "",
                    setField: (e) {
                      setState(
                        () {
                          _whatImLookingFor = e;
                        },
                      );
                    },
                    labelText: "What I'm Looking For",
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _whatIDo ?? "",
                    setField: (e) {
                      setState(
                        () {
                          _whatIDo = e;
                        },
                      );
                    },
                    labelText: "What I do",
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _whatInterestsMe ?? "",
                    setField: (e) {
                      setState(
                        () {
                          _whatInterestsMe = e;
                        },
                      );
                    },
                    labelText: "What Interests Me",
                  ),
                ),
                ListTile(
                  title: TextFieldWrapped(
                    key: ObjectKey(extProfile),
                    initialValue: _sexPreferences ?? "",
                    setField: (e) {
                      setState(
                        () {
                          _sexPreferences = e;
                        },
                      );
                    },
                    labelText: "Sex Preferences",
                  ),
                ),
                ListTile(
                  title: DropdownInputWrapped(
                    value: _ethnicity ?? "",
                    choices: const [
                      "",
                      "Black",
                      "White",
                      "Asian",
                      "Latino",
                      "Other"
                    ],
                    label: "Ethnicity",
                    setValue: (e) {
                      setState(
                        () {
                          _ethnicity = e;
                        },
                      );
                    },
                  ),
                ),
                ListTile(
                  title: AnalyticsLoadingButton(
                    analyticsEventData: {
                      'username': _myAppUser?.email,
                      'height': (_height != null).toString(),
                      'weight': (_weight != null).toString(),
                      'age': (_age != null).toString(),
                      'short_bio': ((_shortBio?.length ?? 0) > 0).toString(),
                      'long_bio': ((_longBio?.length ?? 0) > 0).toString(),
                    },
                    analyticsEventName: 'settings-save-profile',
                    isDisabled: isUpdating,
                    action: (innerContext) async {
                      await _updateProfile(context);
                    },
                    text: "Save Profile",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
