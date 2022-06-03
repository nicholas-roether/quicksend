import 'package:flutter/material.dart';
import 'package:quicksend/client/models.dart';

class MessageBox extends StatelessWidget {
  const MessageBox({Key? key, required this.message}) : super(key: key);
  final Message message;

  Widget messageBoxContent(context) {
    switch (message.type) {
      case "text/plain":
        /*if (message.state == MessageState.sending) {
          return SkeletonParagraph(
            style: SkeletonParagraphStyle(
              lines: 1,
              lineStyle: SkeletonLineStyle(
                width: message.asString().length.toDouble(),
                alignment: Alignment.bottomRight,
              ),
            ),
          );
        }*/
        if (message.state == MessageState.sent) {
          return Text(
            message.asString(),
            style: Theme.of(context)
                .textTheme
                .bodyText1
                ?.copyWith(color: Colors.black),
          );
        }
        break;
      case "image/jpeg":
        return Image.memory(
          message.content,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          scale: 2.0,
          errorBuilder: (context, error, stackTrace) {
            return const Text("Couldn't load Image!");
          },
        );
      case "image/png":
        return Image.memory(
          message.content,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          scale: 2.0,
          errorBuilder: (context, error, stackTrace) {
            return const Text("Couldn't load Image!");
          },
        );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message.asString(),
          style: Theme.of(context).textTheme.bodyText1?.copyWith(
                color: Colors.black,
              ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 8.0),
          child: SizedBox(
            height: 10,
            width: 10,
            child: CircularProgressIndicator(
              color: Colors.black,
              strokeWidth: 1,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.direction == MessageDirection.outgoing
          ? const Alignment(1.0, 1.0)
          : const Alignment(-1.0, 1.0),
      child: Card(
        elevation: 2,
        color: message.direction == MessageDirection.outgoing
            ? Theme.of(context).primaryColor
            : Theme.of(context).secondaryHeaderColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: messageBoxContent(context),
        ),
      ),
    );
  }
}
