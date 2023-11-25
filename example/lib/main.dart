import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:perf_view/perf_view.dart';

Future<Album> fetchAlbum(int idAlbum) async {
  final response = await http
      .get(Uri.parse('https://jsonplaceholder.typicode.com/albums/$idAlbum'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Album.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album');
  }
}

class Album {
  final int userId;
  final int id;
  final String title;

  const Album({
    required this.userId,
    required this.id,
    required this.title,
  });

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      userId: json['userId'] as int,
      id: json['id'] as int,
      title: json['title'] as String,
    );
  }
}

void main() {
  runApp(
    const PerformanceAnalyzerWidget(
      // disable: true,
      backgroundNetwork: Color(0xff0000ff),
      alignmentFPS: Alignment.bottomRight,
      alignmentMemory: Alignment.topLeft,
      alignmentNetwork: Alignment.center,
      activateMemory: false,
      // activateNetwork: false,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Performance Analyzer Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(title: 'Performance Analyzer Demo'),
        routes: {
          '/app2': (context) => AppTwo(),
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final List<int> theList = [];
  // String _platformVersion = 'Unknown';
  // List<Object?> _networkInfo = [];
  // final _perfViewPlugin = PerfView();
  // String _albumName = "";
  Album _album = const Album(
    userId: -1,
    id: -1,
    title: "",
  );

  void _makeRequest() async {
    final album = await fetchAlbum(_counter + 1);
    // print(album.title);
    setState(() {
      _album = album;
    });
  }

  void _incrementCounter() {
    _counter++;
    theList.add(_counter);
    setState(() {});
  }

  // @override
  // void initState() {
  //   super.initState();
  //   initPlatformState();
  //   updateNetworkInfo();
  // }

  // Platform messages are asynchronous, so we initialize in an async method.
  // Future<void> initPlatformState() async {
  //   String platformVersion;
  //   // Platform messages may fail, so we use a try/catch PlatformException.
  //   // We also handle the message potentially returning null.
  //   try {
  //     platformVersion = await _perfViewPlugin.getPlatformVersion() ??
  //         'Unknown platform version';
  //   } on PlatformException {
  //     platformVersion = 'Failed to get platform version.';
  //   }

  //   // If the widget was removed from the tree while the asynchronous platform
  //   // message was in flight, we want to discard the reply rather than calling
  //   // setState to update our non-existent appearance.
  //   if (!mounted) return;

  //   setState(() {
  //     _platformVersion = platformVersion;
  //   });
  // }

  // Future<void> getNetworkInfo() async {
  //   List<Object?> networkInfo;
  //   try {
  //     networkInfo = await _perfViewPlugin.getNetworkInfo("perf_view_example");
  //     // print("networkInfo: $networkInfo");
  //   } on PlatformException {
  //     networkInfo = <int>[-1, -1];
  //   }

  //   if (!mounted) return;

  //   setState(() {
  //     _networkInfo = networkInfo;
  //   });
  // }

  // void updateNetworkInfo() {
  //   getNetworkInfo();
  //   Future.delayed(const Duration(seconds: 2), () => updateNetworkInfo());
  // }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    theList.add(_counter);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'You have pushed the button this many times: ${theList.last}',
              ),
              Text(
                "\n\nAlbum title: \n ${_album.title}\n Album id: ${_album.id != -1 ? _album.id : ' '}\n",
                textAlign: TextAlign.center,
              ),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/app2'),
                child: const Text("Other app"),
              ),
              ElevatedButton(
                onPressed: _makeRequest,
                child: const Text("Make a http request"),
              ),
            ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AppTwo extends StatelessWidget {
  final List<String> items = List<String>.generate(1000000, (i) => 'Item $i');

  AppTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Performance Analyzer Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text('Performance Analyzer Demo'),
          ),
          body: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(items[index]),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.pop(context),
            tooltip: 'Back',
            child: const Icon(Icons.arrow_back),
          )),
    );
  }
}
