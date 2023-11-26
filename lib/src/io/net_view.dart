import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../perf_view_platform_interface.dart';

class NetView extends StatefulWidget {
  // How many seconds are going to be displayed in network view
  final int timeBox;
  final Color textColor;
  final Color textBackgroundColor;

  const NetView({
    super.key,
    required this.timeBox,
    required this.textColor,
    required this.textBackgroundColor,
  });

  @override
  State<NetView> createState() => _NetViewState();
}

class _NetViewState extends State<NetView> {
  List<List<int>> _database = [];
  int _rxMax = 0;
  int _txMax = 0;
  final _cathInfo = _InfoCather();
  bool _skippedFirstSample = false;

  @override
  void initState() {
    super.initState();
    updateNetworkInfo();
  }

  @override
  Widget build(BuildContext context) {
    return _NetworkChart(
      database: _database,
      rxMax: _rxMax,
      txMax: _txMax,
      timeBox: widget.timeBox,
      textColor: widget.textColor,
      textBackgroundColor: widget.textBackgroundColor,
    );
  }

  Future<void> getNetworkInfo() async {
    if (!mounted) return;

    List<Object?>? networkInfo;
    final List<List<int>> dataAux = _database;
    int rxMax = _rxMax;
    int txMax = _txMax;

    try {
      networkInfo = await _cathInfo.getNetworkInfo();
      if (!_skippedFirstSample) {
        networkInfo = [1, 1];
        _skippedFirstSample = true;
      }
    } on PlatformException {
      networkInfo = <int>[-1, -1];
    }
    // add the new values to the list of data
    dataAux.insert(0, [
      int.tryParse(networkInfo![0].toString())!,
      int.tryParse(networkInfo[1].toString())!,
    ]);
    // dataAux.add([
    //   int.tryParse(networkInfo![0].toString())!,
    //   int.tryParse(networkInfo[1].toString())!,
    // ]);

    if (dataAux.length >= widget.timeBox) {
      // if database has more elements than must be shown,
      // remove the last in line
      dataAux.removeLast();
      // dataAux.removeAt(0);
      rxMax = 0;
      txMax = 0;
    }

    // go every element in database to calculate the highest
    for (int i = 0; i < dataAux.length; i++) {
      // for (int i = dataAux.length; i > 0; i--) {
      if (dataAux[i][0] > rxMax) {
        rxMax = dataAux[i][0];
      }
      if (dataAux[i][1] > txMax) {
        txMax = dataAux[i][1];
      }
    }

    setState(() {
      _database = dataAux;
      _rxMax = rxMax;
      _txMax = txMax;
    });
  }

  void updateNetworkInfo() {
    getNetworkInfo();
    Future.delayed(const Duration(seconds: 1), () => updateNetworkInfo());
  }
}

class _InfoCather {
  Future<List<Object?>?> getNetworkInfo() {
    return PerfViewPlatform.instance.getNetworkInfo();
  }
}

class _NetworkChart extends StatelessWidget {
  const _NetworkChart({
    required this.database,
    required this.rxMax,
    required this.txMax,
    required this.timeBox,
    required this.textColor,
    required this.textBackgroundColor,
  });

  final List<List<int>> database;
  final int rxMax;
  final int txMax;
  final int timeBox;
  final Color textColor;
  final Color textBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox.expand(
          child: CustomPaint(
            painter: _NetworkPainter(
              database,
              rxMax,
              txMax,
              timeBox,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: "UP ${database.first[1]} K "),
                  TextSpan(text: ": max $txMax K"),
                  // TextSpan(text: "RX MAX ${database.first[1]} K"),
                ],
                style: TextStyle(
                  fontSize: 11,
                  color: textColor,
                  backgroundColor: textBackgroundColor,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: "DOWN ${database.first[0]} K "),
                  TextSpan(text: ": max $rxMax K"),
                  // TextSpan(text: "RX MAX ${database.first[1]} K"),
                ],
                style: TextStyle(
                  fontSize: 11,
                  color: textColor,
                  backgroundColor: textBackgroundColor,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NetworkPainter extends CustomPainter {
  final List<List<int>> _netData;
  final int _maxRx;
  final int _maxTx;
  final int _timeBox;

  _NetworkPainter(
    this._netData,
    this._maxRx,
    this._maxTx,
    this._timeBox,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // the center of the chart
    final centerDivision = size.height / 2;
    canvas.drawLine(
      Offset(0, centerDivision),
      Offset(size.width, centerDivision),
      Paint()..color = const Color(0x80000000),
    );

    final barWidth = size.width / _timeBox;
    final txPaint = Paint()..color = const Color(0xFFFF9800);
    final rxPaint = Paint()..color = const Color(0xFF2196F3);
    for (var i = _timeBox - 1; i >= 0; i--) {
      final shifted = i - _timeBox + _netData.length;
      if (shifted < 0) break;
      final rxValue = _netData[shifted][0];
      final txValue = _netData[shifted][1];

      final x = barWidth * i;
      final rxBarExtent = rxValue / _maxRx;
      final txBarExtent = txValue / _maxTx;

      // Draw Tx line(up half of chart)
      canvas.drawRect(
        Rect.fromLTWH(x, centerDivision * (1 - txBarExtent), barWidth,
            centerDivision * txBarExtent),
        txPaint,
      );

      // Draw Rx line(down half of chart)
      canvas.drawRect(
        Rect.fromLTWH(
            x, centerDivision, barWidth, centerDivision * rxBarExtent),
        rxPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_NetworkPainter oldDelegate) {
    return oldDelegate._netData != _netData;
  }
}
