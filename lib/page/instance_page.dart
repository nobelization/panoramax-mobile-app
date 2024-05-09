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
    var token =
        await AuthenticationApi.INSTANCE.apiTokenGet(tokenId: tokens.id);

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
            : Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("A qui voulez-vous envoyer vos photos ?"),
                    TextButton(
                        onPressed: () => {authentication("openstreetmap")},
                        child: /*const Text("OpenStreetMap")*/
                            cardButton("OpenStreetMap")),
                    TextButton(
                        onPressed: () => {authentication("ign")},
                        child: cardButton("ign"))
                  ],
                )));
  }

  Widget cardButton(String name) {
    return SizedBox(
        width: 300,
        child: Card(
          child: Column(children: [
            SizedBox(
                height: 80,
                child: Image(image: AssetImage("assets/$name.png"))),
            /*SvgPicture.asset("assets/osm_logo.svg",
            semanticsLabel: "openStreetMap logo"),*/
            Padding(
                padding: EdgeInsets.all(8),
                child: Text(name == "OpenStreetMap"
                    ? AppLocalizations.of(context)!.osmLicence
                    : AppLocalizations.of(context)!.ignLicence)),
          ]),
        ));
  }
}
