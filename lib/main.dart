import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
//import 'package:flutter/rendering.dart';
//ist<CameraDescription> cameras;
import 'dart:io';


Future<void> main() async {
  // プラグインの初期化
  WidgetsFlutterBinding.ensureInitialized();
  // 利用可能なカメラを選ぶ
  final cameras = await availableCameras();
  //カメラの指定
  final firstCamera = cameras.first;

  runApp(
    //アプリケーション全体の設定
    MaterialApp(
      theme: ThemeData.dark(), home: TakePictureScreen(
        // Pass the appropriate camera to the TakePictureScreen widget.
        camera: firstCamera,
      ),
    ),
  );
}

// カメラでとる。
class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;
  //画面のコンストラクタ
  const TakePictureScreen({ Key key, @required this.camera,}) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {

  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override//↓void Start
  void initState() {
    super.initState();
    // CameraControllerでカメラの表示
    _controller = CameraController(
      // 特定のカメラを取得
      widget.camera,
      // 解像度決める
      ResolutionPreset.medium,
    );
    //コントローラーのカメラを初期化
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('はあちゃまっちゃま〜')),
      // 画面の内容
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // カメラプレビューの表示
            return CameraPreview(_controller);
          } else {
            // ロード中はインジケーターを表示する。くるくる回るやつ
            return Center(child: CircularProgressIndicator());
          }
        },
      ),

      floatingActionButton: FloatingActionButton(

        child: Icon(Icons.camera, color: Colors.red),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
        //ボタンが押されたら
        onPressed: () async {
          // try,catchで写真を撮る処理
          try {
            //カメラの初期化を確認
            await _initializeControllerFuture;
            // 写真を撮って保存されたモノをimageに
            final image = await _controller.takePicture();
            //表示する画面に遷移
            Navigator.push(context,
              MaterialPageRoute(builder: (context) => DisplayPictureScreen(imagePath: image?.path,),
              ),
            );
          } catch (e) {
            // エラーが出た時の処理
            print(e);
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
          child: Container(height: 50.0),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
    );
  }
}

// 撮影した写真を表示するWidget
class DisplayPictureScreen extends StatelessWidget {
  //表示する画像パス
  final String imagePath;
  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //画面の作成パーツ
    return Scaffold(
      appBar: AppBar(title: Text('こんる〜じゅ')),
      //画像を表示
      body: Image.file(File(imagePath)),
    );
  }
}

