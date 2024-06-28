import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'article_detail_screen.dart'; // Import the new screen

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter News API Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          bodyText1: TextStyle(fontFamily: 'Times New Roman'),
          bodyText2: TextStyle(fontFamily: 'Times New Roman', height: 1.5), // Adjust line spacing
          headline6: TextStyle(fontFamily: 'Times New Roman', fontSize: 20.0),
          headline5: TextStyle(fontFamily: 'Times New Roman', color: Colors.black, fontWeight: FontWeight.bold),
        ),
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
  int _currentPage = 1;
  int _totalPages = 1;
  final int _pageSize = 10;

  Future<void> fetchArticles() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final String apiKey = 'b1fda43027ad496c8d89f8df2d316b61'; // Replace with your API key
    final String url = 'https://newsapi.org/v2/top-headlines?country=us&pageSize=$_pageSize&page=$_currentPage&apiKey=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        setState(() {
          _articles = data['articles'];
          _totalPages = (data['totalResults'] / _pageSize).ceil();
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
  void initState() {
    super.initState();
    fetchArticles();
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
        fetchArticles();
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
        fetchArticles();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter News API Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: _isLoading
              ? CircularProgressIndicator()
              : _error.isNotEmpty
              ? Text(
            _error,
            style: Theme.of(context).textTheme.bodyText1,
          )
              : _articles.isEmpty
              ? Text(
            'No Data Loaded',
            style: Theme.of(context).textTheme.bodyText1,
          )
              : Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _articles.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        margin: EdgeInsets.zero,
                        elevation: 5,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ArticleDetailScreen(
                                  title: _articles[index]['title'],
                                  description: _articles[index]['description'] ?? 'No description available',
                                  content: _articles[index]['content'] ?? 'No content available',
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _articles[index]['title'],
                                  style: Theme.of(context).textTheme.headline5,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  _articles[index]['description'] ?? 'No description available',
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _currentPage > 1 ? _previousPage : null,
                    child: Text(
                      'Previous',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                  Text(
                    'Page $_currentPage of $_totalPages',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  ElevatedButton(
                    onPressed: _currentPage < _totalPages ? _nextPage : null,
                    child: Text(
                      'Next',
                      style: Theme.of(context).textTheme.bodyText1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 40.0),
        child: FloatingActionButton(
          onPressed: fetchArticles,
          tooltip: 'Fetch Articles',
          child: Icon(Icons.download),
        ),
      ),
    );
  }
}
