import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quicksend/utils/utils.dart';

class LoadingIndicator extends StatelessWidget {
  LoadingIndicator({
    Key? key,
  }) : super(key: key);
  final List<String> quips = [
    "Refactoring the whole database...",
    "Generating your chatlist...",
    "Getting things ready...",
    "Driving out the bugs...",
    "Cleaning out sand grains...",
    "Downloading more RAM...",
    "Coming up with loading quips...",
    "Fastening screws and bolts...",
    "Warming up...",
    "Powering up engines...",
    "Calculating the meaning of life...",
    "Processing some data...",
    "Deploying nanomachines...",
    "Computing all whole numbers...",
    "Instigating bit flips...",
    "Invoking dark magic...",
    "Stitching neural nets...",
    "Rubbing CPU cores together...",
    "Disabling safety features...",
    "Sending data through time...",
    "Removing dust...",
    "Performing fancy calculations...",
    "Applying hot glue...",
    "Securing parts with tape...",
    "Engaging redundant mechanisms...",
    "Locating the start button...",
    "Clearing error logs..."
  ];

  Stream<String> _getQuips() async* {
    final Iterable<int> randIndecies = Utils.randomIndecies(quips.length);
    for (int index in randIndecies) {
      yield quips[index];
      await Future.delayed(const Duration(seconds: 3));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/img/loading_anim.gif",
            scale: 8,
          ),
          StreamBuilder<String>(
            initialData: quips[0],
            builder: (context, snapshot) {
              return Text(
                snapshot.data.toString(),
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              );
            },
            stream: _getQuips(),
          ),
        ],
      ),
    );
  }
}
