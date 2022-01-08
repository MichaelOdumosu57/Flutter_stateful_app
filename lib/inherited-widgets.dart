import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

// void main() {
//   runApp(App());
// }

const List<String> urls = [
  "https://live.staticflickr.com/65535/50489498856_67fbe52703_b.jpg",
  "https://live.staticflickr.com/65535/50488789068_de551f0ba7_b.jpg",
  "https://live.staticflickr.com/65535/50488789118_247cc6c20a.jpg",
  "https://live.staticflickr.com/65535/50488789168_ff9f1f8809.jpg"
];

class App extends StatefulWidget {
  @override
  AppState createState() => AppState();
}

class PhotoState {
  final String url;
  bool? selected = false;
  bool display = true;
  final Set<String> tags = {};

  PhotoState(this.url, {selected, display, tags});
}

class AppState extends State<App> {
  bool isTagging = false;

  List<PhotoState> photoStates = List.of(urls.map((url) => PhotoState(url)));
  Set<String> tags = {"all", "nature", "cat"};

  void selectTag(String tag) {
    setState(() {
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
    });
  }

  void toggleTagging(String url) {
    setState(() {
      isTagging = !isTagging;
      photoStates.forEach((element) {
        if (isTagging && element.url == url) {
          element.selected = true;
        } else {
          element.selected = false;
        }
      });
    });
  }

  void onPhotoSelect(String url, bool? selected) {
    setState(() {
      photoStates.forEach((element) {
        if (element.url == url) {
          element.selected = selected;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Photo Viewer',
        home: MyInheritedWidget(
          model: this,
          child: Builder(builder: (BuildContext innerContext) {
            return GalleryPage(
                title: "Image Gallery",
                model: innerContext
                    .dependOnInheritedWidgetOfExactType<MyInheritedWidget>()!
                    .model);
          }),
        ));
  }
}

class GalleryPage extends StatelessWidget {
  final String title;
  final AppState model;

  GalleryPage({required this.title, required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(this.title)),
      body: GridView.count(
          primary: false,
          crossAxisCount: 2,
          children: List.of(model.photoStates
              .where((ps) => ps.display ?? true)
              .map((ps) => Photo(
                    state: ps,
                    model: model,
                  )))),
      drawer: Drawer(
          child: ListView(
        children: List.of(model.tags.map((t) => ListTile(
              title: Text(t),
              onTap: () {
                model.selectTag(t);
                Navigator.of(context).pop();
              },
            ))),
      )),
    );
  }
}

class Photo extends StatelessWidget {
  final PhotoState state;
  final AppState model;

  Photo({required this.state, required this.model});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      GestureDetector(
          child: Image.network(state.url),
          onLongPress: () => model.toggleTagging(state.url))
    ];

    if (model.isTagging) {
      children.add(Positioned(
          left: 20,
          top: 0,
          child: Theme(
              data: Theme.of(context)
                  .copyWith(unselectedWidgetColor: Colors.grey[200]),
              child: Checkbox(
                onChanged: (value) {
                  model.onPhotoSelect(state.url, value);
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

class MyInheritedWidget extends InheritedWidget {
  final AppState model;

  MyInheritedWidget(
      {/*required Key key,*/ required Widget child, required this.model})
      : super(/*key: key,*/ child: child);

  // static AppState of(BuildContext context) {
  //   return context
  //       .dependOnInheritedWidgetOfExactType<MyInheritedWidget>()!
  //       .model;
  // }

  @override
  bool updateShouldNotify(_) => true;
}
