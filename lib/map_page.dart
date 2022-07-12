import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPAge extends StatefulWidget {
  const MapPAge({Key? key}) : super(key: key);

  @override
  State<MapPAge> createState() => _MapPAgeState();
}

class _MapPAgeState extends State<MapPAge> {
  late GoogleMapController _controller;
  //初期位置の設定
  static const CameraPosition _initialPosition = CameraPosition(
    //緯度軽度で指定
    target: LatLng(35.6695409653854, 139.70297543992643),
    //zoom値(数値が大きい程アップになる)
    zoom: 16,
  );


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal, //表示するmapの種類の選択
        initialCameraPosition: _initialPosition,
        //map生成のタイミングでコントローラーを生成
        onMapCreated: (GoogleMapController controller){
          _controller = controller;
        }
      ),
    );
  }
}