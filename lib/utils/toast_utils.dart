import 'package:fluttertoast/fluttertoast.dart';

void showSnackBar(String text, {ToastGravity gravity = ToastGravity.BOTTOM}) {
  Fluttertoast.showToast(msg: text, gravity: gravity);
}

void showErrorSnackBar(String text) {
  Fluttertoast.showToast(msg: text);
}

void cancelSnackBar() {
  Fluttertoast.cancel();
}
