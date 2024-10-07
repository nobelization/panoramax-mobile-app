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
  SequenceState sequenceState = SequenceState.SENDING;
  MemoryImage? image;

  @override
  void initState() {
    super.initState();
    itemCount = widget.sequence.stats_items!.count;
    checkSequenceState();
    getImage();
    if ((sequenceState != SequenceState.READY &&
            sequenceState != SequenceState.HIDDEN) ||
        widget.sequenceCount != null) {
      timer = Timer.periodic(Duration(seconds: 5), (timer) {
        getStatus();
      });
    }
  }

  void getImage() async {
    MemoryImage? imageRefresh;
    try {
      imageRefresh = await CollectionsApi.INSTANCE
          .getThumbernail(collectionId: widget.sequence.id!);
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        image = imageRefresh;
      });
    }
  }

  void checkSequenceState() {
    int count = geovisioStatus?.items
            .where(
              (element) => element.status == "ready",
            )
            .length ??
        0;
    print("checkSequenceStat");
    setState(() {
      sequenceState = geovisioStatus?.status == "deleted"
          ? SequenceState.DELETED
          : widget.sequence.geovisio_status == "hidden"
              ? SequenceState.HIDDEN
              : widget.sequenceCount == null
                  ? widget.sequence.geovisio_status == "ready"
                      ? SequenceState.READY
                      : SequenceState.BLURRING
                  : widget.sequenceCount != geovisioStatus?.items.length
                      ? SequenceState.SENDING
                      : count == widget.sequenceCount
                          ? SequenceState.READY
                          : SequenceState.BLURRING;
    });
    if (sequenceState == SequenceState.DELETED) {
      timer?.cancel();
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
        checkSequenceState();
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

  Future<void> shareUrl() async {
    final instance = await getInstance();
    final url = "panoramax.$instance.fr/sequence/${widget.sequence.id}";
    await Share.share(url);
  }

  @override
  Widget build(BuildContext context) {
    return sequenceState == SequenceState.DELETED
        ? Container()
        : GestureDetector(
            onTap: openUrl,
            child: Container(
              margin: const EdgeInsets.all(10),
              width: double.infinity,
              decoration: BoxDecoration(
                color: sequenceState == SequenceState.HIDDEN
                    ? Colors.grey.shade400
                    : Colors.white,
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
              child: Column(children: [
                sequenceState == SequenceState.READY ||
                        sequenceState == SequenceState.HIDDEN
                    ? Picture()
                    : Loader(),
                PictureDetail(),
              ]),
            ));
  }

  Widget PictureDetail() {
    return Container(
        margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
        child: Column(
          children: [
            PictureCount(),
            Shooting(),
            sequenceState == SequenceState.READY ||
                    sequenceState == SequenceState.HIDDEN
                ? Publishing()
                : Container(),
            sequenceState == SequenceState.BLURRING ? Blurring() : Container()
          ],
        ));
  }

  Widget PictureCount() {
    final count =
        widget.sequenceCount == null ? itemCount : widget.sequenceCount;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(children: [
          Text(
            '$count ${AppLocalizations.of(context)!.pictures}',
            style: GoogleFonts.nunito(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ]),
        sequenceState == SequenceState.READY
            ? FloatingActionButton(
                onPressed: shareUrl,
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
              sequenceState == SequenceState.BLURRING
                  ? Icon(
                      Icons.check_circle_outline,
                      color: Colors.blue,
                      size: 60,
                    )
                  : CircularProgressIndicator(
                      strokeWidth: 4, // thickness of the circle
                      color: Colors.blue, // color of the progress bar
                    ),
              Text(sequenceState == SequenceState.BLURRING
                  ? AppLocalizations.of(context)!.sendingCompleted
                  : AppLocalizations.of(context)!.sendingInProgress)
            ]))));
  }

  Widget Picture() {
    return ClipRect(
      child: Stack(
        children: [
          if (image != null && image is MemoryImage)
            Container(
                height: 180,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                    image: DecorationImage(
                      image: image!,
                      fit: BoxFit.cover,
                    ))),
          if (sequenceState == SequenceState.HIDDEN)
            ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Colors.transparent,
                  height: 180,
                  width: double.infinity, // or a specific width
                ),
              ),
            ),
          if (sequenceState == SequenceState.HIDDEN)
            Container(
                height: 180,
                child: Center(
                    child: Text(
                  AppLocalizations.of(context)!.hidden,
                  style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                )))
        ],
      ),
    );
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

enum SequenceState { SENDING, BLURRING, READY, DELETED, HIDDEN }
