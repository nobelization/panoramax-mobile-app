part of panoramax;

class GravityOrientationDetector {
  final StreamController<OrientationData> _streamController =
      StreamController<OrientationData>.broadcast();

  Stream<OrientationData> get orientationStream => _streamController.stream;
  late final StreamSubscription<AccelerometerEvent> subscription;

  void init() {
    subscription = accelerometerEvents.listen((AccelerometerEvent event) {
      final ax = event.x;
      final ay = event.y;
      final az = event.z;

      // Calculer la direction de la gravité
      final gx = ax / sqrt(ax * ax + ay * ay + az * az);
      final gy = ay / sqrt(ax * ax + ay * ay + az * az);
      final gz = az / sqrt(ax * ax + ay * ay + az * az);

      // Calculer les angles d'Euler
      final alpha = atan2(gy, gz);
      final beta = atan2(-gx, sqrt(gy * gy + gz * gz));
      final double gamma = 0;

      // Émettre les données d'orientation
      _streamController.add(OrientationData(alpha, beta, gamma));
    });
  }

  void dispose() {
    _streamController.close();
  }
}

class OrientationData {
  final double alpha;
  final double beta;
  final double gamma;

  OrientationData(this.alpha, this.beta, this.gamma);
}
