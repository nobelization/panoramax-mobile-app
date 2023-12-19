library panoramax.api;

import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'model/geo_visio.dart';

part 'endpoint/collections_api.dart';

const String API_HOSTNAME = '10.0.2.2:5000';
const bool API_IS_HTTPS = false;
