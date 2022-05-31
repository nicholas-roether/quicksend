import 'package:flutter/material.dart';
import 'package:quicksend/client/provider.dart';
import 'package:quicksend/screens/chat_list.dart';
import 'package:quicksend/screens/settings_screen.dart';
import 'package:quicksend/utils/user_search_delegate.dart';
import 'package:quicksend/widgets/custom_bottom_navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  @override
  void initState() {
    // Stupid hack to prevent hot reloads from messing up the route stack
    final quicksendClient = QuicksendClientProvider.get(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (Navigator.canPop(context)) {
        Navigator.popUntil(context, (route) => route.isFirst);
        Navigator.popAndPushNamed(context, "/home");
      }
      if (!quicksendClient.isLoggedIn()) {
        Navigator.popAndPushNamed(context, "/");
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomBottomNavbar(
        currentIndex: selectedIndex,
        setIndex: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
      floatingActionButton: selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) {
                    return Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).backgroundColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    );
                  },
                );
              },
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add),
            )
          : const SizedBox(),
      appBar: AppBar(
        title: Text(
          selectedIndex == 0 ? "Chats" : "Settings",
          style: Theme.of(context).textTheme.headline5,
        ),
        actions: [
          selectedIndex == 0
              ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    splashRadius: 18,
                    iconSize: 30,
                    onPressed: () => showSearch(
                        context: context, delegate: UserSearchDelegate()),
                    icon: const Icon(
                      Icons.search,
                    ),
                  ),
                )
              : const SizedBox(
                  height: 0,
                  width: 0,
                ),
        ],
      ),
      body: selectedIndex == 0 ? const ChatList() : const SettingScreen(),
    );
  }
}
