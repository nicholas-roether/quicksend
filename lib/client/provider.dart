import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:quicksend/client/quicksend_client.dart';

class QuicksendClientProvider extends StatefulWidget {
  final Widget child;

  const QuicksendClientProvider({Key? key, required this.child})
      : super(key: key);

  @override
  State<QuicksendClientProvider> createState() =>
      _QuicksendClientProviderState();

  static QuicksendClient get(BuildContext context) {
    return Provider.of<QuicksendClient>(context, listen: false);
  }
}

class _QuicksendClientProviderState extends State<QuicksendClientProvider> {
  late QuicksendClient _client;
  bool didInit = false;

  @override
  void initState() {
    super.initState();
    _client = QuicksendClient();
    _client.init().then((_) => setState(() {
          didInit = true;
        }));
  }

  @override
  Widget build(BuildContext context) {
    if (!didInit) return const SizedBox();
    return Provider.value(value: _client, child: widget.child);
  }
}
