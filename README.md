<p align="center">
<img src="/assets/logo-mobile-app-beta.png" height="100"/>
</p>
<h1 align="center">Panoramax Mobile App</h1>

Panoramax mobile is an application to capture photo sequences with your mobile and send these sequences to a Panoramax instance.

> [!NOTE]
> The app is under development, a first version is available [here](https://github.com/nobelization/panoramax-mobile-app/releases/download/v1.2.1-beta/app-release-v1_2_1-beta.apk).

> You can follow progression in this [project](https://github.com/orgs/nobelization/projects/1).

<div align="center">
  <!--- <a href="https://f-droid.org/packages/app_id"> --->
    <img src="https://fdroid.gitlab.io/artwork/badge/get-it-on.png" alt="Get it on F-Droid" height="80" align="center"/>
  <!---</a>--->
  <!--- <a href="https://play.google.com/store/apps/app_id"> --->
    <img src='https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png' alt='Get it on Google Play' height="80" align="center"/>
  <!---</a>--->
  <!--- <a href="https://apps.apple.com/us/app/app_id"> --->
    <img src="assets/apple-appstore.svg" alt="Get it on App Store" height="60" align="center"/>
  <!---</a>--->
  <a href="https://github.com/nobelization/panoramax-mobile-app/releases/latest/">
    <img src="https://user-images.githubusercontent.com/663460/26973090-f8fdc986-4d14-11e7-995a-e7c5e79ed925.png" alt="Download app from GitHub" height="80" align="center"/>
  </a>
</div>

# Contribute to the code

## Prerequisites
- Dart
- Docker Engine

## Getting Started

This project is developed in Flutter.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/).
To submit PR on the project, use our [conventional commit](https://www.conventionalcommits.org/en/v1.0.0/)

### Start docker container
```shell
docker-compose up -d
```

### Redirect WSL port (Only for docker WSL)
```shell
netsh interface portproxy delete v4tov4 listenport=5000 listenaddress=0.0.0.0
netsh interface portproxy add v4tov4 listenport=5000 listenaddress=0.0.0.0 connectport=5000 connectaddress=<your-wsl-ip>
```
To retrieve <your-wsl-ip> execute the following command from your wsl machine :
```shell
ip add | grep "eth0
```

### Generate translation
```shell
flutter clean
flutter pub get
```

### Generate integration tests
```shell  
dart run build_runner build --delete-conflicting-outputs
```

```shell  
dart run build_runner watch --delete-conflicting-outputs
```

### Run integration tests
```shell  
flutter test integration_test
```

### Documentation

- [Panoramax website](https://panoramax.fr/)
- [Meta catalog](https://api.panoramax.xyz/)
- [Panoramax repository](https://gitlab.com/panoramax/)
- [Topic Panoramax on Forum](https://forum.geocommuns.fr/c/panoramax/6)

Licensed under the AGPL-3.0 license. See [LICENSE](/LICENSE)
