import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expressions/expressions.dart';

final calculatorProvider = StateProvider<String>((ref) => '0');

void main() {
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        textTheme: TextTheme(
            headlineMedium: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 60,
          ),
          bodyMedium: TextStyle(fontSize: 26),
        ),
      ),
      home: CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculatorState = ref.watch(calculatorProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('CALCULATOR'),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
          child: Container(
            height: 1000,
            width: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: Colors.black,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.all(20),
                  child: Text(
                    calculatorState,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                Divider(color: Colors.grey[700]),
                _buildButtonRow(context, ref, ['AC', '+/-', '%', '÷'], Colors.grey, Colors.orange),
                _buildButtonRow(context, ref, ['7', '8', '9', '×'], Colors.grey[850]!, Colors.orange),
                _buildButtonRow(context, ref, ['4', '5', '6', '-'], Colors.grey[850]!, Colors.orange),
                _buildButtonRow(context, ref, ['1', '2', '3', '+'], Colors.grey[850]!, Colors.orange),
                _buildButtonRow(context, ref, ['0', '.', '='], Colors.grey[850]!, Colors.orange, lastRow: true),
              ],
            ),
          ),
      ),
    );
  }

  Widget _buildButtonRow(BuildContext context, WidgetRef ref, List<String> labels, Color color, Color accentColor, {bool lastRow = false}) {
    return Row(
      children: labels.map((label) {
        return CalculatorButton(
          label,
          ref,
          label == '÷' || label == '×' || label == '-' || label == '+' || label == '=' ? accentColor : color,
          isZero: lastRow && label == '0',
        );
      }).toList(),
    );
  }
}

class CalculatorButton extends ConsumerWidget {
  final String label;
  final WidgetRef ref;
  final Color color;
  final bool isZero;

  CalculatorButton(this.label, this.ref, this.color, {this.isZero = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Expanded(
      flex: isZero ? 2 : 1,
      child: Container(
        margin: EdgeInsets.all(8),
        height: 80, // Adjust height to match the circular button size
        child: ElevatedButton(
          onPressed: () => _onPressed(ref),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: isZero ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(90)) : CircleBorder(),
            padding: EdgeInsets.all(isZero ? 20 : 20),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ),
    );
  }

  void _onPressed(WidgetRef ref) {
    final currentState = ref.read(calculatorProvider.notifier).state;

    if (label == 'AC') {
      ref.read(calculatorProvider.notifier).state = '0';
    } else if (label == 'C') {
      if (currentState.length > 1) {
        ref.read(calculatorProvider.notifier).state = currentState.substring(0, currentState.length - 1);
      } else {
        ref.read(calculatorProvider.notifier).state = '0';
      }
    } else if (label == '=') {
      try {
        // Remove all occurrences of "×" and "÷" and replace them with "*", "/"
        final expression = currentState
            .replaceAll('×', '*')
            .replaceAll('÷', '/');

        // Evaluate the expression
        final result = ExpressionEvaluator().eval(Expression.parse(expression), {});
        ref.read(calculatorProvider.notifier).state = result.toString();
      } catch (e) {
        ref.read(calculatorProvider.notifier).state = 'Error';
      }
    } else {
      if (currentState == '0') {
        ref.read(calculatorProvider.notifier).state = label;
      } else {
        ref.read(calculatorProvider.notifier).state = currentState + label;
      }
    }
  }
}
