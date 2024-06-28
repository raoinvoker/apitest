import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NEWS API TEST ',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<dynamic> _articles = [];
  bool _isLoading = false;
  String _error = '';

  Future<void> fetchArticles() async { // function for fetching the data
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final String apiKey = 'b1fda43027ad496c8d89f8df2d316b61'; // Replace with your API key
    final String url = 'https://newsapi.org/v2/top-headlines?country=in&apiKey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _articles = data['articles'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Failed to load data: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Failed to load data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter News API Example'),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : _error.isNotEmpty
            ? Text(_error)
            : _articles.isEmpty
            ? Text('No Data Loaded')
            : ListView.builder(
          itemCount: _articles.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_articles[index]['title']),
              subtitle: Text(_articles[index]['description'] ?? 'No description available'),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchArticles,
        tooltip: 'Fetch Articles',
        child: Icon(Icons.download),
      ),
    );
  }
}
