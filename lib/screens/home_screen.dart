import 'package:blog/data/models/post.dart';
import 'package:blog/data/services/posts_service.dart';
import 'package:blog/screens/create_post_screen.dart';
import 'package:blog/screens/detail_post_screen.dart';
import 'package:blog/screens/login_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<Post> posts = [];
  bool isLoadingPosts = false;

  loadPost () async {
    setState(() {
      isLoadingPosts = true;
    });
    try {
      posts = await PostService.fetch();
    } on DioError catch(e) {
      print(e);
      Map<String, dynamic> error = e.response?.data;
      if (error != null && error.containsKey('message')) {
        Fluttertoast.showToast(msg: error['message']);
      } else {
        Fluttertoast.showToast(msg: "Une erreur est survenue veuillez rééssayer");
      }
    } finally {
      isLoadingPosts = false;
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadPost();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Liste des posts"),
        actions: [
          IconButton(
              onPressed: () async{
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginScreen()));
              },
              icon: Icon(Icons.logout)
          )
        ],
      ),
      body: isLoadingPosts ? Center(
        child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator()
        ),
      ) : posts.length > 0 ? ListView.builder(
        itemCount: posts.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: ListTile(
              leading: Icon(Icons.list_alt),
              title: Text(posts[index].title!, maxLines: 1,),
              subtitle: Text("Créer par "+posts[index].user!.username!+ " le "+posts[index].createdAt!.toString()),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => DetailPostScreen(post: posts[index])));
              },
            ),
          );
        },
      ) : Center(
        child: Text("Aucuns blogs disponibles", style: TextStyle(fontSize: 20.0, fontStyle: FontStyle.italic),),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePostScreen()));
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}