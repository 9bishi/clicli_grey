import 'package:flutter/material.dart';

final loadingWidget = Image.asset(
  'assets/loading.gif',
  width: 150,
  height: 150,
);

Widget errorWidget(VoidCallback retryFn) {
  return Center(
    child: ElevatedButton(
      child: const Text('java.lang.Error: FATAL EXCEPTION'),
      onPressed: retryFn,
    ),
  );
}

typedef _AsyncWidgetBuilder<T> = Widget Function(
    BuildContext context, T snapshot);

class Loading2Load<T> extends StatelessWidget {
  const Loading2Load({required this.builder, required this.load, Key? key})
      : super(key: key);

  final Future<T> Function() load;
  final _AsyncWidgetBuilder<T?> builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: load(),
      builder: (_, __) {
        switch (__.connectionState) {
          case ConnectionState.active:
          case ConnectionState.waiting:
            return Center(child: loadingWidget);
          case ConnectionState.done:
            if (__.hasError) return errorWidget(load);
            return builder(_, __.data);
          default:
            return Container();
        }
      },
    );
  }
}
