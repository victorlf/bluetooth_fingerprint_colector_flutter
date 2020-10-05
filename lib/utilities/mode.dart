import 'package:flutter/material.dart';

// Mode for the RSSI values
int mode(List<int> a, int size) {
  int maxValue = 0, maxCount = 0, i, j;

  for (i = 0; i < size; ++i) {
    int count = 0;
    for (j = 0; j < size; ++j) {
      if (a[j] == a[i]) ++count;
    }

    if (count > maxCount) {
      maxCount = count;
      maxValue = a[i];
    }
  }
  return maxValue;
}
