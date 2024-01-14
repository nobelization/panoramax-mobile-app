library panoramax;

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:panoramax_mobile/service/api/model/geo_visio.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'dart:ui';
import 'package:badges/badges.dart' as badges;
import 'package:permission_handler/permission_handler.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:loading_btn/loading_btn.dart';

import '../service/api/api.dart';

part 'component/app_bar.dart';
part 'component/collection_preview.dart';
part 'page/homepage.dart';
part 'page/capture_page.dart';
part 'page/collection_creation_page.dart';


final DateFormat DATE_FORMATTER = DateFormat.yMd();

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panoramax',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      home: const HomePage(),
    );
  }
}


