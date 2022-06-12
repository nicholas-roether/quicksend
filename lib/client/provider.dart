import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quicksend/client/quicksend_client.dart';
import 'package:quicksend/widgets/loading_indicator.dart';

class InitErrorAlert extends StatelessWidget {
  final InitErrorInfo errInfo;

  const InitErrorAlert(
    this.errInfo, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Error during intialization"),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(errInfo.error.toString()),
            const SizedBox(height: 10),
            const Text("Stacktrace:"),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(errInfo.stackTrace.toString()),
            ),
          ],
        ),
      ),
    );
  }
}

class QuicksendClientProvider extends StatefulWidget {
  final Widget child;
  final client = QuicksendClient();

  QuicksendClientProvider({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<QuicksendClientProvider> createState() =>
      _QuicksendClientProviderState();

  /// Get the global quicksend client instance
  static QuicksendClient get(BuildContext context) {
    return Provider.of<QuicksendClient>(context, listen: false);
  }
}

class InitErrorInfo {
  final Object error;
  final StackTrace stackTrace;

  const InitErrorInfo(this.error, this.stackTrace);
}

class _QuicksendClientProviderState extends State<QuicksendClientProvider> {
  bool didInit = false;
  InitErrorInfo? errorInfo;

  @override
  Widget build(BuildContext context) {
    if (errorInfo != null) return InitErrorAlert(errorInfo!);

    if (!didInit) {
      widget.client.init().then((value) {
        if (!mounted) return;
        setState(() => didInit = true);
      }).catchError((error, stackTrace) {
        setState(() {
          errorInfo = InitErrorInfo(error, stackTrace);
        });
      });
      return Scaffold(body: LoadingIndicator());
    }

    return Provider.value(
      value: widget.client,
      child: widget.child,
    );
  }
}
