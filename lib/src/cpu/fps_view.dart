import 'dart:math';
import 'dart:ui';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class FpsView extends StatefulWidget {
  // sampleSize is the number of frame timings samples stored to extrapolate the FPS
  // default is 32
  final int sampleSize;

  // targetFrameTime is the target frame time line
  // default is 16.7ms (60 FPS)
  // every frame that takes longer than targetFrameTime will be rendered as a red bar
  // if you want to render at 120 FPS, set targetFrameTime to 8.3ms and maxBarValue to 12.5ms
  final Duration targetFrameTime;

  // maxBarValue is the value of the max bar in the bar chart
  // default is 24.0ms (41 FPS) and the min value is 0
  // if you want to render at 120 FPS, change this value to 12.5ms or close
  final Duration maxBarValue;

  // background is the background color of the performance view
  // default is Colors.white
  final Color chartBackground;

  // textColor is the text color of the performance view
  // default is Colors.black
  final Color textColor;

  // textBackgroundColor is the background color of the text in the performance view
  final Color textBackgroundColor;

  final Color chartBarsColor;

  const FpsView({
    super.key,
    required this.sampleSize,
    required this.targetFrameTime,
    required this.maxBarValue,
    required this.chartBackground,
    required this.textColor,
    required this.textBackgroundColor,
    required this.chartBarsColor,
  });

  @override
  State<FpsView> createState() => _FpsViewState();
}

class _FpsViewState extends State<FpsView> {
  List<FrameTiming> _samples = <FrameTiming>[];
  bool _skippedFirstSample = false;

  void _onTimingsCallback(List<FrameTiming> timings) {
    if (!mounted) return;
    if (!_skippedFirstSample) {
      timings = timings.sublist(1);
      _skippedFirstSample = true;
    }
    final combinedSamples = [
      ..._samples,
      ...timings,
    ];
    SchedulerBinding.instance.addPostFrameCallback((timestamp) {
      if (!mounted) return;
      setState(() {
        _samples = combinedSamples.sublist(
          max(0, combinedSamples.length - widget.sampleSize),
        );
        assert(_samples.length <= widget.sampleSize);
      });
    });
  }

  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addTimingsCallback(_onTimingsCallback);
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_onTimingsCallback);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: widget.textColor,
      fontSize: 13,
      backgroundColor: widget.textBackgroundColor,
    );

    return _PerformanceChart(
      samples: [for (final e in _samples) e.totalSpan],
      sampleSize: widget.sampleSize,
      targetFrameTime: widget.targetFrameTime,
      barRangeMax: widget.maxBarValue,
      color: widget.chartBarsColor,
      textStyle: textStyle,
    );
  }
}

class _PerformanceChart extends StatelessWidget {
  const _PerformanceChart({
    Key? key,
    required this.samples,
    required this.sampleSize,
    required this.targetFrameTime,
    required this.barRangeMax,
    required this.color,
    required this.textStyle,
  })  : assert(samples.length <= sampleSize),
        super(key: key);

  /// The duration samples.
  final List<Duration> samples;

  // Max number of samples
  final int sampleSize;

  // The number of FPS you want to achive
  final Duration targetFrameTime;

  // Max value in ms the bar representing a frame can be
  final Duration barRangeMax;

  /// The bar color.
  final Color color;

  /// The text style used for the written stats.
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    var maxDuration = Duration.zero;
    var cumulative = Duration.zero;
    for (var i = 0; i < samples.length; i++) {
      final sample = samples[i];
      maxDuration = sample > maxDuration ? sample : maxDuration;
      cumulative += sample;
    }
    final avg = samples.isEmpty
        ? Duration.zero
        : Duration(microseconds: cumulative.inMicroseconds ~/ samples.length);
    final fps = samples.isEmpty ? 0 : 1e6 / avg.inMicroseconds;

    return Stack(
      children: [
        SizedBox.expand(
          child: CustomPaint(
            painter: _OverlayPainter(
              samples,
              sampleSize,
              targetFrameTime,
              barRangeMax,
              color,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: RichText(
              text: TextSpan(
                children: [
                  // TextSpan(
                  //   text: 'max ${maxDuration.ms}ms\n',
                  //   // style: TextStyle(
                  //   //   color: maxDuration <= targetFrameTime ? null : Colors.red,
                  //   // ),
                  // ),
                  // TextSpan(
                  //   text: 'avg ${avg.ms}ms\n',
                  //   // style: TextStyle(
                  //   //   color: avg <= targetFrameTime ? null : Colors.red,
                  //   // ),
                  // ),
                  TextSpan(
                    text: '${fps.toStringAsFixed(1)} FPS',
                    style: TextStyle(
                      color: fps >=
                              const Duration(milliseconds: 1000) /
                                  targetFrameTime
                          ? null
                          : const Color(0xffff0000),
                      fontSize: 22,
                      // backgroundColor: Colors.white70,
                    ),
                  ),
                ],
                style: textStyle,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OverlayPainter extends CustomPainter {
  _OverlayPainter(
    this.samples,
    this.sampleSize,
    this.targetFrameTime,
    this.barRangeMax,
    this.color,
  );

  final List<Duration> samples;
  final int sampleSize;
  final Duration targetFrameTime;
  final Duration barRangeMax;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final aimHeight = size.height * (1 - targetFrameTime / barRangeMax);
    canvas.drawLine(
      Offset(0, aimHeight),
      Offset(size.width, aimHeight),
      Paint()..color = const Color(0x80000000),
    );

    final barWidth = size.width / sampleSize;
    final paint = Paint()..color = color;
    for (var i = sampleSize - 1; i >= 0; i--) {
      final shifted = i - sampleSize + samples.length;
      // print("samples size = ${samples.length}\n");
      if (shifted < 0) break;
      final timing = samples[shifted];

      final x = barWidth * i;
      final barExtent = timing / barRangeMax;
      canvas.drawRect(
        Rect.fromLTWH(x, size.height * (1 - barExtent), barWidth,
            size.height * barExtent),
        timing <= targetFrameTime
            ? paint
            : (Paint()..color = const Color(0x80ff0000)),
      );
    }
  }

  @override
  bool shouldRepaint(_OverlayPainter oldDelegate) {
    // Using object equality here rather than list equality because it is
    // cheaper and we *know* that the contents are different when the objects
    // are not equal because above, we are reassigning the samples list
    // whenever new timings are reported.
    return oldDelegate.samples != samples;
  }
}

extension on Duration {
  double operator /(Duration other) => inMicroseconds / other.inMicroseconds;

  /// The duration in milliseconds as a string with 1 decimal place.
  String get ms => (inMicroseconds / 1e3).toStringAsFixed(1);
}
