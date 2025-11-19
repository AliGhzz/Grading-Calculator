import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Grading Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const CalculatorPage(),
    );
  }
}

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  // mode: true => add (default), false => subtract
  bool _isAddMode = true;

  // store signed entries
  final List<double> _entries = [];

  double get _total =>
      _entries.fold(0.0, (previousValue, element) => previousValue + element);

  final ScrollController _scrollController = ScrollController();


  // generate 20 values between 1.00 and 5.00 inclusive (linear spacing)
  late final List<double> _values = List<double>.generate(20, (i) {
    final step = 0.25;
    final v = 0.25 + i * step;
    return double.parse(v.toStringAsFixed(2));
  });

  String _fmt(double v) {
    final s = v.toStringAsFixed(2);
    if (s.endsWith('.00')) return s.substring(0, s.length - 3);
    if (s.endsWith('0')) return s.substring(0, s.length - 1);
    return s;
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onNumberPressed(double value) {
    setState(() {
      final signed = _isAddMode ? value : -value;
      _entries.add(signed);
    });
    _scrollToEnd();
  }

  void _deleteLast() {
    setState(() {
      if (_entries.isNotEmpty) _entries.removeLast();
    });
    _scrollToEnd();
  }

  void _clearAll() {
    setState(() {
      _entries.clear();
    });
    _scrollToEnd();
  }


  void _setAddMode() {
    setState(() {
      _isAddMode = true;
    });
  }

  void _setSubtractMode() {
    setState(() {
      _isAddMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Grading Calculator',style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF1E1E1E),
        toolbarHeight: 50,
      ),
      body: Column(
        children: [
          // Display area
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  // total big
                  Expanded(
                    child: Center(
                      child: Text(
                        _fmt(_total),
                        style: const TextStyle(
                          fontSize: 72,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // entries list (small)
                  SizedBox(
                    height: 50 ,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      child: Row(
                        children: _entries.map((e) {
                          final sign = e >= 0 ? '+' : '−';
                          return Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(150),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$sign${_fmt(e.abs())}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Buttons area: fixed 400 height, 4 columns (6 rows => 24 buttons)
          SizedBox(
            height: 450, 
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 3, 8.0, 8.0),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 4 buttons per row
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  mainAxisExtent: 64, // fit 6 rows into ~400 height
                ),
                itemCount: 24, // 4 control buttons + 20 number buttons
                itemBuilder: (context, index) {
                  // first row (0..3): C, DEL, +, -
                  if (index == 0) {
                    return CustomButton(
                      color: Colors.blue,
                      label: 'C',
                      textColor: Colors.white,
                      fontSize: 20.0,
                      onTapped: _clearAll,
                    );
                  } else if (index == 1) {
                    return CustomButton(
                      color: Colors.red,
                      label: 'DEL',
                      textColor: Colors.white,
                      fontSize: 16.0,
                      onTapped: _deleteLast,
                    );
                  } else if (index == 2) {
                    return CustomButton(
                      color: Colors.green,
                      label: '+',
                      textColor: Colors.white,
                      fontSize: 20.0,
                      onTapped: _setAddMode,
                    );
                  } else if (index == 3) {
                    return CustomButton(
                      color: Colors.orange,
                      label: '−',
                      textColor: Colors.white,
                      fontSize: 20.0,
                      onTapped: _setSubtractMode,
                    );
                  }

                  // remaining indices 4..23 -> map to 20 numeric buttons (0..19)
                  final numberIndex = index - 4;
                  if (numberIndex >= 0 && numberIndex < _values.length) {
                    final v = _values[numberIndex];
                    return CustomButton(
                      color: Colors.grey[200]!,
                      label: _fmt(v),
                      textColor: Colors.black,
                      fontSize: 18.0,
                      onTapped: () => _onNumberPressed(v),
                    );
                  }

                  // fallback (shouldn't hit)
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Simple no-hover button
class CustomButton extends StatelessWidget {
  final Color color;
  final String label;
  final Color textColor;
  final VoidCallback? onTapped;
  final double fontSize;

  const CustomButton({
    super.key,
    required this.color,
    required this.label,
    required this.textColor,
    this.onTapped,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapped,
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
