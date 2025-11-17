import'package:flutter/material.dart';
import 'package:notes/notesUI.dart';


void main()
{
  runApp(Notes());
}
class Notes extends StatefulWidget
{
  @override
  State<StatefulWidget> createState()=>NotesState();
}
class NotesState extends State<Notes>
{
@override
  Widget build(BuildContext context)
{
  return MaterialApp(
    debugShowCheckedModeBanner:false,
    title: 'Notes',
    theme: ThemeData(
      primaryColor: Colors.amberAccent,
      appBarTheme: AppBarTheme(
        backgroundColor:Colors.amberAccent,
        elevation:2,
      ),
      colorScheme: ColorScheme.fromSeed(seedColor:Colors.amber),
    ),
    home:notesUI(),
  );
}
}
