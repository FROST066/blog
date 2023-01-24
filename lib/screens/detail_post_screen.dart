import 'package:blog/data/models/comment.dart';
import 'package:blog/data/models/post.dart';
import 'package:blog/data/services/comments_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DetailPostScreen extends StatefulWidget {
  const DetailPostScreen({Key? key, required this.post}) : super(key: key);

  final Post post;

  @override
  State<DetailPostScreen> createState() => _DetailPostScreenState();
}

class _DetailPostScreenState extends State<DetailPostScreen> {

  final contentController = TextEditingController();

  List<Comment> _comments = [];

  final formKey = GlobalKey<FormState>();

  bool isLoading = false;

  _createComment(content) async {
    setState(() {
      isLoading = true;
    });
    try {
      var result = await CommentService.create({
        'content': content,
        'post_id': widget.post.id
      });
      contentController.text = "";
      await _loadComments();
      Fluttertoast.showToast(msg: "Commentaire ajouté avec succès");
    } on DioError catch (e) {
      Map<String, dynamic> error = e.response?.data;
      if (error != null && error.containsKey('message')) {
        Fluttertoast.showToast(msg: error['message']);
      } else {
        Fluttertoast.showToast(msg: "Une erreur est survenue veuillez rééssayer");
      }
      print(e.response);
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  _loadComments() async {
    try {
      _comments = await CommentService.fetch(queryParameters: {'post_id': widget.post.id});
    } on DioError catch (e) {
      Map<String, dynamic> error = e.response?.data;
      if (error != null && error.containsKey('message')) {
        Fluttertoast.showToast(msg: error['message']);
      } else {
        Fluttertoast.showToast(msg: "Une erreur est survenue veuillez rééssayer");
      }
      print(e.response);
    } finally {
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title!),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Text(widget.post.title!, textAlign: TextAlign.center, style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20),),
            SizedBox(height: 30.0,),
            Text(widget.post.content!, textAlign: TextAlign.justify, style: TextStyle(fontSize: 17.0, color: Colors.black),),
            SizedBox(height: 15.0,),
            Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: contentController,
                      minLines: 3,
                      maxLines: 5,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Ajouter un commentaire",
                      ),
                      validator: (value) {
                        return value == null || value == "" ? "Ce champs est obligatoire" : null;
                      },
                    ),
                    SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () async{
                          if(formKey.currentState!.validate()) {
                            await _createComment(contentController.text);
                          }
                        },
                        child: isLoading ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,)) : Text("Ajouter"),
                      ),
                    )
                  ],
                )
            ),
            SizedBox(height: 20.0,),
            Align(alignment: Alignment.centerLeft, child: Text("Commentaires", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),)),
            Flexible(
              child: ListView.builder(
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Align(alignment: Alignment.centerLeft ,child: Text(_comments[index].content!, style: TextStyle(fontSize: 16),)),
                            SizedBox(height: 10,),
                            Align(alignment: Alignment.centerRight ,child: Text(_comments[index].user!.username!+" "+ "le "+_comments[index].createdAt.toString(), style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),)),
                          ],
                        ),
                      ),
                    );
                  }
              ),
            )
          ],
        ),
      ),
    );
  }
}
