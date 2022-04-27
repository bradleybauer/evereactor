import 'dart:convert';

import 'package:http/http.dart';

class Order {
  final int typeID;
  final int systemID;
  final int regionID;
  final bool isBuy;
  final double price;
  final int volumeRemaining;

  Order(this.typeID, this.systemID, this.regionID, this.isBuy, this.price, this.volumeRemaining);

  // static Order fromRequest(Response response, int region) {
  // }
}
