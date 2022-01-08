import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

const List<String> urls = [
  "https://live.staticflickr.com/65535/50489498856_67fbe52703_b.jpg",
  "https://live.staticflickr.com/65535/50488789068_de551f0ba7_b.jpg",
  "https://live.staticflickr.com/65535/50488789118_247cc6c20a.jpg",
  "https://live.staticflickr.com/65535/50488789168_ff9f1f8809.jpg"
];

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Viewer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: GalleryPage(title: "Image Gallery", urls: urls),
    );
  }
}

class GalleryPage extends StatelessWidget {
  final String title;
  final List<String> urls;

  GalleryPage({required this.title, required this.urls});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: GridView.count(
            primary: false,
            crossAxisCount: 2,
            children: List.of(urls.map((url) => TogglePhoto(url: url)))));
  }
}

class MyPhoto extends StatelessWidget {
  final String url;

  MyPhoto({required this.url});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 10), child: Image.network(url));
  }
}

class TogglePhoto extends StatefulWidget {
  final String url;

  TogglePhoto({required this.url});

  @override
  TogglePhotoState createState() => TogglePhotoState(url: this.url);
}

class TogglePhotoState extends State<TogglePhoto> {
  String url;
  int index = 0;

  TogglePhotoState({required this.url});

  onTap() {
    setState(() {
      index >= urls.length - 1 ? index = 0 : index++;
    });
    url = urls[index];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(top: 10),
        child: GestureDetector(
          child: Image.network(url),
          onTap: onTap,
        ));
  }
}
