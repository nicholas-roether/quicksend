import 'package:flutter/material.dart';
import 'package:quicksend/client/models.dart';
import 'package:quicksend/widgets/image_box_widget.dart';

class MessageBox extends StatelessWidget {
  const MessageBox({Key? key, required this.message}) : super(key: key);
  final Message message;

  Widget messageBoxContent(context) {
    switch (message.type) {
      case "text/plain":
        if (message.state == MessageState.sent) {
          return Text(
            message.asString(),
            style: Theme.of(context)
                .textTheme
                .bodyText1
                ?.copyWith(color: Colors.black),
          );
        } else if (message.state == MessageState.sending) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.asString(),
                style: Theme.of(context)
                    .textTheme
                    .bodyText1
                    ?.copyWith(color: Colors.black),
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
        break;
      case "image/jpeg":
        if (message.state == MessageState.sent) {
          return ImageBoxWidget(byteImage: message.content);
        } else if (message.state == MessageState.sending) {
          return const SizedBox(
            height: 200,
            width: 200,
            child: CircularProgressIndicator(
              color: Colors.black,
            ),
          );
        }
        break;
      case "image/png":
        if (message.state == MessageState.sent) {
          return ImageBoxWidget(byteImage: message.content);
        } else if (message.state == MessageState.sending) {
          return const SizedBox(
            height: 200,
            width: 200,
            child: CircularProgressIndicator(
              color: Colors.black,
            ),
          );
        }
    }
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.direction == MessageDirection.outgoing
          ? const Alignment(1.0, 1.0)
          : const Alignment(-1.0, 1.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Card(
          elevation: 2,
          color: message.direction == MessageDirection.outgoing
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.secondary,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: messageBoxContent(context),
          ),
        ),
      ),
    );
  }
}
