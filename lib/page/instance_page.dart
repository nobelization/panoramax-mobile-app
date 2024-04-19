part of panoramax;

class InstancePage extends StatefulWidget {
  const InstancePage({super.key});

  @override
  State<InstancePage> createState() => _InstancePageState();
}

class _InstancePageState extends State<InstancePage> {
  void _choiceInstance() async {
    try {
      print("toto");
      final result = await FlutterWebAuth2.authenticate(
          url: 'https://panoramax.openstreetmap.fr/api/auth/login',
          callbackUrlScheme: "https");
      print(result);
    } on PlatformException catch (err) {
      print(err.code);
    } catch (err) {
      print(err.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PanoramaxAppBar(context: context),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          //crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
                "Veuillez choisir l'instance à laquelle vous souhaitez contribuer"),
            ElevatedButton(
                onPressed: _choiceInstance,
                child: Image.asset('assets/osmfr.png')),
            ElevatedButton(
                onPressed: _choiceInstance,
                child: Image.asset('assets/logo_ign.png')),
          ],
        ));
  }
}
