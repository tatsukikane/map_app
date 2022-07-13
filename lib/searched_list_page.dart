import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:map_app/place.dart';

class SearchedListPage extends StatefulWidget {
  const SearchedListPage({Key? key}) : super(key: key);

  @override
  State<SearchedListPage> createState() => _SearchedListPageState();
}

class _SearchedListPageState extends State<SearchedListPage> {
  //変数
  late GooglePlace googlePlace;
  List<AutocompletePrediction>? predictions = [];
  //検索結果を定義したPlaces型で保存する為の配列
  List<Place> places = [];


  //目的地のラトロンを検索する関数------------------------------------------
  Future<void> serchLatLng(String txt) async {
    //名称で検索した情報が resultに代入される
    final result = await googlePlace.autocomplete.get(txt);
    if(result != null) {
      //.predictionsで写真や住所とか色々な情報が得られる
      predictions = result.predictions;
      if(predictions != null) {
        print(predictions![0].description); //住所が取れる
        for(AutocompletePrediction prediction in predictions!){
          googlePlace.details.get(prediction.placeId!).then((value) async{
            //nullチェック
            if(value != null && value.result != null && value.result!.photos != null){
              //写真よう配列
              List<Uint8List> photos = [];
              await Future.forEach(value.result!.photos!, (element){
                //Photo型のphotoと言う変数に、elemetに入ってきた画像をPhoto型で代入
                Photo photo = element as Photo;
                googlePlace.photos.get(photo.photoReference!, 200, 200).then((value){
                  photos.add(value as Uint8List);
                });
              });
              setState(() {
                places.add(Place(
                  name: value.result!.name,
                  address: prediction.description,
                  images: photos
                ));
              });
              // print(value.result!.photos);
            }
          });

        }

      }
    }
    //locationFromAddressがパッケージの関数で渡した住所のラトロンを検索してくれる
    // List<Location> location = await locationFromAddress(address);
    // return CameraPosition(target: LatLng(location[0].latitude, location[0].longitude), zoom: 16);
  }
  //-----------------------------------------------------------
  //GooglePlaceを起動するみたいな感じ??
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    googlePlace = GooglePlace('AIzaSyAYSOL5KtvGEiwnns7RED5YPZPIxYE-VMQ');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.0, //浮き出ている感じ
        backgroundColor: Colors.white,

        title: SizedBox(
          height: 40,
          child: TextField(
            autofocus: true, //自動でテキストフィールドを選択している状態になる
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.only(left: 10),
            ),
            onSubmitted: (value) async{
              serchLatLng(value);
            },
          ),
        ),
      ),
      body: ListView.builder(
        //itemcountでLVbuilderで生成する個数を制御
        itemCount: places.length,
        itemBuilder: (context, index) {
          return ListTile(
            //検索結果の住所を表示
            title: Text(places[index].address ?? ''), //nullだったら何も表示させない ??でnullの場合の挙動をかける
            onTap: (){
              //選択した値を持って画面遷移
              Navigator.pop(context, places[index]);
            },

          );
      },),

    );
  }
  
  locationFromAddress(String address) {}
}