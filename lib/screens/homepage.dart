import 'package:flutter/material.dart';
import 'package:quicksend/client/exceptions.dart';
import 'package:quicksend/client/provider.dart';
import 'package:quicksend/screens/chat_list.dart';
import 'package:quicksend/screens/settings_screen.dart';
import 'package:quicksend/utils/user_search_delegate.dart';
import 'package:quicksend/widgets/custom_bottom_navbar.dart';
import 'package:quicksend/widgets/custom_text_form_field.dart';
import 'package:quicksend/widgets/small_fab_widget.dart';

import '../widgets/custom_error_alert_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  final TextEditingController _popUpController = TextEditingController();

  void createChat() async {
    if (_popUpController.text.isEmpty) return;
    final quicksendClient = QuicksendClientProvider.get(context);
    try {
      final userInfo = await quicksendClient.getUserInfo();
      if (_popUpController.text == userInfo.username) return;
      await quicksendClient.getChatList().createChat(_popUpController.text);
      _popUpController.text = "";
      Navigator.pop(context);
    } on UnknownUserException {
      showDialog(
        context: context,
        builder: (context) {
          return const CustomErrorWidget(
            message: "User does not exist",
          );
        },
      );
    }
  }

  void showChatPopup() {
    showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * (2 / 3),
          decoration: BoxDecoration(
            color: Theme.of(context).backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Align(
              alignment: Alignment.topCenter,
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      hintInfo: "",
                      labelInfo: "Benutzername",
                      obscure: false,
                      textController: _popUpController,
                      submitCallback: (_) => createChat(),
                      noPadding: true,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SmallFAB(
                    onPressedCallback: () => createChat(),
                    icon: Icons.add,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

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
              onPressed: showChatPopup,
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
