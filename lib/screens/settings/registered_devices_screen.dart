import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:quicksend/client/models.dart';
import 'package:quicksend/client/provider.dart';
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
      body: FutureBuilder<List<DeviceInfo>>(
        future: registeredDevices,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return LoadingIndicator();
          }
          return ListView.builder(
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                  "${snapshot.data![index].name} - ${getDevice(snapshot.data![index].type)}",
                  style: Theme.of(context).textTheme.bodyText1,
                ),
                subtitle: Text(
                  "last activity: ${DateFormat('dd.MM.yyyy EEEE', 'de').format(snapshot.data![index].lastActivity)}",
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
