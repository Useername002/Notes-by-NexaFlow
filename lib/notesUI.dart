import 'package:flutter/material.dart';
import 'package:notes/main.dart';
import 'package:notes/Database/local/Sqllite_db.dart';
import 'package:notes/noteEditingpage.dart';
import 'package:intl/intl.dart';

class notesUI extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => notesUIState();
}

class notesUIState extends State<notesUI> {
  List<Map<String, dynamic>> notes = [];
  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    final data = await Notesdb.instance.fetchNotes();
    setState(() {
      notes = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Notes",
          style: TextStyle(color: Colors.black, fontSize: 25),
        ),
      ),
      body: notes.isEmpty
          ? Center(
              child: Text(
                "Tap + to create a note",
                style: TextStyle(color: Colors.grey, fontSize: 25),
              ),
            )
          : ListView.builder(
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                final noteId = note['ID'] as int;
                   return Dismissible(key: Key(noteId.toString()),
                       direction: DismissDirection.endToStart,
                       background: Container(
                         color: Colors.red,
                         alignment: Alignment.centerRight,
                         padding: EdgeInsets.symmetric(horizontal: 20),
                         child: Icon(Icons.delete,color: Colors.white,),
                       ),
                       onDismissed:(direction)async{
                     final db=await Notesdb.instance.getDB();
                     await db.delete('Notes',where:'ID=?',whereArgs:[noteId]);
                     setState(() {
                       notes.removeAt(index);
                     });
                     ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(content: Text('Note deleted')),
                     );

                       },
                       child:  Card(
                     margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                     child: ListTile(
                       title: Text(note['Title'] ?? 'Untitled'),
                       subtitle: Text(
                         note['Content'] ?? ' ',
                         maxLines: 1,
                         overflow: TextOverflow.ellipsis,
                       ),
                       trailing: Text(
                         formatTimestamp(note['Timestamp']),
                         style: TextStyle(fontSize: 12),
                       ),
                       onTap: () async {
                         final noteId = note['ID'] as int;
                         await Navigator.push(
                           context,
                           MaterialPageRoute(
                             builder: (_) => noteEditingpage(noteId: noteId),
                           ),
                         );
                         await loadNotes();
                       },
                     ),
                   ));

              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => noteEditingpage()),
          ).then((_) => loadNotes());
        },
        child: Icon(Icons.note_add),
      ),
    );
  }

  String formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    final dt = DateTime.tryParse(timestamp);
    if (dt == null) return '';
    return DateFormat('dd MMM yyyy, h:mm a').format(dt);
  }
}
