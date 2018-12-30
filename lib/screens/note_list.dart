import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:notekeeper/models/note.dart';
import 'package:notekeeper/utils/database_helper.dart';
import 'package:notekeeper/screens/note_detail.dart';
import 'package:sqflite/sqflite.dart';

class NoteList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return NoteListState();
  }
}

class NoteListState extends State<NoteList> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Note> noteList;
  int count = 0;
  Note note;
  DatabaseHelper helper = DatabaseHelper();
  static var _priorities = ['High', 'Low'];
  String currentProfilePic =
      "https://avatars3.githubusercontent.com/u/16825392?s=460&v=4";

  @override
  Widget build(BuildContext context) {

    if (noteList == null) {
      noteList = List<Note>();
      updateListView();
    }
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          leading: Container(
            width: 0.0,
            height: 0.0,
          ),
          backgroundColor: Colors.white,
          elevation: 0.0,
          title: Container(
            child: Padding(
                padding: EdgeInsets.only(top: 20.0, left: 10.0),
                child: Text(
                  'My Tasks',
                  textAlign: TextAlign.left,
//                textDirection: TextDirection.ltr,
                  style: TextStyle(
                      fontSize: 30.0,
                      color: Colors.black,
                      fontFamily: 'Raleway',
                      fontWeight: FontWeight.w400),
                )),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: getNoteListView(),
        ),
        backgroundColor: Colors.white,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            debugPrint('FAB clicked');
            _showAlertDialog();
//          navigateToDetail(Note('', '', 2), 'Add Note');
          },
          tooltip: 'Add Note',
          icon: Icon(Icons.add),
          label: Text('Add New Task'),
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              new UserAccountsDrawerHeader(
                accountEmail: new Text("bramvbilsen@gmail.com"),
                accountName: new Text("Bramvbilsen"),
                currentAccountPicture: new GestureDetector(
                  child: new CircleAvatar(
                    backgroundImage: new NetworkImage(currentProfilePic),
                  ),
                  onTap: () => print("This is your current account."),
                ),
                decoration: new BoxDecoration(
                    image: new DecorationImage(
                        image: new NetworkImage(
                            "https://img00.deviantart.net/35f0/i/2015/018/2/6/low_poly_landscape__the_river_cut_by_bv_designs-d8eib00.jpg"),
                        fit: BoxFit.fill)),
              ),
              new ListTile(
                  title: new Text("Page One"),
                  trailing: new Icon(Icons.arrow_upward),
                  onTap: () {
                    Navigator.of(context).pop();
                  }),
              new ListTile(
                  title: new Text("Page Two"),
                  trailing: new Icon(Icons.arrow_right),
                  onTap: () {
                    Navigator.of(context).pop();
                  }),
              new Divider(),
              new ListTile(
                title: new Text("Cancel"),
                trailing: new Icon(Icons.cancel),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          elevation: 40.0,
          child:
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.menu),
                  onPressed: () {
                    _scaffoldKey.currentState.openDrawer();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    mainBottomSheet(context);
                  },
                ),
              ],
            ),

        ));
  }

  ListView getNoteListView() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          elevation: 0.2,
          color: Colors.white,
          child: ListTile(
            leading: Radio(
              value: 0,
              activeColor: Colors.teal,
            ),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(
                      top: 10.0,
                      bottom: 5.0,
                    ),
                    child: Text(
                      this.noteList[position].title,
                      style: TextStyle(
                          fontFamily: 'Raleway',
                          fontWeight: FontWeight.w400,
                          fontSize: 12.0),
                      textAlign: TextAlign.left,
//                      textDirection: TextDirection.ltr,
                      textScaleFactor: 1.3,
                    )),
                Padding(
                  padding: EdgeInsets.only(bottom: 5.0),
                  child: Text(
                    'Description: ' + this.noteList[position].description,

                    style: TextStyle(
                        fontFamily: 'Raleway',
                        fontWeight: FontWeight.w400,
                        fontSize: 12.0),
                    textAlign: TextAlign.left,
//                    textDirection: TextDirection.ltr,
                  ),
                )
              ],
            ),
            subtitle: Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Text(this.noteList[position].date,
                  style: TextStyle(
                    fontFamily: 'Raleway',
                    fontWeight: FontWeight.w300,
                  )),
            ),
            trailing: GestureDetector(
              child: Icon(
                Icons.delete,
                color: Colors.indigo,
              ),
              onTap: () {
                _delete(context, noteList[position]);
              },
            ),
            onTap: () {
              debugPrint("ListTile Tapped");
              navigateToDetail(this.noteList[position], 'Edit Note');
            },
          ),
        );
      },
    );
  }

  // Returns the priority color
  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;

      default:
        return Colors.yellow;
    }
  }

  // Returns the priority icon
  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;

      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void _delete(BuildContext context, Note note) async {
    int result = await databaseHelper.deleteNote(note.id);
    if (result != 0) {
      _showSnackBar(context, 'Note Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Note note, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NoteDetail(note, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Note>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((noteList) {
        setState(() {
          this.noteList = noteList;
          this.count = noteList.length;
        });
      });
    });
  }

  mainBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _createTile(context, 'Message', Icons.message, _action1),
              _createTile(context, 'Take Photo', Icons.camera_alt, _action2),
              _createTile(context, 'My Images', Icons.photo_library, _action3),
            ],
          );
        });
  }

  ListTile _createTile(
      BuildContext context, String name, IconData icon, Function action) {
    return ListTile(
      leading: Icon(icon),
      title: Text(name),
      onTap: () {
        Navigator.pop(context);

        action();
      },
    );
  }

  _action1() {
    print('action 1');
  }

  _action2() {
    print('action 2');
  }

  _action3() {
    print('action 3');
  }

  void _showAlertDialog() {
    String _title = '';
    int _priority = 2;
    String desc = '';
    Note note = Note(
        _title, DateFormat.yMMMd().format(DateTime.now()), _priority, desc);
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    var _priorities = ['High', 'Low'];

    void updateTitle() {
      note.title = titleController.text;
    }

    void updateDescription() {
      note.description = descriptionController.text;
    }

    void updatePriorityAsInt(String value) {
      switch (value) {
        case 'High':
          note.priority = 1;
          break;
        case 'Low':
          note.priority = 2;
          break;
      }
    }

    void _save() async {
      Navigator.pop(context);
      // Case 2: Insert Operation
      await helper.insertNote(note);
      updateListView();
    }

    AlertDialog alertDialog = AlertDialog(
        content: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height / 2,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: ListView(
                    children: <Widget>[
                      // First element
                      ListTile(
                        title: DropdownButton(
                            items: _priorities.map((String dropDownStringItem) {
                              return DropdownMenuItem<String>(
                                value: dropDownStringItem,
                                child: Text(dropDownStringItem),
                              );
                            }).toList(),
                            value: getPriorityAsString(note.priority),
                            onChanged: (valueSelectedByUser) {
                              setState(() {
                                debugPrint(
                                    'User selected $valueSelectedByUser');
                                updatePriorityAsInt(valueSelectedByUser);
                              });
                            }),
                      ),

                      // Second Element
                      Padding(
                        padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                        child: TextField(
                          controller: titleController,
                          onChanged: (value) {
                            debugPrint('Something changed in Title Text Field');
                            updateTitle();
                          },
                          decoration: InputDecoration(
                              labelText: 'Title',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0))),
                        ),
                      ),

                      // Third Element
                      Padding(
                        padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                        child: TextField(
                          controller: descriptionController,
                          onChanged: (value) {
                            debugPrint(
                                'Something changed in Description Text Field');
                            updateDescription();
                          },
                          decoration: InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0))),
                        ),
                      ),

                      // Fourth Element
                      Padding(
                        padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: RaisedButton(
                                color: Theme.of(context).primaryColorDark,
                                textColor: Theme.of(context).primaryColorLight,
                                child: Text(
                                  'Save',
                                  textScaleFactor: 1.5,
                                ),
                                onPressed: () {
                                  setState(() {
                                    debugPrint("Save button clicked");
                                    _save();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )));
    showDialog(context: context, builder: (_) => alertDialog);
  }

  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0]; // 'High'
        break;
      case 2:
        priority = _priorities[1]; // 'Low'
        break;
    }
    return priority;
  }
}
