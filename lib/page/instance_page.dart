part of panoramax;

class InstancePage extends StatefulWidget {
  const InstancePage({required this.imgList, super.key});

  final List<File> imgList;

  @override
  State<StatefulWidget> createState() {
    return _InstanceState();
  }
}

class _InstanceState extends State<InstancePage> {
  late final WebViewController _controller;
  String? url;
  bool isInstanceChosen = false;
  final cookieManager = WebviewCookieManager();

  void authentication(String instance) {
    setState(() {
      API_HOSTNAME = "openstreetmap";
      url = "https://panoramax.${instance}.fr/api/auth/login";
      isInstanceChosen = true;
    });
  }

  void getToken() async {
    final cookies =
        await cookieManager.getCookies('https://panoramax.$API_HOSTNAME.fr');

    var tokens = await AuthenticationApi.INSTANCE.apiTokensGet(cookies);
    var token = await AuthenticationApi.INSTANCE
        .apiTokenGet(tokenId: tokens.id);

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('token', token.jwt_token);

    GetIt.instance<NavigationService>().pushTo(Routes.homepage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: isInstanceChosen
            ? WebViewWidget(
                controller: WebViewController()
                  ..setJavaScriptMode(JavaScriptMode.unrestricted)
                  ..setNavigationDelegate(NavigationDelegate(
                    onNavigationRequest: (request) {
                      if (request.url.contains(
                          "https://panoramax.$API_HOSTNAME.fr/api/auth/redirect")) {
                        getToken();
                      }
                      return NavigationDecision.navigate;
                    },
                  ))
                  ..loadRequest(Uri.parse(url!)))
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("A qui voulez-vous envoyer vos photos ?"),
                  TextButton(
                      onPressed: () => {authentication("openstreetmap")},
                      child: const Text("OpenStreetMap")),
                  TextButton(
                      onPressed: () => {authentication("ign")},
                      child: const Text("IGN"))
                ],
              ));
  }
}
