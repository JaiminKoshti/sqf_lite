import 'package:flutter/material.dart';
import 'package:sqf_lite/models/note_model.dart';
import 'package:sqf_lite/screens/note_screen.dart';
import 'package:sqf_lite/services/database_helper.dart';
import 'package:sqf_lite/widgets/note_card_widget.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({Key? key}) : super(key: key);

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (context) => const NoteScreen()));
            setState(() {});
          },
          child: const Icon(Icons.add)),
      body: FutureBuilder<List<Note>?>(
        future: DatabaseHelper.getAllNotes(),
        builder: (context, AsyncSnapshot<List<Note>?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {} else
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (snapshot.hasData) {
            if (snapshot.data != null) {
              return ListView.builder(itemBuilder: (context, index) =>
                  NoteCardWidgets(note: snapshot.data![index],
                      onTap: () async {
                        await Navigator.push(
                            context, MaterialPageRoute(builder: (context) =>
                            NoteScreen(note: snapshot.data![index],)));
                        setState(() {});
                      },
                      onLongPress: () async {
                        showDialog(context: context, builder: (context) {
                          return AlertDialog(
                            title: const Text(
                                "are you sure you want to delete this note ?"),
                            actions: [
                              ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .all(Colors.red)),
                                  onPressed: () async {
                                    await DatabaseHelper.deleteNote(
                                        snapshot.data![index]);
                                    Navigator.pop(context);
                                    setState(() {});
                                  }, child: const Text("Yes")),
                              ElevatedButton(onPressed: ()=> Navigator.pop(context), child: const Text("No"))
                            ],
                          );
                        });
                      }),itemCount: snapshot.data!.length,
              );
            }
            return const Center(
              child: Text("click + to create new notes"),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
