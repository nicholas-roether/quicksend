import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quicksend/client/models.dart';
import 'package:quicksend/client/provider.dart';
import 'package:quicksend/widgets/custom_error_alert_widget.dart';
import 'package:quicksend/widgets/loading_indicator.dart';

class RegisteredDevices extends StatelessWidget {
  const RegisteredDevices({Key? key}) : super(key: key);

  IconData getDevice(int type) {
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
          style: Theme.of(context).textTheme.headline5,
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
              return Dismissible(
                key: Key(snapshot.data![index].name),
                confirmDismiss: (_) async {
                  try {
                    await quicksendClient
                        .removeDevice(snapshot.data![index].id);
                    return true;
                  } on Exception catch (_) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const CustomErrorWidget(
                            message:
                                "Cannot remove the device that is currently in use!");
                      },
                    );
                    return false;
                  }
                },
                background: Container(
                  decoration: const BoxDecoration(color: Colors.red),
                  child: const Icon(Icons.delete),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                ),
                direction: DismissDirection.endToStart,
                child: ListTile(
                  title: Text(
                    snapshot.data![index].name,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  subtitle: Text(
                    "last activity: ${DateFormat('dd.MM.yyyy EEEE').format(snapshot.data![index].lastActivity)}",
                  ),
                  leading: Icon(
                    getDevice(snapshot.data![index].type),
                    color: Theme.of(context).primaryColor,
                  ),
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
