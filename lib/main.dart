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
  int _currentPage = 1;
  int _totalPages = 1;
  final int _pageSize = 10; // each page is having 10 articles

  Future<Welcome> fetchArticles() async {
    final String apiKey = 'b1fda43027ad496c8d89f8df2d316b61'; // Replace with your API key
    final String url = 'https://newsapi.org/v2/top-headlines?country=us&pageSize=$_pageSize&page=$_currentPage&apiKey=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      return Welcome.fromJson(data);
    } else {
      throw Exception('Failed to load data: ${response.reasonPhrase}');
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() {
        _currentPage--;
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
        child: FutureBuilder<Welcome>(
          future: fetchArticles(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Failed to load data: ${snapshot.error}',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.articles.isEmpty) {
              return Center(
                child: Text(
                  'No Data Loaded',
                  style: Theme.of(context).textTheme.bodyText1,
                ),
              );
            }

            final articles = snapshot.data!.articles;
            _totalPages = (snapshot.data!.totalResults / _pageSize).ceil();

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      Article article = articles[index];
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
                                    title: article.title,
                                    description: article.description ?? 'No description available',
                                    content: article.content ?? 'No content available',
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
                                    article.title,
                                    style: Theme.of(context).textTheme.headline5,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    article.description ?? 'No description available',
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
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 120.0, left: 350),
        child: FloatingActionButton(
          onPressed: () {
            setState(() {});
          },
          tooltip: 'Fetch Articles',
          child: Icon(Icons.download),
        ),
      ),
    );
  }
}

class Welcome {
  String status;
  int totalResults;
  List<Article> articles;

  Welcome({
    required this.status,
    required this.totalResults,
    required this.articles,
  });

  factory Welcome.fromJson(Map<String, dynamic> json) {
    return Welcome(
      status: json['status'],
      totalResults: json['totalResults'],
      articles: List<Article>.from(json['articles'].map((x) => Article.fromJson(x))),
    );
  }
}

class Article {
  Source source;
  String? author;
  String title;
  String? description;
  String url;
  String? urlToImage;
  DateTime publishedAt;
  String? content;

  Article({
    required this.source,
    required this.author,
    required this.title,
    required this.description,
    required this.url,
    required this.urlToImage,
    required this.publishedAt,
    required this.content,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      source: Source.fromJson(json['source']),
      author: json['author'],
      title: json['title'],
      description: json['description'],
      url: json['url'],
      urlToImage: json['urlToImage'],
      publishedAt: DateTime.parse(json['publishedAt']),
      content: json['content'],
    );
  }
}

class Source {
  String? id;
  String? name;

  Source({
    required this.id,
    required this.name,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      id: json['id'],
      name: json['name'],
    );
  }
}
