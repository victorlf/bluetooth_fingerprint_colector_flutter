import 'dart:math';

// Dart only has natural log
double logBase(num x, num base) => log(x) / log(base);

double calculateDistanceModel1(int maxRssi) {
  //Total path loss = Tx-power minus RSSI
  int lTotal = -21 - maxRssi;
  // Depends on the frequency equals 2400MHz
  double log = logBase(2400, 10);
  double ld0 = 20 * log - 28;
  // Operations
  double lFinal = lTotal - ld0;
  // Depends on the same frequency and the environment
  int nForOffice = 30;
  // Operations
  lFinal = lFinal / nForOffice;
  // Final Operation for distance
  double distance = pow(10, lFinal);

  // Round the result
  distance = double.parse((distance).toStringAsFixed(2));

  return distance;
}

double calculateDifference(double realDistance, double calculatedDistance) {
  double diff = realDistance - calculatedDistance;
  diff = double.parse((diff).toStringAsFixed(2));
  return diff;
}
