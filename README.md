# Paranomax Mobile App

## Prerequisites
- Dart
- Docker Engine

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
netsh interface portproxy add v4tov4 listenport=5000 listenaddress=0.0.0.0 connectport=5000 connectaddress=<your-wsl-ip>
```
To retrieve <your-wsl-ip> execute the following command from your wsl machine :
```shell
ip add | grep "eth0
```

### Generating translation
```shell
flutter clean
flutter pub get
```