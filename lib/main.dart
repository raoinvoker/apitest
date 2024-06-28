import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  fetchArticles();
}

Future<void> fetchArticles() async {
  final String apiKey = 'b1fda43027ad496c8d89f8df2d316b61'; // api
  final String url = 'https://newsapi.org/v2/top-headlines?country=in&apiKey=$apiKey';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      List<dynamic> articles = data['articles'];

      print('Fetched ${articles.length} articles:');
      for (var article in articles) {
        print('Title: ${article['title']}');
        print('Description: ${article['description']}');
        print('---');
      }
    } else {
      print('Failed to load data: ${response.reasonPhrase}');
    }
  } catch (e) {
    print('Failed to load data: $e');
  }
}
