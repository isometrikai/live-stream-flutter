part of '../stream_view.dart';

class _TopDarkGradient extends StatelessWidget {
  const _TopDarkGradient();

  @override
  Widget build(BuildContext context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: MediaQuery.of(context).size.height * 0.3,
        child: const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black38,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      );
}

class _BottomDarkGradient extends StatelessWidget {
  const _BottomDarkGradient();

  @override
  Widget build(BuildContext context) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        height: MediaQuery.of(context).size.height * 0.3,
        child: const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black38,
                ],
              ),
            ),
          ),
        ),
      );
}