import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// void main() {
//   runApp(ChangeNotifierProvider(create: (_) => AppState(), child: App()));
// }

const List<String> urls = [
  "https://live.staticflickr.com/65535/50489498856_67fbe52703_b.jpg",
  "https://live.staticflickr.com/65535/50488789068_de551f0ba7_b.jpg",
  "https://live.staticflickr.com/65535/50488789118_247cc6c20a.jpg",
  "https://live.staticflickr.com/65535/50488789168_ff9f1f8809.jpg"
];

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Viewer',
      home: GalleryPage(title: "Image Gallery"),
    );
  }
}

class PhotoState {
  final String url;
  bool? selected = false;
  bool display = true;
  final Set<String> tags = {};

  PhotoState(this.url, {selected, display, tags});
}

class AppState with ChangeNotifier {
  bool isTagging = false;

  List<PhotoState> photoStates = List.of(urls.map((url) => PhotoState(url)));
  Set<String> tags = {"all", "nature", "cat"};

  void selectTag(String tag) {
    if (isTagging) {
      if (tag != "all") {
        photoStates.forEach((element) {
          if (element.selected == true) {
            element.tags.add(tag);
          }
        });
      }
      toggleTagging("");
    } else {
      photoStates.forEach((element) {
        element.display = tag == "all" ? true : element.tags.contains(tag);
      });
    }
    notifyListeners();
  }

  void toggleTagging(String url) {
    print("fire");
    isTagging = !isTagging;
    photoStates.forEach((element) {
      if (isTagging && element.url == url) {
        element.selected = true;
      } else {
        element.selected = false;
      }
    });
    notifyListeners();
  }

  void onPhotoSelect(String url, bool? selected) {
    photoStates.forEach((element) {
      if (element.url == url) {
        element.selected = selected;
      }
    });
    notifyListeners();
  }
}

class GalleryPage extends StatelessWidget {
  final String title;

  GalleryPage({required this.title});

  @override
  Widget build(BuildContext context) {
    AppState watch() {
      return context.watch<AppState>();
    }

    AppState read() {
      return context.read<AppState>();
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: GridView.count(
          primary: false,
          crossAxisCount: 2,
          children: List.of(
              watch().photoStates.where((ps) => ps.display).map((ps) => Photo(
                    state: ps,
                  )))),
      drawer: Drawer(
          child: ListView(
        children: List.of(watch().tags.map((t) => ListTile(
              title: Text(t),
              onTap: () {
                read().selectTag(t);
                Navigator.of(context).pop();
              },
            ))),
      )),
    );
  }
}

class Photo extends StatelessWidget {
  final PhotoState state;

  Photo({required this.state});

  @override
  Widget build(BuildContext context) {
    AppState watch() {
      return context.watch<AppState>();
    }

    AppState read() {
      return context.read<AppState>();
    }

    List<Widget> children = [
      GestureDetector(
          child: Image.network(state.url),
          onLongPress: () => read().toggleTagging(state.url))
    ];

    if (watch().isTagging) {
      children.add(Positioned(
          left: 20,
          top: 0,
          child: Theme(
              data: Theme.of(context)
                  .copyWith(unselectedWidgetColor: Colors.grey[200]),
              child: Checkbox(
                onChanged: (value) {
                  watch().onPhotoSelect(state.url, value);
                },
                value: state.selected,
                activeColor: Colors.white,
                checkColor: Colors.black,
              ))));
    }

    return Container(
        padding: EdgeInsets.only(top: 10),
        child: Stack(alignment: Alignment.center, children: children));
  }
}
