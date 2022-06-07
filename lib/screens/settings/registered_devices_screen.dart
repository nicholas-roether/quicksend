import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:quicksend/client/models.dart';
import 'package:quicksend/client/provider.dart';
import 'package:quicksend/widgets/custom_error_alert_widget.dart';
import 'package:quicksend/widgets/loading_indicator.dart';

class RegisteredDevices extends StatelessWidget {
  const RegisteredDevices({Key? key}) : super(key: key);

  String getDevice(int type) {
    switch (type) {
      case 0:
        return "unknown device";
      case 1:
        return "mobile device";
      case 2:
        return "desktop device";
      case 3:
        return "command line interface";
    }
    return type.toString();
  }

  @override
  Widget build(BuildContext context) {
    final quicksendClient = QuicksendClientProvider.get(context);
    final registeredDevices = quicksendClient.getRegisteredDevices();
    initializeDateFormatting();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Registered devices",
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
      body: Column(
        children: [
          const Text("Swipe left to remove device"),
          FutureBuilder<List<DeviceInfo>>(
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
                        "${snapshot.data![index].name} - ${getDevice(snapshot.data![index].type)}",
                        style: Theme.of(context).textTheme.bodyText1,
                      ),
                      subtitle: Text(
                        "last activity: ${DateFormat('dd.MM.yyyy EEEE', 'de').format(snapshot.data![index].lastActivity)}",
                      ),
                    ),
                  );
                },
                itemCount: snapshot.data!.length,
              );
            },
          ),
        ],
      ),
    );
  }
}
