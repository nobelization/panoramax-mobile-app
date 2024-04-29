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
  void authentication(String instance) {
    String url = "https://panoramax.${instance}.fr/api/auth/login";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("A qui voulez-vous envoyer vos photos ?"),
        TextButton(
            onPressed: () => {authentication("openstreetmap")},
            child: Text("OpenStreetMap")),
        TextButton(onPressed: () => {authentication("ign")}, child: Text("IGN"))
      ],
    ));
  }
}
