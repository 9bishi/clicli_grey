import 'package:clicli_grey/widgets/loading2load.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

typedef LoadMoreCallback = Future<bool> Function();

class RefreshWrapper extends StatefulWidget {
  final Widget child;
  final RefreshCallback onRefresh;
  final LoadMoreCallback onLoadMore;
  final ScrollController scrollController;

  const RefreshWrapper({
    Key? key,
    required this.child,
    required this.onRefresh,
    required this.onLoadMore,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RefreshWrapperState();
  }
}

class _RefreshWrapperState extends State<RefreshWrapper>
    with AutomaticKeepAliveClientMixin {
  final refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  bool _isLoading = false;
  bool hasError = false;
  bool hasMore = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance?.addPostFrameCallback((_) {
      refreshIndicatorKey.currentState?.show();
      _onRefresh();
      widget.scrollController.addListener(() {
        if (widget.scrollController.position.maxScrollExtent -
                widget.scrollController.position.pixels <=
            200) {
          _onLoadMore();
        }
      });
    });
  }

  Future<void> _onLoadMore() async {
    if (!hasMore || _isLoading) return;
    refreshIndicatorKey.currentState?.show();
    _isLoading = true;
    try {
      hasMore = await widget.onLoadMore();
    } catch (_) {}
    _isLoading = false;
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<void> _onRefresh() async {
    if (_isLoading) return;
    refreshIndicatorKey.currentState?.show();
    setState(() {
      _isLoading = true;
      hasError = false;
      hasMore = true;
    });
    try {
      await widget.onRefresh();
    } catch (e) {
      debugPrint('refresh error $e');
      hasError = true;
      setState(() {});
    }
    _isLoading = false;
    await Future.delayed(const Duration(milliseconds: 600));
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return RefreshIndicator(
      key: refreshIndicatorKey,
      onRefresh: _onRefresh,
      child: hasError ? errorWidget(_onRefresh) : widget.child,
    );
  }
}
