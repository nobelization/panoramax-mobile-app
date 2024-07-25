part of panoramax;

class SequenceCard extends StatefulWidget {
  const SequenceCard(this.sequence, {this.sequenceCount, super.key});

  final GeoVisioLink sequence;
  final int?
      sequenceCount; //if sequenceCount is not null, there are photos being uploaded

  @override
  State<StatefulWidget> createState() => _SequenceCardState();
}

class _SequenceCardState extends State<SequenceCard> {
  late int itemCount;
  GeoVisioCollectionImportStatus? geovisioStatus;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    itemCount = widget.sequence.stats_items!.count;
    if (widget.sequence.geovisio_status != "preparing" ||
        widget.sequenceCount != null) {
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        getStatus();
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> getStatus() async {
    GeoVisioCollectionImportStatus? geovisioStatusRefresh;
    try {
      geovisioStatusRefresh = await CollectionsApi.INSTANCE
          .getGeovisioStatus(collectionId: widget.sequence.id!);
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        geovisioStatus = geovisioStatusRefresh;
      });
    }
  }

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
          widget.sequence.geovisio_status == "ready" &&
                  widget.sequenceCount == null
              ? Picture()
              : Loader(),
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
                : Container(),
            widget.sequenceCount == null ||
                    widget.sequence.stats_items?.count == widget.sequenceCount
                ? Blurring()
                : Container()
          ],
        ));
  }

  Widget PictureCount() {
    final count =
        widget.sequenceCount == null ? itemCount : widget.sequenceCount;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$count ${AppLocalizations.of(context)!.pictures}',
          style: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        widget.sequence.geovisio_status == "ready" &&
                widget.sequenceCount == null
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
              widget.sequenceCount == null ||
                      geovisioStatus?.items.length == widget.sequenceCount
                  ? Icon(
                      Icons.check_circle_outline,
                      color: Colors.blue,
                      size: 60,
                    )
                  : CircularProgressIndicator(
                      strokeWidth: 4, // thickness of the circle
                      color: Colors.blue, // color of the progress bar
                    ),
              Text(widget.sequenceCount == null ||
                      geovisioStatus?.items.length == widget.sequenceCount
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

  Widget Blurring() {
    int count = geovisioStatus?.items
            .where(
              (element) => element.status == "ready",
            )
            .length ??
        0;
    double total = geovisioStatus?.items.length.toDouble() ?? 0;
    return Container(
        child: Column(
      children: [
        LinearProgressIndicator(
          value: (total == 0) ? 0 : count / total, //don't divide by 0 !
          semanticsLabel: AppLocalizations.of(context)!.blurringInProgress,
          minHeight: 16,
          borderRadius: BorderRadius.circular(8),
        ),
        Row(
          children: [
            const Icon(Icons.blur_on_outlined),
            Padding(
                padding: EdgeInsets.all(8),
                child: Text(AppLocalizations.of(context)!.blurringInProgress))
          ],
        )
      ],
    ));
  }
}
