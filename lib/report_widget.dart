import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:instant/instant.dart';
import 'response_widget.dart';

Future<Post> fetchPost() async {
  //var sheet = new DateTime.now().day + 1;
  final response =
      //await http.get('https://jsonplaceholder.typicode.com/posts/1');
      await http.get('https://spreadsheets.google.com/feeds/list/1IpmZM0CTu4Ju2vR9nNPbUOFKtJNHCO69ydEH9vAtxWI/1/public/values?alt=json');

  if (response.statusCode == 200) {
    // If the call to the server was successful, parse the JSON.
    return Post.fromJson(json.decode(response.body));
  } else {
    // If that call was not successful, throw an error.
    throw Exception('Failed to load post');
  }
}

class Post {
  Feed feed;
  Post({this.feed});
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      feed: Feed.fromJson(json['feed']),
    );
  }
}

class Feed {
  List<Entry> entries;

  Feed({this.entries});

  factory Feed.fromJson(Map<String, dynamic> json) {
    var list = json['entry'] as List;
    List<Entry> entryList = list.map((i) => Entry.fromJson(i)).toList();
    return Feed(
      entries: entryList,
    );
  }
}

class Entry {
  final Value timestamp;
  final Value pmfine;
  final Value humidity;
  final Value temperature;
  
  Entry({this.timestamp, this.pmfine, this.humidity, this.temperature});

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      timestamp: Value.fromJson(json['gsx\$timestamp']),
      pmfine: Value.fromJson(json['gsx\$pmfine']),
      humidity: Value.fromJson(json['gsx\$relativehumidity']),
      temperature: Value.fromJson(json['gsx\$temperaturec']),
    );
  }
}

class Value {
  String t;
  Value({this.t});

  factory Value.fromJson(Map<String, dynamic> json) {
    return Value(
      t: json['\$t'],
    );
  }
}

// Function to get the last data entry
ResponseWidget lastEntry(List<Entry> entryList) {
  var timestamp = DateFormat('yyyy-MM-dd').format(dateTimeToZone(zone: "EST", datetime: DateTime.now()));
  int i;
  for (i = entryList.length-1; i > 0; i--) {
    if (timestamp == entryList[i].timestamp.t.substring(0,10)) break;
  }
  print(entryList[i].timestamp.t);
  return ResponseWidget(entryList[i].timestamp.t, entryList[i].temperature.t, entryList[i].humidity.t, entryList[i].pmfine.t);
}

class ReportWidget extends StatefulWidget {
  ReportWidget({Key key}) : super(key: key);

  @override
  _ReportState createState() => _ReportState();
}

class _ReportState extends State<ReportWidget> {
  Future<Post> post;

  @override
  void initState() {
    super.initState();
    post = fetchPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //backgroundColor: Colors.lightBlueAccent,
        body: Container(
          child: FutureBuilder<Post>(
            future: post,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var timestamp = snapshot.data.feed.entries[0].timestamp.t;
                var temperature = snapshot.data.feed.entries[0].temperature.t;
                var humidity = snapshot.data.feed.entries[0].humidity.t;
                var pmfine = snapshot.data.feed.entries[0].pmfine.t;
                  return Column(
                    children: <Widget>[
                      //Text('Air Quality Report generated at ' + DateFormat('yyyy-MM-dd HH:mm:ss').format(new DateTime.now())),
                      Text('Air Quality Report', textAlign: TextAlign.center, style: TextStyle(fontSize: 28)),
                      Text('generated at ' + DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTimeToZone(zone: "EST", datetime: DateTime.now())) + " EST", textAlign: TextAlign.center, style:  TextStyle(fontSize: 15)),
                      lastEntry(snapshot.data.feed.entries),
                    ],
                  );
              } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
              }
              // By default, show a loading spinner.
              return Center(child: CircularProgressIndicator());
            },
          ),
        ),
      );
  }
}



