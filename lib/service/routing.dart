part of panoramax;

class Routes extends Equatable {
  static const String homepage = "/";
  static const String newSequenceCapture = "/new-sequence/capture";
  static const String newSequenceSend = "/new-sequence/send";
  static const String instance = "/instance";

  @override
  List<Object?> get props => [homepage, newSequenceCapture, newSequenceSend, instance];
}

class NavigationService {
  final GlobalKey<NavigatorState> navigatorkey = GlobalKey<NavigatorState>();
  dynamic pushTo(String route, {dynamic arguments}) {
    return navigatorkey.currentState?.pushNamed(route, arguments: arguments);
  }

  dynamic goBack() {
    return navigatorkey.currentState?.pop();
  }
}

Route<dynamic> generateRoutes(RouteSettings settings) {
  switch (settings.name) {
    case "/":
      return MaterialPageRoute(builder: (_) => HomePage());
    case "/new-sequence/capture":
      return MaterialPageRoute(
          builder: (_) => CapturePage(
              cameras: settings.arguments as List<CameraDescription>));
    case "/new-sequence/send":
      return MaterialPageRoute(
          builder: (_) => CollectionCreationPage(
              imgList: settings.arguments as List<File>));
    case "/instance":
      return MaterialPageRoute(
          builder: (_) =>
              InstancePage(imgList: settings.arguments as List<File>));
    default:
      return MaterialPageRoute(builder: (_) => HomePage());
  }
}
