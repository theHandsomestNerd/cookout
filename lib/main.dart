import 'dart:async';

import 'package:cookowt/pages/posts_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:cookowt/config/default_config.dart';
import 'package:cookowt/models/controllers/analytics_controller.dart';
import 'package:cookowt/models/controllers/auth_controller.dart';
import 'package:cookowt/models/controllers/chat_controller.dart';
import 'package:cookowt/models/controllers/geolocation_controller.dart';
import 'package:cookowt/models/controllers/post_controller.dart';
import 'package:cookowt/pages/chapter_roster_page.dart';
import 'package:cookowt/pages/hashtag_library_page.dart';
import 'package:cookowt/pages/hashtag_page.dart';
import 'package:cookowt/pages/home_page.dart';
import 'package:cookowt/pages/logout_page.dart';
import 'package:cookowt/pages/profiles_page.dart';
import 'package:cookowt/pages/register_page.dart';
import 'package:cookowt/pages/settings_page.dart';
import 'package:cookowt/pages/solo_post_page.dart';
import 'package:cookowt/pages/solo_profile_page.dart';
import 'package:cookowt/pages/splash_screen.dart';
import 'package:meta_seo/meta_seo.dart';

import 'config/firebase_options.dart';
import 'models/controllers/auth_inherited.dart';
import 'pages/login_page.dart';

// import '../../platform_dependent/image_uploader.dart'
//     if (dart.library.io) '../../platform_dependent/image_uploader_io.dart'
//     if (dart.library.html) '../../platform_dependent/image_uploader_html.dart';

