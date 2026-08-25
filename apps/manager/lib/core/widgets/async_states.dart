// Epic 08 task 08.8 -- the three states every data-backed screen has.
//
// Two product rules drive the whole file (apps/manager/AGENTS.md):
//
//   "No spinner without a skeleton. No error without a retry. Mess wifi is
//    bad and users blame the app, not the network."
//
//   "A zero-exception day must look FINISHED, not empty."
//
// The second is the one most likely to be quietly undone. An empty state is
// normally an apology for missing content; here, the emptiest day is the
// product working perfectly, and it has to read that way.

import 'package:flutter/material.dart';

import '../api/api_error.dart';
import '../i18n/l10n/app_localizations.dart';
import '../theme/tokens.g.dart';

/// A grey block standing in for content that has not arrived.
///
/// A skeleton rather than a spinner because a spinner says "wait, with no
/// idea how long"; a skeleton says "this shape, shortly" and stops the
/// layout jumping when the real content lands.
class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.height = 16,
    this.width,
    this.borderRadius = TinBelaRadius.chip,
  });

  final double height;
  final double? width;
  final double borderRadius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Opacity only: no blur, no gradient sweep. This has to hold 60fps on a
    // four-year-old mid-range Android, and a shimmer gradient is the most
    // common reason a list does not.
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 0.85).animate(_controller),
      child: Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: TinBelaColors.divider,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

/// A few skeleton lines in the shape of a list.
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.rows = 3});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: TinBelaSpace.md),
            child: Row(
              children: [
                const Skeleton(height: 40, width: 40, borderRadius: 20),
                const SizedBox(width: TinBelaSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Uneven widths: rows of identical bars read as a
                      // loading bar, not as content arriving.
                      Skeleton(width: i.isEven ? 140 : 180),
                      const SizedBox(height: TinBelaSpace.sm),
                      const Skeleton(height: 12, width: 90),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// A failure, with a way out of it.
///
/// [error] is an [ApiException] where one is available: its message is
/// already localised by the server (docs/eng/errors.md), and rendering that
/// beats inventing a second vocabulary in the client.
class ErrorState extends StatelessWidget {
  const ErrorState({super.key, this.error, this.onRetry});

  final ApiException? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final err = error;

    final message = switch (err) {
      null => l.errorGeneric,
      _ when err.code == ApiErrorCode.unavailable => l.errorOffline,
      _ when err.message.isNotEmpty => err.message,
      _ => l.errorGeneric,
    };

    // A retry button on "you are not the manager" is a lie. Only offer it
    // where trying again could actually work.
    final canRetry = onRetry != null && (err?.isRetryable ?? true);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TinBelaSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: TinBelaColors.ink),
            ),
            if (err?.requestId != null) ...[
              const SizedBox(height: TinBelaSpace.sm),
              Text(
                l.errorRequestId(err!.requestId!),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: TinBelaColors.inkMuted,
                ),
              ),
            ],
            if (canRetry) ...[
              const SizedBox(height: TinBelaSpace.lg),
              // One-handed, in sunlight, possibly standing up.
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: TinBelaTouch.min,
                  minWidth: TinBelaTouch.min,
                ),
                child: FilledButton(
                  onPressed: onRetry,
                  style: FilledButton.styleFrom(
                    backgroundColor: TinBelaColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(TinBelaRadius.button),
                    ),
                  ),
                  child: Text(l.retry),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// The state that means FINISHED.
///
/// Defaults to the zero-exception day, because that is the state this app
/// exists to produce and the one a manager sees most often. It is a success
/// message, not an apology for an empty list -- UX law 5, and the exact
/// wording is a product rule, not a placeholder.
class FinishedState extends StatelessWidget {
  const FinishedState({super.key, this.headline, this.detail});

  final String? headline;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(TinBelaSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              headline ?? l.nothingToDo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: TinBelaColors.ink,
              ),
            ),
            const SizedBox(height: TinBelaSpace.sm),
            Text(
              detail ?? l.allOnDefault,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: TinBelaColors.inkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Confirmation is a toast; dialogs are only for irreversible actions
/// (apps/manager/AGENTS.md). This is the toast.
void showToast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: TinBelaColors.ink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TinBelaRadius.button),
        ),
      ),
    );
}

/// Picks the right state for one async value, so no screen has to remember
/// the rules. `AsyncStateView` is the only place a screen should branch on
/// loading versus error versus data.
class AsyncStateView<T> extends StatelessWidget {
  const AsyncStateView({
    super.key,
    required this.snapshot,
    required this.builder,
    this.onRetry,
    this.skeleton,
  });

  final AsyncSnapshot<T> snapshot;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback? onRetry;
  final Widget? skeleton;

  @override
  Widget build(BuildContext context) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Padding(
        padding: const EdgeInsets.all(TinBelaSpace.lg),
        child: skeleton ?? const SkeletonList(),
      );
    }
    if (snapshot.hasError) {
      final error = snapshot.error;
      return ErrorState(
        error: error is ApiException ? error : null,
        onRetry: onRetry,
      );
    }
    final data = snapshot.data;
    if (data == null) {
      return const FinishedState();
    }
    return builder(context, data);
  }
}
