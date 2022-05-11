import 'package:flutter/material.dart';
import 'package:quicksend/screens/chat_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        backgroundColor: Theme.of(context).backgroundColor,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.blueGrey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Chats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
      appBar: AppBar(
        title: Text(
          "Chats",
          style: Theme.of(context).textTheme.headline4,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.search,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => ListTile(
          title: ListTile(
            title: Text(
              'Benutzername: ${index + 1}',
              style: Theme.of(context).textTheme.headline6,
            ),
            subtitle: Text(
              "Last Message",
              style: Theme.of(context).textTheme.bodyText1,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return const ChatScreen();
                },
              ),
            ),
          ),
        ),
        itemCount: 20,
      ),
    );
  }
}
