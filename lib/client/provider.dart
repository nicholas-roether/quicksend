import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:quicksend/client/quicksend_client.dart';

class QuicksendClientProvider extends StatelessWidget {
  final Widget child;
  final _client = QuicksendClient();

  QuicksendClientProvider({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _client.init(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox();
        }
        return Provider<QuicksendClient>.value(
          value: _client,
          child: child,
        );
      },
    );
  }

  static QuicksendClient get(BuildContext context) {
    return Provider.of<QuicksendClient>(context, listen: false);
  }
}
