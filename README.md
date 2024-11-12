# Paranomax Mobile App

## Environment
- [Git](https://git-scm.com/) or [Github desktop](https://desktop.github.com/download/)

## Prerequisites
- Dart
- Docker Engine For example [Docker install](https://docs.docker.com/engine/install/) or [Docker for Git](https://docker.courselabs.co/setup/)

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

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
