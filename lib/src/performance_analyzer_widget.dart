import 'package:flutter/widgets.dart';

import 'cpu/fps_view.dart';
import 'io/net_view.dart';
import 'memory/mem_view.dart';

class PerformanceAnalyzerWidget extends StatelessWidget {
  // Widget with the developer's app
  // the overlay will be rendered on top of this widget
  // it is required, otherwise the app you want to test will not appear
  final Widget child;

  final bool disable;

  // activateFPS is a flag to turn on/off the performance view
  final bool activateFPS;
  // scaleFPS is the scale of the performance view, default is 1.0
  final double scaleFPS;
  // alignmentFPS is the alignment of the performance view, default is Alignment.topRight
  // the options are: Alignment.topLeft, Alignment.topCenter, Alignment.topRight,
  //                  Alignment.centerLeft, Alignment.center, Alignment.centerRight
  //                  Alignment.bottomLeft, Alignment.bottomCenter, Alignment.bottomRight
  final Alignment alignmentFPS;
  // sampleSizeFPS is the number of frame timings samples stored to extrapolate the FPS
  final int sampleSizeFPS;
  // targetFrameTimeFPS is the target frame time line in FPS chart
  final Duration targetFrameTimeFPS;
  // maxBarValueFPS is the value of the max bar in the FPS bar chart
  final Duration maxBarValueFPS;
  // backgroundFPS is the background color of the FPS chart
  final Color backgroundFPS;
  // textColorFPS is the text color of the FPS chart
  final Color textColorFPS;
  // textBackgroundColorFPS is the background color of the text in the FPS chart
  // it is necessary to create a contrast between the text and chart
  final Color textBackgroundColorFPS;

  final Color chartBarsColor;

  //
  // activateMemory is a flag to turn on/off the memory view
  final bool activateMemory;
  // alignmentMemory is the alignment of the memory view, default is Alignment.topRight
  // the options are: Alignment.topLeft, Alignment.topRight
  final Alignment alignmentMemory;
  // scaleMemory is the scale of the memory view, default is 1.0
  final double scaleMemory;
  // nObjects is the number of objects to be displayed in the memory view, default is 5
  final int nObjects;
  // backgroundMemory is the background color of memory info
  final Color backgroundMemory;
  // textColorMemory is the text color of the memory info
  final Color textColorMemory;
  // textBackgroundColorMemory is the background color of the text in memory info
  // it is necessary to create a contrast between the text and background
  final Color textBackgroundColorMemory;

  //
  // activateNetwork is a flag to turn on/off the network view
  final bool activateNetwork;
  // alignmentNetwork is the alignment of the network view, default is Alignment.topLeft
  // the options are: Alignment.topLeft, Alignment.topRight, Alignment.bottomLeft, Alignment.bottomRight
  final Alignment alignmentNetwork;
  // scaleNetwork is the scale of the network view, default is 1.0
  final double scaleNetwork;
  // backgroundNetwork is the background color of the network view
  final Color backgroundNetwork;

  final Color textColorNetwork;
  final Color textBackgroundNetwork;

  // timeBox is how many seconds are going to appear in the chart
  // default is 60 seconds
  final int timeBox;

  const PerformanceAnalyzerWidget({
    super.key,
    required this.child,
    this.disable = false,
    this.activateFPS = true,
    this.scaleFPS = 1,
    this.alignmentFPS = Alignment.topRight,
    this.sampleSizeFPS = 32,
    this.targetFrameTimeFPS =
        const Duration(milliseconds: 16, microseconds: 700),
    this.maxBarValueFPS = const Duration(milliseconds: 24),
    this.backgroundFPS = const Color(0x00ffffff),
    this.textColorFPS = const Color(0xff000000),
    this.textBackgroundColorFPS = const Color(0xffffffff),
    this.chartBarsColor = const Color(0xff4caf50),
    this.activateMemory = true,
    this.alignmentMemory = Alignment.topRight,
    this.scaleMemory = 1,
    this.nObjects = 5,
    this.backgroundMemory = const Color(0x00ffff8d),
    this.textColorMemory = const Color(0xff000000),
    this.textBackgroundColorMemory = const Color(0xffffffff),
    this.activateNetwork = true,
    this.alignmentNetwork = Alignment.topLeft,
    this.scaleNetwork = 1,
    this.backgroundNetwork = const Color(0x00ffffff),
    this.textColorNetwork = const Color(0xff000000),
    this.textBackgroundNetwork = const Color(0xffffffff),
    this.timeBox = 60,
  });

