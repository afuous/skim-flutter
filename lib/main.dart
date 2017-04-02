import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:ui' as Ui;
import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as Img;

void main() {
  runApp(new MyApp());
}

Future<String> httpGet(String url) {
  var completer = new Completer();
  new HttpClient().getUrl(Uri.parse(url))
    .then((request) {
      return request.close();
    })
    .then((response) {
      response.transform(new Utf8Decoder()).listen((contents) {
        completer.complete(contents);
      });
    });
  return completer.future;
}

Future<String> httpPost(String url) {
  var completer = new Completer();
  new HttpClient().postUrl(Uri.parse(url))
    .then((request) {
      request.write('this is a test message');
      return request.close();
    })
    .then((response) {
      response.transform(new Utf8Decoder()).listen((contents) {
        completer.complete(contents);
      });
    });
  return completer.future;
}

Future<String> apiCall(List<int> imageData) {
  var completer = new Completer();
  new HttpClient().postUrl(Uri.parse('https://westus.api.cognitive.microsoft.com/vision/v1.0/ocr?language=en'))
  // new HttpClient().postUrl(Uri.parse('http://thing.voidpigeon.com/'))
    .then((request) {
      request.headers.set('Content-Type', 'application/octet-stream');
      request.headers.set('Ocp-Apim-Subscription-Key', '5884f810a13346c2ae3b86912014cb02');
      imageData.forEach((chr) {
        request.writeCharCode(chr);
      });
      // request.write(ASCII.decode(imageData));
      return request.close();
    })
    .then((response) {
      response.transform(new Utf8Decoder()).reduce((a, b) => a + b).then((contents) {
        completer.complete(contents);
      });
    });
  return completer.future;
}

// Future<String> readFile(String path) {
//   return new File(path).readAsString();
// }

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Skim!',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Skim!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class Painter extends CustomPainter {
  Ui.Image img;
  Map data;
  String search;
  Painter(this.img, this.data, this.search);
  paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.red
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    // canvas.drawCircle(new Point(50.0, 50.0), 40.0, paint);
    if (img != null) {
      // Ui.Image image = await decodeImageFromList(await new File(file).readAsBytes());
      canvas.rotate(3.14159265358 / 2);
      double size = 525.0;
      canvas.drawImageRect(
        img,
        new Point(0.0, 0.0) & new Size(img.width + 0.0, img.height + 0.0),
        new Point(37.0, 148 - size * img.height / img.width) & new Size(size, size * img.height / img.width),
        paint
      );
      if (data != null && search != '') {
        for (var region in data["regions"]) {
          print(data);
          for (var line in region["lines"]) {
            for (var word in line["words"]) {
              if (word["text"].toLowerCase() == search.toLowerCase()) {
                var nums = word["boundingBox"].split(',').map(int.parse).toList();
                Rect rect = new Point(35 + nums[1] * size / img.width, 120 - nums[0] * size / img.width) & new Size(nums[3] * size / img.width, nums[2] * size / img.width);
                canvas.drawRect(rect, paint);
                print(word);
              }
            }
          }
        }
      }
    }
  }
  bool shouldRepaint(_) => true;
}

class _MyHomePageState extends State<MyHomePage> {

  // String _file = '';
  // Uint8List _bytes;
  Ui.Image _img;

  Map _data = null;

  InputValue _search = const InputValue();

  static const platform = const PlatformMethodChannel('samples.flutter.io/battery');

  // Canvas _canvas = new Canvas(new PictureRecorder(), const Point(0.0, 0.0) & const Size(100.0, 100.0));

  _incrementCounter() async {
    // _canvas.drawCircle(new Point(50.0, 50.0), 40.0, new Paint(color: const Color(0xFFFF0000)));
    var file = await platform.invokeMethod('takePicture');
    print(file);
    // setState(() {
      // _bytes = bytes;
      // _file = result;
    // });
    var bytes = await new File(file).readAsBytes();
    var img = await decodeImageFromList(bytes);
    setState(() {
      _img = img;
    });
    var newBytes = Img.encodeJpg(Img.copyResize(Img.decodeJpg(bytes), 1000), quality: 50);
    // await new File(file.substring(0, file.length - 4) + '-stuff' + file.substring(file.length - 4))
    //   .writeAsBytes(Img.encodeJpg(Img.copyResize(Img.decodeJpg(bytes), 1000), quality: 50), flush: true);
      // .writeAsBytes(Img.encodePng(Img.copyResize(Img.copyRotate(Img.decodeJpg(bytes), 90), 100)), flush: true);
      // .writeAsBytesSync(Img.encodeJpg(Img.copyRotate(Img.decodeImage(bytes), 90), quality: 50));
    // var str = await apiCall(Img.encodeJpg(Img.decodeImage(bytes), quality: 50));
    // await new Future.delayed(new Duration(seconds: 1));
    // var smallFile = file.substring(0, file.length - 4) + '-stuff' + file.substring(file.length - 4);
    // var str = await apiCall(newBytes);
    var str = await apiCall(bytes);
    print(str);
    Map map = JSON.decode(str);
    print(map);
    _data = map;
    // readFile(result).then((str) {
    //   _bytes = new Uint8List.fromList(str.codeUnits);
    //   decodeImageFromList(new Uint8List.fromList(str.codeUnits)).then((image) {
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(config.title),
      ),
      body: _img == null
        ? new Image.asset('images/Skim_03.png', fit: BoxFit.cover, height: 600.0)
        : new Column(
            children: [
              new CustomPaint(painter: new Painter(_img, _data, _search.text)),
              new Input(
                hintText: 'Search',
                value: _search,
                onChanged: (InputValue input) {
                  setState(() {
                    _search = input;
                  });
                },
              ),
            ],
          ),
        // : new Center(
        //     // child: new Image.file(new File(_file),
        //     child: new Image.file(new File(_file),
        //       // repeat: ImageRepeat.repeat,
        //       // centerSlice: const Point(0.0, 0.0) & const Size(600.0, 900.0),
        //       width: 200.0,
        //       height: 100.0,
        //     ),
        //   ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'New Image',
        child: new Icon(Icons.add_a_photo),
      ),
    );
  }
}
