// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'dart:convert';

import 'package:cookowt/models/clients/api_client.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart'
    show kDebugMode;
import 'package:flutter/services.dart';
import 'package:package_info_plus_web/package_info_plus_web.dart';

class DefaultConfig {
  static String authBaseUrl = "";
  static String sanityDB = "";
  static String sanityProjectID = "";
  static String appName = "";
  static String packageName = "";
  static String version = "";
  static String apiVersion = "";
  static String apiSanityDB = "";
  static String buildNumber = "";
  static String apiStatus = "";

  static int homepagePostDurationSecs = 5;
  static int homepageProfileDurationSecs = 5;

  static String blankUrl = "";

  static ApiClient? _apiClient;

  static get client {
    return _apiClient;
  }

  static Future<void>? initializingConfig;

  static get theVersion {
    return version;
  }

  static get thebuildNumber {
    return buildNumber;
  }

  static get theApiVersion {
    return apiVersion;
  }

  static get theApiDb {
    return apiSanityDB;
  }

  static get theAuthBaseUrl {
    return authBaseUrl;
  }

  static get theApiStatus {
    return apiStatus;
  }

  static get theSanityDB {
    return sanityDB;
  }

  static get theSanityProjectID {
    return sanityProjectID;
  }

  static get theHomePagePostDurationSecs {
    return homepagePostDurationSecs;
  }

  static get theHomePageProfileDurationSecs {
    return homepageProfileDurationSecs;
  }

  _initializeConfig() async {
    print("API Status Check");

    print("Getting Package info");
    print("Initializing Remote Config");
    final remoteConfig = FirebaseRemoteConfig.instance;

    return remoteConfig
        .setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval:
            kDebugMode ? const Duration(hours: 1) : const Duration(minutes: 30),
      ),
    )
        .then((response) {
      print("Getting Remote Config");
      return remoteConfig.setDefaults(
        {
          "development": jsonEncode(
            {
              "sanityProjectId": "x",
              "sanityDB": "x",
              "blankUrl": "x",
              "authBaseUrl": "x",
              "homepageProfileDurationSecs": "x",
              "homepagePostDurationSecs": "x",
            },
          ),
          "production": jsonEncode(
            {
              "sanityProjectId": "x",
              "sanityDB": "x",
              "blankUrl": "x",
              "authBaseUrl": "x",
              "homepageProfileDurationSecs": "x",
              "homepagePostDurationSecs": "x",
            },
          ),
          "deployment": jsonEncode(
            {
              "sanityProjectId": "x",
              "sanityDB": "x",
              "blankUrl": "x",
              "authBaseUrl": "x",
              "homepageProfileDurationSecs": "x",
              "homepagePostDurationSecs": "x",
            },
          )
        },
      ).then((value) {
        print("Activating Remote Config");

        return remoteConfig.fetchAndActivate().then((isActivated) async {
          print("Activation Status: $isActivated");
          try {
            final FirebaseRemoteConfig remoteConfig =
                FirebaseRemoteConfig.instance;

            getMode() {
              print(" mode: $kDebugMode");
              return kDebugMode ? 'development' : 'production';
            }

            var rawData =
                jsonDecode(remoteConfig.getAll()[getMode()]?.asString() ?? "");

            if (rawData['authBaseUrl'] != null) {
              authBaseUrl = rawData['authBaseUrl'];
            }

            if (rawData['sanityDB'] != null) {
              sanityDB = rawData['sanityDB'];
            }

            if (rawData['sanityProjectId'] != null) {
              sanityProjectID = rawData['sanityProjectId'];
            }
            if (rawData['homepageProfileDurationSecs'] != null) {
              homepageProfileDurationSecs =
                  int.parse(rawData['homepageProfileDurationSecs']);
            }
            if (rawData['homepagePostDurationSecs'] != null) {
              homepagePostDurationSecs =
                  int.parse(rawData['homepagePostDurationSecs']);
            }

            // print("Config from remote: $authBaseUrl");
            var theClient = ApiClient(rawData['authBaseUrl']);
            _apiClient = theClient;
            var healthResponse = await theClient.healthCheck();
            // print("THe health response $healthResponse");
            apiVersion = healthResponse['apiVersion'];
            apiSanityDB = healthResponse['sanityDB'];
            apiStatus = healthResponse['status'];

            return PackageInfoPlugin().getAll().then((packageInfo) {
              print("retrieved Package Info $packageInfo");
              appName = packageInfo.appName;
              packageName = packageInfo.packageName;
              version = packageInfo.version;
              buildNumber = packageInfo.buildNumber;
            });
          } on PlatformException catch (exception) {
            print(exception);
// return 'Exception: $exception';
          } catch (exception) {
            print("Cant get remote config");
            print(exception);
// return 'Unable to fetch remote config. Cached or default values will be '
// 'used';
          }
        });
      });
    });
  }

  DefaultConfig() {
    initializingConfig = _initializeConfig();
  }
}

/// Global singleton instance
// final DefaultConfig cookowtAppConfig = DefaultConfig();
