import 'package:flutter/material.dart';
import '../data/deck_store.dart';

/// Wraps a scrollable in the standard pull-to-refresh gesture.
///
/// There is no server to re-fetch from yet, so a pull re-reads the in-memory
/// store and rebuilds. That still matters: it is the gesture people reach for
/// when a screen looks stale, and it gives every list a consistent, working
/// response instead of nothing happening.
class Refreshable extends StatelessWidget {
  const Refreshable({super.key, required this.child, this.onRefresh});

  final Widget child;

  /// Extra work to do on pull, before the rebuild is signalled.
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await onRefresh?.call();
        // Brief pause so the spinner is legible rather than flashing.
        await Future<void>.delayed(const Duration(milliseconds: 400));
        DeckStore.revision.value++;
      },
      child: child,
    );
  }
}
