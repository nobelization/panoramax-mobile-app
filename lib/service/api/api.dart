library panoramax.api;

import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'model/geo_visio.dart';
import 'dart:io';

part 'endpoint/collections_api.dart';

const String API_HOSTNAME = '192.168.1.12:5000';
const bool API_IS_HTTPS = false;