Future<void> main() async {
  // await dotenv.load(mergeWith: Platform.environment, fileName: "assets/.env");
  // const _requiredEnvVars = const ['FIREBASE_PROJECT_ID', 'FIREBASE_APP_ID'];
  // bool get (hasEnv) => dotenv.isEveryDefined(_requiredEnvVars);

  // print("platform env vars${Platform.environment} ${dotenv.env}");
  usePathUrlStrategy();

  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // Ideal time to initialize
  if (kIsWeb) {
    MetaSEO().config();
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  DefaultConfig();
  await DefaultConfig.initializingConfig;

  if (kDebugMode) {
    //Emulator setup
    await FirebaseAuth.instance
        .useAuthEmulator('127.0.0.1', 9099); //Error is thrown here
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late GoRouter router = GoRouter(
    redirect: (BuildContext context, GoRouterState state) {
      // print("GO_ROUTER ${state.location} ${state.subloc}");
      if (state.location == '/register' || state.location == '/splash') {
        return null;
      }

      // if the user is not logged in, they need to login
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final loggingIn = state.location == '/login';

      // print("loggedIn ${loggedIn} loggingIn ${loggingIn}");

      if (!loggedIn) return loggingIn ? null : '/login';

      // if the user is logged in but still on the login page, send them to
      // the home page
      if (loggingIn) return '/home';

      // no need to redirect at all
      return null;
    },
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: '/logout',
        builder: (BuildContext context, GoRouterState state) {
          return const LogoutPage();
        },
      ),
      GoRoute(
        path: '/profilesPage',
        builder: (BuildContext context, GoRouterState state) {
          return ProfilesPage();
        },
      ),
      GoRoute(
        path: '/splash',
        builder: (BuildContext context, GoRouterState state) {
          return SplashPage();
        },
      ),
      GoRoute(
          path: '/home',
          builder: (BuildContext context, GoRouterState state) => HomePage()),
      GoRoute(
          path: '/postsPage',
          builder: (BuildContext context, GoRouterState state) => PostsPage()),
      GoRoute(
          path: '/hashtagCollections',
          builder: (BuildContext context, GoRouterState state) => HashtagLibraryPage()),
      // GoRoute(
      //     path: '/createPostsPage',
      //     builder: (BuildContext context, GoRouterState state) =>
      //         BugReporter(child: CreatePostPage())),
      GoRoute(
          path: '/register',
          builder: (BuildContext context, GoRouterState state) =>
              RegisterPage()),
      GoRoute(
          path: '/settings',
          builder: (BuildContext context, GoRouterState state) =>
              SettingsPage()),
      GoRoute(
          path: '/post/:id',
          builder: (BuildContext context, GoRouterState state) => SoloPostPage(
                thisPostId: state.pathParameters["id"],
              )),
      GoRoute(
          path: '/profile/:id',
          builder: (BuildContext context, GoRouterState state) {
            return SoloProfilePage(
              id: state.pathParameters["id"]!,
            );
          }),
      GoRoute(
          path: '/myProfile',
          builder: (BuildContext context, GoRouterState state) {
            return SoloProfilePage(
              id: FirebaseAuth.instance.currentUser?.uid ?? "",
            );
          }),
      GoRoute(
          path: '/hashtag/:id',
          builder: (BuildContext context, GoRouterState state) => HashtagPage(
                key: Key(state.pathParameters["id"]!),
                thisHashtagId: state.pathParameters["id"],
              )),

      GoRoute(
          path: '/chapterRoster',
          builder: (BuildContext context, GoRouterState state) =>
              const ChapterRosterPage()),
    ],
  );

  AuthController authController = AuthController.init();
  ChatController chatController = ChatController.init();
  PostController postController = PostController.init();
  AnalyticsController analyticsController = AnalyticsController.init();
  GeolocationController geolocationController = GeolocationController();

  // var myExtProfile = null;

  // static bool isUserLoggedIn = false;

  String appName = "";
  String packageName = "";
  String version = "";
  String apiVersion = "";
  String buildNumber = "";

  @override
  void initState() {
    super.initState();
    analyticsController.logOpenApp();

    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        if (kDebugMode) {
          print('postController: User is currently signed out!');
        }
      } else {
        if (kDebugMode) {
          print('postController: User is signed in!');
        }
        analyticsController.logLogin();
        analyticsController.setUserId(user.uid);
      }
    });
  }

  @override
  void dispose() {
    geolocationController.dispose();
    super.dispose();
  }

  String id = "";

  @override
  void didChangeDependencies() async {
    var theAppVersion = DefaultConfig.version;

    appName = DefaultConfig.appName;
    packageName = DefaultConfig.packageName;
    version = theAppVersion;
    apiVersion = DefaultConfig.apiVersion;
    buildNumber = DefaultConfig.buildNumber;
    // if (kDebugMode) {
    //   print(
    //       "UI Version: ${DefaultConfig.version}.${DefaultConfig.buildNumber}");
    //   print("appName: ${DefaultConfig.appName}");
    //   print("packageName: ${DefaultConfig.packageName}");
    // }

    setState(() {});
    super.didChangeDependencies();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AuthInherited(
      apiVersion: apiVersion,
      appName: appName,
      packageName: packageName,
      version: version,
      buildNumber: buildNumber,
      analyticsController: analyticsController,
      geolocationController: geolocationController,
      authController: authController,
      chatController: chatController,
      postController: postController,
      myLoggedInUser: authController.loggedInUser,
      profileImage: authController.myAppUser?.profileImage,
      child: MaterialApp.router(
        routeInformationProvider: router.routeInformationProvider,
        routeInformationParser: router.routeInformationParser,
        routerDelegate: router.routerDelegate,
        title: 'Cookowt',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch(
            primarySwatch: Colors.red,
            brightness: Brightness.light,
            accentColor: Colors.black,
          ),
          primaryColor: Colors.red,
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          textTheme: const TextTheme(
            displayLarge:
                TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
            titleLarge: TextStyle(fontSize: 36.0),
            titleSmall: TextStyle(fontSize: 22.0),
            bodyLarge: TextStyle(fontSize: 18.0, fontFamily: 'Hind'),
            bodyMedium: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
          ),
          // primarySwatch: Colors.grey,
        ),
      ),
    );
  }
}
