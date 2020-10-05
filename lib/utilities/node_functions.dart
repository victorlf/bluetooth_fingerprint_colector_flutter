class Device {
  final String _name;
  final String _address;
  final int _rssi;

  Device(this._name, this._address, this._rssi);

  String getName() {
    return this._name;
  }

  String getAddress() {
    return this._address;
  }

  int getRssi() {
    return this._rssi;
  }
}

class DeviceScanResult {
  final String _name;
  final String _address;
  final List<int> _rssiList;

  DeviceScanResult(this._name, this._address, this._rssiList);

  String getName() {
    return this._name;
  }

  String getAddress() {
    return this._address;
  }

  List<int> getRssiList() {
    return this._rssiList;
  }

  void setRssiList(int rssi) {
    this._rssiList.add(rssi);
  }
}

class Node {
  final String _name;
  final String _address;

  Node(this._name, this._address);

  String getName() {
    return this._name;
  }

  String getAddress() {
    return this._address;
  }
}