  @override
  Widget build(BuildContext context) {
    if (!disable) {
      double mqWidth = MediaQuery.of(context).size.width;
      double mqHeight = MediaQuery.of(context).size.height;
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          // textDirection: TextDirection.ltr,
          children: [
            child,
            if (activateFPS)
              IgnorePointer(
                child: Stack(
                  // textDirection: TextDirection.ltr,
                  children: [
                    Positioned(
                      child: Align(
                        alignment: alignmentFPS,
                        child: Container(
                          width: (((mqWidth * 0.3) * scaleFPS) < mqWidth)
                              ? (mqWidth * 0.3) * scaleFPS
                              : mqWidth,
                          height: (((mqHeight * 0.1) * scaleFPS) < mqHeight)
                              ? (mqHeight * 0.1) * scaleFPS
                              : mqHeight,
                          color: backgroundFPS,
                          child: FpsView(
                            sampleSize: sampleSizeFPS,
                            targetFrameTime: targetFrameTimeFPS,
                            maxBarValue: maxBarValueFPS,
                            chartBackground: backgroundFPS,
                            textColor: textColorFPS,
                            textBackgroundColor: textBackgroundColorFPS,
                            chartBarsColor: chartBarsColor,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            if (activateMemory)
              IgnorePointer(
                child: Stack(
                  children: [
                    Positioned(
                      child: Align(
                        alignment: alignmentMemory,
                        child: Padding(
                          padding: EdgeInsets.only(top: mqHeight * 0.11),
                          child: Container(
                            width: (((mqWidth * 0.25) * scaleMemory) < mqWidth)
                                ? (mqWidth * 0.25) * scaleMemory
                                : mqWidth,
                            height:
                                (((mqHeight * 0.08) * scaleMemory) < mqHeight)
                                    ? (mqHeight * 0.08) * scaleMemory
                                    : mqHeight,
                            color: backgroundMemory,
                            child: MemView(
                              textColor: textColorMemory,
                              textBackgroundColor: textBackgroundColorMemory,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (activateNetwork)
              IgnorePointer(
                child: Stack(
                  children: [
                    Positioned(
                      child: Align(
                        alignment: alignmentNetwork,
                        child: Container(
                          width: (((mqWidth * 0.35) * scaleNetwork) < mqWidth)
                              ? (mqWidth * 0.35) * scaleNetwork
                              : mqWidth,
                          height:
                              (((mqHeight * 0.12) * scaleNetwork) < mqHeight)
                                  ? (mqHeight * 0.12) * scaleNetwork
                                  : mqHeight,
                          color: backgroundNetwork,
                          child: NetView(
                              textColor: textColorNetwork,
                              textBackgroundColor: textBackgroundNetwork,
                              timeBox: timeBox),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    } else {
      return child;
    }
  }
}

// class _PerformanceAnalyzerWidgetState extends State<PerformanceAnalyzerWidget> {
//   init() {
//     MemoryAllocations.instance.addListener((p0) {
//       p0.toMap().clear();
//     });
//   }

//   printValue() {
//     // final object = Object();
//     // final snapshot = HeapSnapshot.capture();
//     // final objectSize = snapshot.getObjectSize(object);
//     // print('Object size: $objectSize bytes');
//   }

//   @override
//   void initState() {
//     super.initState();
//     // init();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (widget.activateFPS) {
//       // printValue();
//       return MaterialApp(
//         home: Initialyzer(
//           child: widget.child,
//         ),
//       );
//     } else {
//       return widget.child;
//     }
//   }
// }

// class Initialyzer extends StatefulWidget {
//   final Widget child;

//   const Initialyzer({super.key, required this.child});

//   @override
//   State<Initialyzer> createState() => _InitialyzerState();
// }

// class _InitialyzerState extends State<Initialyzer> {
//   @override
//   Widget build(BuildContext context) {
//     return CustomPerformanceOverlay(
//       child: widget.child,
//     );
//   }
// }
