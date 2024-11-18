part of panoramax;

const TAG_INSTANCE = "instance";
const TAG_TOKEN = "token";

Future<String> getInstance() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  var instance = prefs.getString(TAG_INSTANCE);
  if (instance != null && !instance.contains("panoramax")) {
    prefs.remove(TAG_INSTANCE);
    instance = null;
  }
  return instance ?? "";
}

void setInstance(String instance) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(TAG_INSTANCE, instance);
}

Future<String?> getToken() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(TAG_TOKEN);
}

void setToken(String token) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(TAG_TOKEN, token);
}
