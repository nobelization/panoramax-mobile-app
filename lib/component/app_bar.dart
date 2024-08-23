part of panoramax;

PreferredSizeWidget PanoramaxAppBar(
    {context, title = "Panoramax", backEnabled = true}) {
  return AppBar(
    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    title: Text(title),
    automaticallyImplyLeading: backEnabled,
  );
}
