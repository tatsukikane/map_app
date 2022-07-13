import 'dart:typed_data';

class Place {
  String? name;
  String? address;
  late List<Uint8List?> images;

  //コンストラクタ
  Place({required this.name, required this.address, required this.images});
}