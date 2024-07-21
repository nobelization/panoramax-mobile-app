part of panoramax;

class SequenceCard extends StatefulWidget {
  const SequenceCard(this.sequence, {super.key});

  final GeoVisioLink sequence;

  @override
  State<StatefulWidget> createState() => _SequenceCardState();
}

class _SequenceCardState extends State<SequenceCard> {
  late int itemCount;
  GeoVisioCollectionImportStatus? geovisioStatus;

  @override
  void initState() {
    super.initState();
    itemCount = widget.sequence.stats_items!.count;
    if (widget.sequence.geovisio_status != "preparing") {
      getStatus();
    }
  }

  Future<void> getStatus() async {}

  Future<void> openUrl() async {
    final instance = await getInstance();
    final Uri url =
        Uri.https("panoramax.$instance.fr", '/sequence/${widget.sequence.id}');
    if (!await launchUrl(url)) {
      throw Exception("Could not launch $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(
          Radius.circular(18),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            spreadRadius: 4,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          widget.sequence.geovisio_status == "ready" ? Picture() : Loader(),
          PictureDetail(),
        ],
      ),
    );
  }

  Widget PictureDetail() {
    return Container(
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Column(
          children: [
            PictureCount(),
            Shooting(),
            widget.sequence.geovisio_status == "ready"
                ? Publishing()
                : Container()
          ],
        ));
  }

  Widget PictureCount() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$itemCount ${AppLocalizations.of(context)!.pictures}',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        widget.sequence.geovisio_status == "ready"
            ? FloatingActionButton(
                onPressed: openUrl,
                child: Icon(
                  Icons.share,
                  //size: 14,
                ),
                shape: CircleBorder(),
                mini: true,
                backgroundColor: Colors.grey,
                tooltip: AppLocalizations.of(context)!.share)
            : Container(),
      ],
    );
  }

  Widget Shooting() {
    String? date = widget.sequence.extent?.temporal?.interval?[0]?[0];
    DateFormat dateFormat = DateFormat.yMMMd('fr_FR').add_Hm();
    return Row(
      children: [
        const Icon(Icons.photo_camera),
        Padding(
            padding: EdgeInsets.all(8),
            child: Text(AppLocalizations.of(context)!.shooting)),
        Spacer(),
        Text(date == null ? "" : dateFormat.format(DateTime.parse(date)))
      ],
    );
  }

  Widget Publishing() {
    DateFormat dateFormat = DateFormat.yMMMd('fr_FR').add_Hm();
    String? date = widget.sequence.created;
    return Row(
      children: [
        const Icon(Icons.cloud_upload),
        Padding(
            padding: EdgeInsets.all(8),
            child: Text(AppLocalizations.of(context)!.publishing)),
        Spacer(),
        Text(date == null ? "" : dateFormat.format(DateTime.parse(date)))
      ],
    );
  }

  Widget Loader() {
    return Container(
        height: 140,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
        ),
        child: Container(
            child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
              widget.sequence.geovisio_status == "preparing"
                  ? Icon(
                      Icons.check_circle_outline,
                      color: Colors.blue,
                      size: 60,
                    )
                  : CircularProgressIndicator(
                      strokeWidth: 4, // thickness of the circle
                      color: Colors.blue, // color of the progress bar
                    ),
              Text(widget.sequence.geovisio_status == "preparing"
                  ? AppLocalizations.of(context)!.sendingCompleted
                  : AppLocalizations.of(context)!.sendingInProgress)
            ]))));
  }

  Widget Picture() {
    return Container(
        height: 140,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            image: DecorationImage(
              image: Image.network(widget.sequence.getThumbUrl()!).image,
              fit: BoxFit.cover,
            )));
  }
}
