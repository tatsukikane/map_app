import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_app/place.dart';
import 'package:map_app/searched_list_page.dart';

class MapPAge extends StatefulWidget {
  const MapPAge({Key? key}) : super(key: key);

  @override
  State<MapPAge> createState() => _MapPAgeState();
}

class _MapPAgeState extends State<MapPAge> {
  late GoogleMapController _controller;
  //検索結果を表示しておくためのtxt用のコントローラー
  final TextEditingController _txtController = TextEditingController();
  //距離を入れておく変数
  String? distance = '0.0';
  //初期位置の設定
  static const CameraPosition _initialPosition = CameraPosition(
    //緯度軽度で指定
    target: LatLng(35.6695409653854, 139.70297543992643),
    //zoom値(数値が大きい程アップになる)
    zoom: 16,
  );
  //エラーメッセージ変数
  String? errorTxt;
  //検索画面からの情報を受け取る
  Place? searchedPlace;

  //現在位置の取得-----------------------------------
  //現在位置の取得変数
  late final CameraPosition currentPosition;
  //現在位置の取得メソッド(関数)
  Future<void> getCurrentPosition()async{
    //位置情報取得の権限の確認
    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      //拒否されていた場合
      //位置情報取得権限のリクエストを送る
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied){
        //それでも拒否されていた場合
        return Future.error('現在地の取得はできません。');
      }
    }
    //現在地を変数に代入
    final Position _currentPosition = await Geolocator.getCurrentPosition();
    //最初に定義したcurrentPositionにCameraPosition型で、取得したラトロンを代入
    currentPosition = CameraPosition(target: LatLng(_currentPosition.latitude, _currentPosition.longitude), zoom: 16);
  }
  //---------------------------------------------------------

  //pin------------------------------------------------------
  //pin用変数 Markerオブジェクトを返す set型
  //この中にpinを追加していくことができる
  final Set<Marker> _markers = {
    // const Marker(
    //   markerId: MarkerId('1'),
    //   position: LatLng(35.6695409653854, 139.70297543992643),
    //   //pinをタップした時の表示
    //   infoWindow: InfoWindow(title: 'じーず', snippet: 'おいでませ')
    // ),
    // const Marker(
    //   markerId: MarkerId('2'),
    //   position: LatLng(35.670623135039115, 139.7030526687628),
    //   infoWindow: InfoWindow(title: 'いけあ', snippet: '色々売ってるよ'),
    // ),
  };
  //-----------------------------------------------------------

  //目的地のラトロンを検索する関数------------------------------------------
  Future<CameraPosition> serchLatLng(String address) async {
    //locationFromAddressがパッケージの関数で渡した住所のラトロンを検索してくれる
    List<Location> location = await locationFromAddress(address);
    return CameraPosition(target: LatLng(location[0].latitude, location[0].longitude), zoom: 16);
  }
  //-----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.search, color: Colors.black,),
        elevation: 0.0,
        backgroundColor: Colors.white,
        //入力欄
        title: SizedBox(
          height: 40,
          child: TextField(
            controller: _txtController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.only(left: 10)
            ),
            onTap: () async{
              //画面遷移
              //popで送られてきた値をresultに代入
              Place? result = await Navigator.push(context, MaterialPageRoute(builder: (context) => SearchedListPage()));
              setState(() {
                searchedPlace = result;
              });
              if(searchedPlace != null){
                _txtController.text = searchedPlace!.name!;
                CameraPosition searchedPosition = await serchLatLng(searchedPlace!.address ?? '');
                setState(() {
                  _markers.add(Marker(
                    markerId: MarkerId('2'),
                    position: searchedPosition.target,
                    infoWindow: InfoWindow(title: '検索結果')
                  ));
                });
                //カメラ位置の変更
                _controller.animateCamera(CameraUpdate.newCameraPosition(searchedPosition));
                //Geolocatorの距離を計測するメソッド 開始と終了の緯度けいどを計測
                double _distance = Geolocator.distanceBetween(
                  //現在位置
                  currentPosition.target.latitude, currentPosition.target.longitude,
                  //目的地
                  searchedPosition.target.latitude, searchedPosition.target.longitude
                );
                //toStringAsFixedで小数点1桁に変更
                distance = (_distance / 1000).toStringAsFixed(1);
              }
            },
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            //エラーメッセージ表示
            errorTxt == null ? Container() : Text(errorTxt!),
            //検索結果がnullだったら何も表示しない。
            searchedPlace == null ? Container() : SizedBox(
              height: 100,
              //写真の表示
              child: ListView.builder(
                //listviewを横スクロールに変更
                scrollDirection: Axis.horizontal,
                itemCount: searchedPlace!.images.length,
                itemBuilder: (context, index) {
                //Uint8List型の時は、Image.memoryを使う
                return Image.memory(searchedPlace!.images[index]!);
               },
              ),
            ),
            //map欄
            Expanded(
              child: GoogleMap(
                mapType: MapType.normal, //表示するmapの種類の選択
                initialCameraPosition: _initialPosition,
                //map生成のタイミングでコントローラーを生成
                onMapCreated: (GoogleMapController controller) async{
                  //mapが生成されたタイミングでawaitして現在位置取得の関数実行 
                  await getCurrentPosition();
                  _controller = controller;
                  //カメラ位置の移動 取得した現在位置へ
                  _controller.animateCamera(CameraUpdate.newCameraPosition(currentPosition));
                  //setStateで再描画
                  // setState(() {
                  // //現在位置へのpinの描画
                  //   _markers.add(Marker(
                  //     markerId: MarkerId('3'),
                  //     position: currentPosition.target, //現在位置のラトロン
                  //     infoWindow: InfoWindow(title: '現在位置'),
                  //   ));
                  // });
                },
                //pinの描画
                markers: _markers,
                //右下のボタンを押したときに現在位置の戻る(デフォはfalse)
                myLocationEnabled: true,
                //右下のボタンの非表示(デフォはtrueになってる)
                //myLocationButtonEnabled: false,
              ),
            ),
            Text(
              '検索地までの距離は' + distance! + 'kmです',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ),
      ),
    );
  }
}