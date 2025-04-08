import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 230, 184, 200),
        ),
      ),
      home: const TaskListScreen(title: 'Task Manager'),
    );
  }
}

class Task {
  String name;
  bool checked;

  Task({required this.name, required this.checked});
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key, required this.title});
  final String title;

  @override
  State<TaskListScreen> createState() => _TaskListScreen();
}

class _TaskListScreen extends State<TaskListScreen> {
  final TextEditingController _controller = TextEditingController();

  final CollectionReference _tasks = FirebaseFirestore.instance.collection(
    'tasks',
  );

  List<Task> taskList = [
    Task(name: 'Do Homework', checked: true),
    Task(name: 'Exercise', checked: false),
    Task(name: 'Drink Water', checked: true),
    Task(name: 'Clean car', checked: false),
    Task(name: 'Do laundry', checked: false),
  ];

  Future<void> addTask([DocumentSnapshot? documentSnapshot]) async {
    String userTask = _controller.text;
    setState(() {
      _tasks.add({'name': userTask, 'checked': false});
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(title: 'loginpage'),
                  ),
                );
              },
              child: Text("Logout"),
            ),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Enter Task',
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: addTask,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder(
                stream: _tasks.snapshots(),
                builder: (
                  context,
                  AsyncSnapshot<QuerySnapshot> streamSnapshot,
                ) {
                  if (streamSnapshot.hasData) {
                    return ListView.builder(
                      itemCount: streamSnapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final DocumentSnapshot documentSnapshot =
                            streamSnapshot.data!.docs[index];
                        return ListTile(
                          leading: Checkbox(
                            value: documentSnapshot['checked'],
                            onChanged: (bool? newValue) {
                              _tasks.doc(documentSnapshot.id).update({
                                'checked': newValue,
                              });
                            },
                          ),
                          title: Text(documentSnapshot['name']),
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              FirebaseFirestore.instance
                                  .collection('tasks')
                                  .doc(documentSnapshot.id)
                                  .delete();
                            },
                          ),
                        );
                      },
                    );
                  }
                  return Center(child: Text("No tasks"));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
