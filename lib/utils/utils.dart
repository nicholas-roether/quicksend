import 'dart:math';

class Utils {
  static Iterable<int> randomIndecies(int length) sync* {
    final random = Random();
    int current = random.nextInt(length);
    while (true) {
      int randInt = random.nextInt(length - 1);
      current = randInt < current ? randInt : randInt + 1;
      yield current;
    }
  }
}
