import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quicksend/client/exceptions.dart';
import 'package:quicksend/client/models.dart';
import 'package:quicksend/client/provider.dart';
import 'package:quicksend/widgets/custom_error_alert_widget.dart';
import 'package:quicksend/widgets/custom_listttile.dart';
import 'package:quicksend/widgets/custom_text_form_field.dart';
import 'package:quicksend/widgets/loading_indicator.dart';

class RegisteredDevices extends StatelessWidget {
  const RegisteredDevices({Key? key}) : super(key: key);

  IconData getDeviceIcon(int type) {
    switch (type) {
      case 0:
        return Icons.device_unknown;
      case 1:
        return Icons.smartphone;
      case 2:
        return Icons.computer;
      case 3:
        return Icons.terminal;
      case 4:
        return Icons.language;
    }
    return Icons.device_unknown_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final quicksendClient = QuicksendClientProvider.get(context);
    final registeredDevices = quicksendClient.getRegisteredDevices();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Registered devices",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
      body: FutureBuilder<List<DeviceInfo>>(
        future: registeredDevices,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LoadingIndicator();
          }
          return ListView.builder(
            itemBuilder: (context, index) {
              String currentDeviceID = quicksendClient.getCurrentDeviceID();
              if (snapshot.data![index].id == currentDeviceID) {
                return CustomListtile(
                  title: snapshot.data![index].name,
                  icon: getDeviceIcon(snapshot.data![index].type),
                  iconColor: Theme.of(context).colorScheme.secondary,
                  subtitle:
                      "last activity: ${DateFormat('dd.MM.yyyy EEEE').format(snapshot.data![index].lastActivity)}",
                  trailingIcon: Icons.my_location,
                );
              }
              return Dismissible(
                key: Key(snapshot.data![index].name),
                confirmDismiss: (DismissDirection direction) async {
                  bool confirmation = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Are you sure?'),
                        content: const Text(
                          "This action will logout the selected device and therefore delete all messages on that device",
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(true);
                            },
                            child: Text(
                              'Sure!',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: Text(
                              'Nope',
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          )
                        ],
                      );
                    },
                  );
                  if (!confirmation) return false;
                  TextEditingController _passwordController =
                      TextEditingController();
                  return await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Enter password"),
                        content: CustomTextFormField(
                          hintInfo: "",
                          labelInfo: "Password",
                          obscure: true,
                          textController: _passwordController,
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () async {
                              try {
                                await quicksendClient.removeDevice(
                                    _passwordController.text,
                                    snapshot.data![index].id);
                                Navigator.of(context).pop(true);
                              } on RequestException catch (error) {
                                Navigator.of(context).pop(false);
                                await showDialog(
                                  context: context,
                                  builder: (context) {
                                    return CustomErrorWidget(
                                      message: error.message,
                                    );
                                  },
                                );
                              }
                            },
                            child: const Text("Okay"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(false);
                            },
                            child: const Text("Cancel"),
                          ),
                        ],
                      );
                    },
                  );
                },
                background: Container(
                  decoration: const BoxDecoration(color: Colors.red),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                ),
                direction: DismissDirection.endToStart,
                child: CustomListtile(
                  title: snapshot.data![index].name,
                  subtitle:
                      "last activity: ${DateFormat('dd.MM.yyyy EEEE').format(snapshot.data![index].lastActivity)}",
                  icon: getDeviceIcon(snapshot.data![index].type),
                ),
              );
            },
            itemCount: snapshot.data!.length,
          );
        },
      ),
    );
  }
}
