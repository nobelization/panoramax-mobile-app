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
      setInstance(instance);
      url = "https://$instance/api/auth/login";
      isInstanceChosen = true;
    });
  }

  void getJWTToken() async {
    final instance = await getInstance();
    final cookies = await cookieManager.getCookies("https://$instance");

    var tokens = await AuthenticationApi.INSTANCE.apiTokensGet(cookies);
    var token =
        await AuthenticationApi.INSTANCE.apiTokenGet(tokens.id, cookies);

    setToken(token.jwt_token);

    GetIt.instance<NavigationService>()
        .pushTo(Routes.newSequenceUpload, arguments: widget.imgList);
  }

  void initState() {
    super.initState();
    getInstance().then((instance) async {
      final token = await getToken();
      if (instance.isNotEmpty && token != null) {
        GetIt.instance<NavigationService>()
            .pushTo(Routes.newSequenceUpload, arguments: widget.imgList);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(color: Colors.black),
        ),
        body: isInstanceChosen
            ? WebViewWidget(
                controller: WebViewController()
                  ..setJavaScriptMode(JavaScriptMode.unrestricted)
                  ..setNavigationDelegate(NavigationDelegate(
                    onNavigationRequest: (request) async {
                      bool shouldNavigate = true;
                      await getInstance().then((instance) {
                        if (request.url == "https://$instance/") {
                          getJWTToken();
                          shouldNavigate = false;
                        }
                      });
                      return shouldNavigate
                          ? NavigationDecision.navigate
                          : NavigationDecision.prevent;
                    },
                  ))
                  ..loadRequest(Uri.parse(url!)))
            : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(AppLocalizations.of(context)!.instanceShare,
                            style: GoogleFonts.nunito(
                                fontSize: 25, fontWeight: FontWeight.w400))),
                    CustomCard(
                        AppLocalizations.of(context)!.instanceOsmTitle,
                        AppLocalizations.of(context)!
                            .osmGeographicCoverageTitle,
                        AppLocalizations.of(context)!
                            .osmGeographicCoverageDescription,
                        AppLocalizations.of(context)!.osmLicenceTitle,
                        AppLocalizations.of(context)!.osmLicenceDescription,
                        "assets/OpenStreetMap.png",
                        "panoramax.openstreetmap.fr"),
                    CustomCard(
                        AppLocalizations.of(context)!.instanceIgnTitle,
                        AppLocalizations.of(context)!
                            .ignGeographicCoverageTitle,
                        AppLocalizations.of(context)!
                            .ignGeographicCoverageDescription,
                        AppLocalizations.of(context)!.ignLicenceTitle,
                        AppLocalizations.of(context)!.ignLicenceDescription,
                        "assets/ign.png",
                        "panoramax.ign.fr"),
                  ],
                )));
  }

  Widget CustomCard(
      String name,
      String geoTitle,
      String geoDescription,
      String licenceTitle,
      String licenceDescription,
      String img,
      String instance) {
    return Container(
        child: Card(
      // Set the shape of the card using a rounded rectangle border with a 8 pixel radius
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      // Set the clip behavior of the card
      clipBehavior: Clip.antiAliasWithSaveLayer,
      // Define the child widgets of the card
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
            child: Image.asset(
              img,
              height: 150,
              width: 150,
              fit: BoxFit.fitWidth,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Divider(
                  //color: Colors.black,
                  ),
              Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(
                  //color: Colors.black,
                  ),
              CustomRowInCard(Icons.public, geoTitle, geoDescription),
              Divider(
                  //color: Colors.black,
                  ),
              CustomRowInCard(Icons.copyright, licenceTitle, licenceDescription)
            ],
          ),
          Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.fromLTRB(0, 0, 16, 16),
              child: ElevatedButton(
                onPressed: () => authentication(instance),
                child: Text("Envoyer"),
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(BLUE),
                    foregroundColor: MaterialStateProperty.all(Colors.white)),
              ))
        ],
      ),
    ));
  }

  Widget CustomRowInCard(IconData icon, String title, String description) {
    return Container(
        padding: EdgeInsets.all(16),
        alignment: Alignment.topLeft,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            SizedBox(
              width: 8,
            ),
            Expanded(
                child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(description)
              ],
            ))
          ],
        ));
  }
}
