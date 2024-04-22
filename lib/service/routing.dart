part of panoramax;

/// The route configuration.
final GoRouter _router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const CapturePage();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'new-sequence/display',
          builder: (BuildContext context, GoRouterState state) {
            return const DisplaySequence();
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
  static const String newSequenceDisplay = "/new_sequence/display";
  static const String newSequenceCapture = "/new-sequence/capture";
  static const String newSequenceSend = "/new-sequence/send";

  @override
  List<Object?> get props => [newSequenceDisplay, newSequenceCapture, newSequenceSend];
}