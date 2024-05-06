library panoramax;

import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter_exif_plugin/flutter_exif_plugin.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:panoramax_mobile/service/api/model/geo_visio.dart';
import 'package:intl/intl.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:badges/badges.dart' as badges;
import 'package:equatable/equatable.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:loading_btn/loading_btn.dart';
import 'package:get_it/get_it.dart';
import 'component/loader.dart';
import 'service/api/api.dart';
import 'constant.dart';

part 'component/app_bar.dart';
part 'component/collection_preview.dart';
part 'page/homepage.dart';
part 'page/capture_page.dart';
part 'page/collection_creation_page.dart';
part 'service/routing.dart';
part 'service/permission_helper.dart';


const String DATE_FORMATTER = 'dd/MM/y HH:mm:ss';

void main() {
  GetIt.instance.registerLazySingleton<NavigationService>(() => NavigationService());
  runApp(const PanoramaxApp());
}

class PanoramaxApp extends StatelessWidget {
  final String? selectedLocale;

  const PanoramaxApp({super.key, this.selectedLocale});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panoramax',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: DEFAULT_COLOR),
        useMaterial3: true,
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: getSupportedLocales,
      initialRoute: Routes.homepage,
      onGenerateRoute: generateRoutes,
      navigatorKey: GetIt.instance<NavigationService>().navigatorkey
    );
  }

  List<Locale> get getSupportedLocales {
    return this.selectedLocale != null ?
            [
              Locale(selectedLocale!),
            ]:
            const [
              Locale('en'),
              Locale('fr'),
            ];
  }
}


