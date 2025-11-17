import 'package:flutter/material.dart';
import 'package:notes/Database/local/Sqllite_db.dart';

class noteEditingpage extends StatefulWidget {
  final int? noteId;
  noteEditingpage({this.noteId});
  @override
  State<noteEditingpage> createState() => noteEditingpageState();
}

class noteEditingpageState extends State<noteEditingpage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  bool isNewNote = true;
  int? CurrentNoteId;
  @override
  void initState() {
    super.initState();
    if (widget.noteId != null) {
      isNewNote = false;
      Future.microtask(() => loadNote(widget.noteId));
    }
  }

  Future<void> loadNote(int? id) async {
    if (id == null) return;
    final db = await Notesdb.instance.getDB();
    final result = await db.query('Notes', where: 'ID= ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      final note = result.first;
      titleController.text = note["Title"] as String;
      contentController.text = note["Content"] as String;
      CurrentNoteId = note['ID'] as int;
    }
  }

  void autosave() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();
    if (title.isEmpty && content.isEmpty) return;
    final db = await Notesdb.instance.getDB();
    final note = {
      "Title": title.isEmpty ? 'Untitled' : title,
      "Content": content,
      "Timestamp": DateTime.now().toIso8601String(),
    };
    if (isNewNote) {
      CurrentNoteId = await db.insert('Notes', note);
      isNewNote = false;
    } else {
      await db.update('Notes', note, where: 'ID=?', whereArgs: [CurrentNoteId]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Note")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hint: Text(
                  "Title",
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                suffix: Text("Title",style:TextStyle(color:Colors.grey)),
                enabledBorder:UnderlineInputBorder(borderSide:BorderSide(color:Colors.transparent)),
                focusedBorder:UnderlineInputBorder(borderSide:BorderSide(color:Colors.transparent)),
              ),
              onChanged: (_) => autosave(),
            ),
            SizedBox(height: 10),
            Expanded(
              child: TextField(
                controller: contentController,
                decoration: InputDecoration(
                  hint: Text(
                    "Your Note....",
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 25
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                  focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.transparent)),
                ),
                maxLines: null,
                expands: true,
                onChanged: (_) => autosave(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
