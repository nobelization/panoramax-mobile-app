// import 'dart:io';
//
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';
//
// import '../main.dart';
//
// class Routing {
//   static const String homepage = "/";
//   static const String newSequenceCapture = "/new-sequence/capture";
//   static const String newSequenceSend = "/new-sequence/send";
//
//   static Map<String, Widget Function(RouteSettings)> routeToWidgetMappings = {
//     homepage: (settings) => HomePage(),
//     newSequenceCapture: (settings) => CapturePage(cameras: settings.arguments as List<CameraDescription>),
//     newSequenceSend: (settings) => CollectionCreationPage(imgList: settings.arguments as List<File>),
//   };
//
//   static Widget getWidgetOfRoute(RouteSettings settings) {
//     final routeName = settings.name;
//     final widgetFunction = routeToWidgetMappings[routeName];
//     assert(
//     widgetFunction != null,
//     "No route to widget mapping found for route \"${settings.name}\", make sure you have registered the widget as you're adding a new route.",
//     );
//     return widgetFunction!(settings);
//   }
//
//   static PageRoute onGenerateRoute(RouteSettings settings) {
//     return MaterialPageRoute(
//       builder: (context) => getWidgetOfRoute(settings),
//       settings: settings,
//     );
//   }
// }
part of panoramax;

/// The route configuration.
final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const InstancePage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'user/instance',
          builder: (BuildContext context, GoRouterState state) {
            return const SequencePage();
          },
        ),
        GoRoute(
          path: 'new-sequence/capture',
          builder: (BuildContext context, GoRouterState state) {
            return CapturePage(cameras: state.extra as List<CameraDescription>);
          },
        ),
        GoRoute(
          path: 'new-sequence/send',
          builder: (BuildContext context, GoRouterState state) {
            return CollectionCreationPage(imgList: state.extra as List<File>);
          },
        ),
      ]
    ),
  ],
);

class Routes extends Equatable {
  static const String userInstance = "/user/instance";
  static const String newSequenceDisplay = "/";
  static const String newSequenceCapture = "/new-sequence/capture";
  static const String newSequenceSend = "/new-sequence/send";

  @override
  List<Object?> get props => [userInstance, newSequenceDisplay, newSequenceCapture, newSequenceSend];
}