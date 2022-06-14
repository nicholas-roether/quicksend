import 'package:flutter/cupertino.dart';

class RouteArgs<T> extends StatelessWidget {
  final Widget Function(T args) builder;

  const RouteArgs(this.builder, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as T;
    return builder(args);
  }
}
