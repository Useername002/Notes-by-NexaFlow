import'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import'package:path/path.dart';
import 'dart:io';

class Notesdb
{
  //singleton object of Notesdb
 static final Notesdb instance= Notesdb._();
 Notesdb._();
 Database?Mydb;
 Future<Database>getDB()async{
   if(Mydb!=null) {return Mydb!;}
   else{Mydb=await opendb(); return Mydb!;}
 }
 Future<Database>opendb()async{
   Directory appdir=await getApplicationDocumentsDirectory();
   String dbPath=join(appdir.path, "Notes.db");
   return await openDatabase(dbPath,onCreate: (db, version)
   {
     db.execute("create table Notes(ID INTEGER PRIMARY KEY AUTOINCREMENT, Title TEXT NOT NULL,Content TEXT NOT NULL , Timestamp TEXT NOT NULL )");
   },
   version: 1,
   );
 }
 //inserting notes into table
 Future<int> insertNote(String title, String content)async{
   final db=await getDB();
   final note= {
     'Title':title,
     'Content':content,
     'Timestamp':DateTime.now().toIso8601String(),
   };
   return await db.insert('Notes', note);
 }
//retrieving notes from table
Future<List<Map<String ,dynamic>>> fetchNotes()async{
   final db= await getDB();
   return await db.query('Notes',orderBy: 'Timestamp DESC');
}
//checking if notes exist on app startup using shared_preferences
Future<void> checkNotes()async{
   final prefs= await SharedPreferences.getInstance();
   final hasNotes=prefs.getBool('hasNotes')??false;
   if(!hasNotes)
     {
       final db = await getDB();
       final notes= await db.query('Notes');
       if(notes.isNotEmpty){
         await prefs.setBool('hasNotes', true);
       }
     }
 }
}