part of panoramax;

PreferredSizeWidget PanoramaxAppBar({context, title = "Panoramax"}) {
  return AppBar(
    backgroundColor: Theme.of(context).colorScheme.inversePrimary,
    title: Text(title),
  );
}