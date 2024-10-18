import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/article.dart';
import 'dart:convert';

class NewsController extends GetxController {
  var articles = <Article>[].obs;
  var isLoading = true.obs;
  var selectedSource = ''.obs;
  var fromDate = ''.obs;
  var toDate = ''.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;

  final String apiKey = 'a6fa75f6990a456e920d15012e86dafa';
  final String apiUrl =
      'https://newsapi.org/v2/everything?q=flutter&pageSize=10';

  @override
  void onInit() {
    super.onInit();
    loadCachedArticles();
    fetchArticles();
  }

  Future<void> loadCachedArticles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedArticles = prefs.getString('cachedArticles');
    if (cachedArticles != null) {
      List<dynamic> articlesJson = jsonDecode(cachedArticles);
      articles.value = articlesJson
          .map((jsonString) => Article.fromJson(jsonDecode(jsonString)))
          .toList();
    }
  }

  Future<void> cacheArticles(List<Article> articlesList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> articlesJson =
        articlesList.map((article) => jsonEncode(article.toJson())).toList();
    await prefs.setString('cachedArticles', jsonEncode(articlesJson));
  }

  void fetchArticles() async {
    isLoading(true);
    try {
      var dio = Dio();
      var url = '$apiUrl&page=$currentPage&apiKey=$apiKey';

      // Add filters to the URL if applicable
      if (selectedSource.isNotEmpty) {
        url += '&sources=${selectedSource.value}';
      }
      if (fromDate.isNotEmpty) {
        url += '&from=${fromDate.value}';
      }
      if (toDate.isNotEmpty) {
        url += '&to=${toDate.value}';
      }

      var response = await dio.get(url);

      if (response.statusCode == 200) {
        var articlesData = response.data['articles'] as List;
        var fetchedArticles =
            articlesData.map((article) => Article.fromJson(article)).toList();

        if (currentPage.value == 1) {
          articles.value = fetchedArticles;
        } else {
          articles.addAll(fetchedArticles);
        }

        // ignore: invalid_use_of_protected_member
        await cacheArticles(articles.value);
        totalPages.value = (response.data['totalResults'] / 10).ceil();
      }
    } catch (e) {
      print("Error fetching articles: $e");
    } finally {
      isLoading(false);
    }
  }

  void updateFilters(String source, String from, String to) {
    selectedSource.value = source;
    fromDate.value = from;
    toDate.value = to;
    currentPage.value = 1;
    fetchArticles();
  }

  void loadMoreArticles() {
    if (currentPage.value < totalPages.value) {
      currentPage.value++;
      fetchArticles();
    }
  }
}
