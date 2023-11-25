import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../perf_view_platform_interface.dart';

class MemView extends StatefulWidget {
  final Color textColor;
  final Color textBackgroundColor;

  const MemView({
    super.key,
    required this.textColor,
    required this.textBackgroundColor,
  });

  @override
  State<MemView> createState() => _MemViewState();
}

class _InfoCather {
  Future<List<Object?>?> getMemoryInfo() {
    return PerfViewPlatform.instance.getMemoryInfo();
  }
}

class _MemViewState extends State<MemView> {
  double _total = 0;
  double _used = 0;
  double _free = 0;

  final _cathInfo = _InfoCather();

  @override
  void initState() {
    super.initState();
    updateMemInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _MemInfo(
      used: _used,
      free: _free,
      total: _total,
      textColor: widget.textColor,
      textBackgroundColor: widget.textBackgroundColor,
    );
  }

  Future<void> getMemInfo() async {
    if (!mounted) return;

    List<Object?>? memInfo;

    try {
      memInfo = await _cathInfo.getMemoryInfo();
    } on PlatformException {
      memInfo = <int>[-1, -1];
    }

    setState(() {
      _total = (int.tryParse(memInfo![0].toString())!) / 1024;
      _free = (int.tryParse(memInfo[1].toString())!) / 1024;
      _used = _total - _free;
    });
  }

  void updateMemInfo() {
    getMemInfo();
    Future.delayed(const Duration(seconds: 1), () => updateMemInfo());
  }
}

class _MemInfo extends StatelessWidget {
  final double used;
  final double free;
  final double total;
  final Color textColor;
  final Color textBackgroundColor;

  const _MemInfo({
    required this.used,
    required this.free,
    required this.total,
    required this.textColor,
    required this.textBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(text: "Mem\n", style: TextStyle(fontSize: 10)),
                  TextSpan(text: "Total: ${total.toStringAsFixed(2)}G\n"),
                  TextSpan(text: "Used: ${used.toStringAsFixed(2)}G\n"),
                  TextSpan(text: "Free: ${free.toStringAsFixed(2)}G"),
                ],
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
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
