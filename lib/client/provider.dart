import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:quicksend/client/quicksend_client.dart';

class QuicksendClientProvider extends StatelessWidget {
  final Widget child;
  final QuicksendClient client;

  const QuicksendClientProvider({
    Key? key,
    required this.child,
    required this.client,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider.value(
      value: client,
      child: child,
    );
  }

  /// Get the global quicksend client instance
  static QuicksendClient get(BuildContext context) {
    return Provider.of<QuicksendClient>(context, listen: false);
  }
}
