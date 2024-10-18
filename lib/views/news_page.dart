import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/news_controller.dart';
import 'article_item.dart';
import 'package:intl/intl.dart';

class NewsPage extends StatelessWidget {
  final NewsController newsController = Get.put(NewsController());
  final ScrollController _scrollController = ScrollController();

  NewsPage({super.key}) {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        newsController.loadMoreArticles();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Latest News'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showFilterDialog(context);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (newsController.isLoading.value && newsController.articles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (newsController.articles.isEmpty) {
          return const Center(child: Text('No articles found.'));
        } else {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: newsController.articles.length + 1,
              itemBuilder: (context, index) {
                if (index == newsController.articles.length) {
                  return Obx(() {
                    return newsController.isLoading.value
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox.shrink();
                  });
                }
                return ArticleItem(article: newsController.articles[index]);
              },
            ),
          );
        }
      }),
    );
  }

  void showFilterDialog(BuildContext context) {
    DateTime? fromDate;
    DateTime? toDate;
    String fromDateLabel = 'From Date';
    String toDateLabel = 'To Date';
    final sourceController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Filter Articles'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: sourceController,
                    decoration: const InputDecoration(labelText: 'Source'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: fromDateLabel,
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      fromDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (fromDate != null) {
                        setState(() {
                          fromDateLabel =
                              'From: ${DateFormat('yyyy-MM-dd').format(fromDate!)}';
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: toDateLabel,
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
                    onTap: () async {
                      toDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (toDate != null) {
                        setState(() {
                          toDateLabel =
                              'To: ${DateFormat('yyyy-MM-dd').format(toDate!)}';
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    String fromDateString = fromDate != null
                        ? DateFormat('yyyy-MM-dd').format(fromDate!)
                        : '';
                    String toDateString = toDate != null
                        ? DateFormat('yyyy-MM-dd').format(toDate!)
                        : '';

                    newsController.updateFilters(
                      sourceController.text,
                      fromDateString,
                      toDateString,
                    );
                    Get.back();
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
