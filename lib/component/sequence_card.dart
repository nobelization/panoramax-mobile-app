part of panoramax;

class SequenceCard extends StatelessWidget {
  final GeoVisioLink sequence;
  final GeoVisioCollectionImportStatus geovisioStatus;
  const SequenceCard(this.sequence, this.geovisioStatus, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10),
      height: 230,
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
          geovisioStatus.status == "ready"
              ? Container(
                  height: 140,
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                      image: DecorationImage(
                        image: Image.network(sequence.getThumbUrl()!).image,
                        fit: BoxFit.cover,
                      )))
              : Container(
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
                        geovisioStatus.status == "preparing"
                            ? Icon(
                                Icons.check_circle_outline,
                                color: Colors.blue,
                                size: 60,
                              )
                            : CircularProgressIndicator(
                                strokeWidth: 4, // thickness of the circle
                                color: Colors.blue, // color of the progress bar
                              ),
                        Text(geovisioStatus.status == "preparing"
                            ? AppLocalizations.of(context)!.sendingCompleted
                            : AppLocalizations.of(context)!.sendingInProgress)
                      ])))),
          Container(
            margin: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${geovisioStatus.items.length} ${AppLocalizations.of(context)!.element}',
                  style: GoogleFonts.nunito(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          /*Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${sequence.stats_items?.count} ${AppLocalizations.of(context)!.photo}',
                  style: GoogleFonts.nunito(
                    fontSize: 14,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w400,
                  ),
                )
              ],
            ),
          ),*/
          Container(
            margin: const EdgeInsets.fromLTRB(10, 3, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                    sequence.created != null
                        ? DateFormat(DATE_FORMATTER)
                            .format(DateTime.parse(sequence.created!))
                        : "",
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w400,
                    ))
              ],
            ),
          ),
        ],
      ),
    );
  }
}
