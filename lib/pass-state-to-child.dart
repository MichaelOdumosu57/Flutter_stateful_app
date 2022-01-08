import 'package:flutter/material.dart';

void main() {
  runApp(App());
}

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
  bool selected = false;
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
            if (element.selected) {
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

  void onPhotoSelect(String url, bool selected) {
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
        home: GalleryPage(
            title: "Image Gallery",
            photoStates: photoStates,
            tags: tags,
            tagging: isTagging,
            toggleTagging: toggleTagging,
            selectTag: selectTag,
            onPhotoSelect: onPhotoSelect));
  }
}

class GalleryPage extends StatelessWidget {
  final String title;
  final List<PhotoState> photoStates;
  final Set<String> tags;
  final bool tagging;

  final Function toggleTagging;
  final Function selectTag;
  final Function onPhotoSelect;

  GalleryPage(
      {required this.title,
      required this.photoStates,
      required this.tags,
      required this.tagging,
      required this.toggleTagging,
      required this.selectTag,
      required this.onPhotoSelect});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(this.title)),
      body: GridView.count(
          primary: false,
          crossAxisCount: 2,
          children: List.of(
              photoStates.where((ps) => ps.display ?? true).map((ps) => Photo(
                    state: ps,
                    selectable: tagging,
                    onLongPress: toggleTagging,
                    onSelect: onPhotoSelect,
                  )))),
      drawer: Drawer(
          child: ListView(
        children: List.of(tags.map((t) => ListTile(
              title: Text(t),
              onTap: () {
                selectTag(t);
                Navigator.of(context).pop();
              },
            ))),
      )),
    );
  }
}

class Photo extends StatelessWidget {
  final PhotoState state;
  final bool selectable;

  final Function onLongPress;
  final Function onSelect;

  Photo(
      {required this.state,
      required this.selectable,
      required this.onLongPress,
      required this.onSelect});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [
      GestureDetector(
          child: Image.network(state.url),
          onLongPress: () => onLongPress(state.url))
    ];

    if (selectable) {
      children.add(Positioned(
          left: 20,
          top: 0,
          child: Theme(
              data: Theme.of(context)
                  .copyWith(unselectedWidgetColor: Colors.grey[200]),
              child: Checkbox(
                onChanged: (value) {
                  onSelect(state.url, value);
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
