import 'package:flutter/material.dart';
import 'package:quicksend/screens/chat_screen.dart';
import 'package:quicksend/utils/user_search_delegate.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
            onPressed: () =>
                showSearch(context: context, delegate: UserSearchDelegate()),
            icon: const Icon(
              Icons.search,
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemBuilder: (context, index) => ListTile(
          title: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.white,
            ),
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
