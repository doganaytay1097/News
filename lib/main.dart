import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(NewsApp());
}

class NewsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    NewsHomePage(),
    ExplorePage(),
    ProfilePage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class NewsHomePage extends StatefulWidget {
  @override
  _NewsHomePageState createState() => _NewsHomePageState();
}

class _NewsHomePageState extends State<NewsHomePage> {
  List articles = [];
  bool isLoading = true;
  String apiKey = '2850d9ce399dcf8f01d940abb2ef0ad3'; // Buraya kendi GNews API anahtarınızı ekleyin.
  String category = 'general'; // Varsayılan kategori

  @override
  void initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    try {
      final response = await http.get(Uri.parse(
          'https://gnews.io/api/v4/top-headlines?token=$apiKey&lang=en&country=tr&topic=$category'));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          articles = data['articles'];
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching news: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  void searchNews(String searchQuery) {
    setState(() {
      isLoading = true;
    });
    fetchNews();
  }

  void changeCategory(String newCategory) {
    setState(() {
      category = newCategory;
      isLoading = true;
    });
    fetchNews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NBWS APP'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: NewsSearchDelegate(searchNews));
            },
          ),
          IconButton(icon: Icon(Icons.notifications), onPressed: () {}),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Text('Kategoriler', style: TextStyle(color: Colors.white, fontSize: 24)),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            ListTile(
              title: Text('Genel'),
              onTap: () {
                changeCategory('general');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('İş'),
              onTap: () {
                changeCategory('business');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Teknoloji'),
              onTap: () {
                changeCategory('technology');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Eğlence'),
              onTap: () {
                changeCategory('entertainment');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Spor'),
              onTap: () {
                changeCategory('sports');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Bilim'),
              onTap: () {
                changeCategory('science');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Sağlık'),
              onTap: () {
                changeCategory('health');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : articles.isEmpty
              ? Center(child: Text('No news found'))
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView.builder(
                    itemCount: articles.length,
                    itemBuilder: (context, index) {
                      final article = articles[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewsDetailPage(article: article),
                            ),
                          );
                        },
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (article['image'] != null)
                                Image.network(article['image'], fit: BoxFit.cover),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  article['title'] ?? 'No Title',
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  article['description'] ?? 'No Description',
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

class NewsSearchDelegate extends SearchDelegate {
  final Function(String) onSearch;

  NewsSearchDelegate(this.onSearch);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    close(context, null);
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}

class NewsDetailPage extends StatelessWidget {
  final Map<String, dynamic> article;

  NewsDetailPage({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article['title'] ?? 'News Detail'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (article['image'] != null)
              Image.network(article['image']),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                article['title'] ?? 'No Title',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                article['description'] ?? 'No Description',
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                article['content'] ?? 'No Content',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExplorePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Explore'),
      ),
      body: Center(
        child: Text('Explore Page'),
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Text('Profile Page'),
      ),
    );
  }
}
