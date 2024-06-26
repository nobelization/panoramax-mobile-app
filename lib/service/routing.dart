part of panoramax;

class Routes extends Equatable {
  //static const String homepage = "/";
  static const String newSequenceCapture = "/";
  static const String newSequenceSend = "/new-sequence/send";
  static const String instance = "/instance";
  static const String newSequenceUpload = "/new-sequence/upload";

  @override
  List<Object?> get props => [
        //homepage,
        newSequenceCapture,
        newSequenceSend,
        instance,
        newSequenceUpload,
      ];
}

class NavigationService {
  final GlobalKey<NavigatorState> navigatorkey = GlobalKey<NavigatorState>();
  dynamic pushTo(String route, {dynamic arguments}) {
    return navigatorkey.currentState?.pushNamed(route, arguments: arguments);
  }

  dynamic pushReplacementTo(String route, {dynamic arguments}) {
    return navigatorkey.currentState
        ?.pushReplacementNamed(route, arguments: arguments);
  }

  dynamic goBack() {
    return navigatorkey.currentState?.pop();
  }
}

Route<dynamic> generateRoutes(RouteSettings settings) {
  switch (settings.name) {
    case "/":
      return MaterialPageRoute(builder: (_) => CapturePage());
    case "/new-sequence/send":
      return MaterialPageRoute(
          builder: (_) => CollectionCreationPage(
              imgList: settings.arguments as List<File>));
    case "/instance":
      return MaterialPageRoute(
          builder: (_) =>
              InstancePage(imgList: settings.arguments as List<File>));
    case "/new-sequence/upload":
      return MaterialPageRoute(
          builder: (_) =>
              UploadPicturesPage(imgList: settings.arguments as List<File>));
    default:
      return MaterialPageRoute(builder: (_) => HomePage());
  }
}
