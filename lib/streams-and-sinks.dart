import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  AppState state = AppState();
  runApp(App(state: state));
}

const List<String> urls = [
  "https://live.staticflickr.com/65535/50489498856_67fbe52703_b.jpg",
  "https://live.staticflickr.com/65535/50488789068_de551f0ba7_b.jpg",
  "https://live.staticflickr.com/65535/50488789118_247cc6c20a.jpg",
  "https://live.staticflickr.com/65535/50488789168_ff9f1f8809.jpg"
];

class App extends StatelessWidget {
  final AppState state;

  App({required this.state});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Photo Viewer',
      home: GalleryPage(title: "Image Gallery", state: state),
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

class AppState {
  bool _isTagging = false;
  final List<PhotoState> _photoStates =
      List.of(urls.map((url) => PhotoState(url)));
  final Set<String> _tags = {"all", "nature", "cat"};

  final StreamController<bool> _taggingController =
      StreamController.broadcast();
  final StreamController<List<PhotoState>> _photoStatesController =
      StreamController.broadcast();

  Stream<bool> get isTagging => _taggingController.stream;
  Stream<List<PhotoState>> get photoStates => _photoStatesController.stream;

  AppState() {
    _photoStatesController.onListen = () {
      _photoStatesController.add(_photoStates);
    };
    _taggingController.onListen = () {
      _taggingController.add(_isTagging);
    };
  }

  void selectTag(String tag) {
    if (_isTagging) {
      if (tag != "all") {
        _photoStates.forEach((element) {
          if (element.selected == true) {
            element.tags.add(tag);
          }
        });
      }
      toggleTagging("");
    } else {
      _photoStates.forEach((element) {
        element.display = tag == "all" ? true : element.tags.contains(tag);
      });
    }
    _taggingController.add(_isTagging);
    _photoStatesController.add(_photoStates);
  }

  void toggleTagging(String url) {
    print("fire");
    _isTagging = !_isTagging;
    _photoStates.forEach((element) {
      if (_isTagging && element.url == url) {
        element.selected = true;
      } else {
        element.selected = false;
      }
    });
    _taggingController.add(_isTagging);
    _photoStatesController.add(_photoStates);
  }

  void onPhotoSelect(String url, bool? selected) {
    _photoStates.forEach((element) {
      if (element.url == url) {
        element.selected = selected;
      }
    });
    _taggingController.add(_isTagging);
    _photoStatesController.add(_photoStates);
  }
}

class GalleryPage extends StatelessWidget {
  final String title;
  final AppState state;

  GalleryPage({required this.title, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: StreamBuilder<List<PhotoState>>(
          initialData: const [],
          stream: state.photoStates,
          builder: (context, snapshot) {
            return GridView.count(
                primary: false,
                crossAxisCount: 2,
                children: List.of(
                    snapshot.data!.where((ps) => ps.display).map((ps) => Photo(
                          state: ps,
                          appState: state,
                        ))));
          }),
      drawer: Drawer(
          child: ListView(
        children: List.of(state._tags.map((t) => ListTile(
              title: Text(t),
              onTap: () {
                state.selectTag(t);
                Navigator.of(context).pop();
              },
            ))),
      )),
    );
  }
}

class Photo extends StatelessWidget {
  final PhotoState state;
  final AppState appState;

  Photo({required this.state, required this.appState});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        initialData: false,
        stream: appState.isTagging,
        builder: (context, snapshot) {
          List<Widget> children = [
            GestureDetector(
                child: Image.network(state.url),
                onLongPress: () => appState.toggleTagging(state.url))
          ];

          if (snapshot.data ?? false) {
            children.add(Positioned(
                left: 20,
                top: 0,
                child: Theme(
                    data: Theme.of(context)
                        .copyWith(unselectedWidgetColor: Colors.grey[200]),
                    child: Checkbox(
                      onChanged: (value) {
                        appState.onPhotoSelect(state.url, value);
                      },
                      value: state.selected,
                      activeColor: Colors.white,
                      checkColor: Colors.black,
                    ))));
          }

          return Container(
              padding: EdgeInsets.only(top: 10),
              child: Stack(alignment: Alignment.center, children: children));
        });
  }
}
