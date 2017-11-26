import 'dart:math' as math;

import 'package:angry_arrows/game/gesture.dart';

double angleBetween(Point a, Point b) {
  return (math.atan2(a.x - b.x, b.y - a.y) - math.PI / 2) % (2 * math.PI);
}

double distanceBetween(Point a, Point b) {
  return math.sqrt(math.pow(b.y - a.y, 2) + math.pow(b.x - a.x, 2));
}