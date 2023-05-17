import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqf_lite/models/note_model.dart';
import 'package:sqf_lite/services/database_helper.dart';

class NoteScreen extends StatefulWidget {
  final Note? note;

  const NoteScreen({Key? key, this.note}) : super(key: key);

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  File? _imageFile;

  Future<void> _selectImage() async {
    final imageSource = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Select Image Source"),
          actions: <Widget>[
            GestureDetector(
              child: Text("Camera"),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            GestureDetector(
              child: Text("Gallery"),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        );
      },
    );

    if (imageSource != null) {
      // ignore: deprecated_member_use
      final pickedFile = await ImagePicker().getImage(source: imageSource);

      setState(() {
        if (pickedFile != null) {
          _imageFile = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var imgPath = _imageFile;
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    if (widget.note != null) {
      titleController.text = widget.note!.title;
      descriptionController.text = widget.note!.description;
      imgPath = widget.note!.imagePath as File?;
    }

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.note == null ? "Add a note" : "Edit a note"),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              GestureDetector(
                onTap: _selectImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? Icon(
                          Icons.person,
                          size: 30,
                        )
                      : null,
                ),
              ),
              const Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: Center(
                    child: Text(
                  "What are you thinking about ?",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                )),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: TextFormField(
                  controller: titleController,
                  maxLines: 1,
                  decoration: const InputDecoration(
                      hintText: 'Title',
                      labelText: 'Note title',
                      border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.white,
                            width: 0.75,
                          ),
                          borderRadius:
                              BorderRadius.all(Radius.circular(10.0)))),
                ),
              ),
              TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                    hintText: 'type here note',
                    labelText: 'Note description',
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                          width: 0.75,
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(10.0)))),
                keyboardType: TextInputType.multiline,
                onChanged: (str) {},
                maxLines: 2,
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: SizedBox(
                  height: 35,
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                      onPressed: () async {
                        final imagePath = _imageFile;
                        final title = titleController.value.text;
                        final description = descriptionController.value.text;

                        if (title.isEmpty || description.isEmpty || imagePath == null) {
                          return;
                        }

                        final Note model = Note(
                            title: title,
                            description: description,
                            imagePath: imagePath.toString(),
                            id: widget.note?.id);
                        if (widget.note == null) {
                          await DatabaseHelper.addNote(model);
                        } else {
                          await DatabaseHelper.updateNote(model);
                        }
                        Navigator.pop(context);
                      },
                      style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                              const RoundedRectangleBorder(
                                  side: BorderSide(
                                      color: Colors.white, width: 0.75),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(10.0))))),
                      child: Text(
                        widget.note == null ? "Save" : "Edit",
                        style: const TextStyle(fontSize: 20),
                      )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
