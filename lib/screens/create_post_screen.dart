import 'package:blog/data/services/posts_service.dart';
import 'package:blog/screens/home_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({Key? key}) : super(key: key);

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool isLoading = false;

  _createPost(title, content) async {
    setState(() {
      isLoading = true;
    });
    try {
      var result = await PostService.create({
        'title': title,
        'content': content
      });
      Fluttertoast.showToast(msg: "Poste créé avec succès");
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nouveau poste"),),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("Nouveau Poste", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.blue),),
            Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: titleController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                          hintText: "Entrez le titre du poste",
                          labelText: "Titre",
                      ),
                      validator: (value) {
                        return value == null || value == "" ? "Ce champs est obligatoire" : null;
                      },
                    ),
                    SizedBox(height: 10.0,),
                    TextFormField(
                      controller: contentController,
                      keyboardType: TextInputType.text,
                      minLines: 5,
                      maxLines: 7,
                      decoration: const InputDecoration(
                          hintText: "Entrez le contenu du poste",
                          labelText: "Contenu",
                      ),
                      validator: (value) {
                        return value == null || value == "" ? "Ce champs est obligatoire" : null;
                      },
                    ),
                    SizedBox(height: 20.0,),
                    ElevatedButton(
                        onPressed: () async {
                          if (!isLoading && formKey.currentState!.validate()) {
                            await _createPost(titleController.text, contentController.text);
                            titleController.text = "";
                            contentController.text = "";
                          }
                        },
                        child: isLoading ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3,)) : Text("Créer")
                    )
                  ],
                )
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
                },
                child: Text("Voir la liste des postes", style: TextStyle(fontSize: 17, color: Colors.blue),),
              ),
            )
          ],
        ),
      ),
    );
  }
}
