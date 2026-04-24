import 'package:flutter/material.dart';
import '../models/calculator_mode.dart';
import '../models/calculator_settings.dart';
import 'calculator_button.dart';

class ButtonGrid extends StatelessWidget {
  final CalculatorMode mode;
  final AngleMode angleMode;
  final bool isSecondFunction;
  final void Function(String) onButtonPressed;
  final VoidCallback? onClearHistory;

  const ButtonGrid({
    super.key,
    required this.mode,
    required this.angleMode,
    required this.isSecondFunction,
    required this.onButtonPressed,
    this.onClearHistory,
  });

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case CalculatorMode.basic:
        return _buildBasicGrid(context);
      case CalculatorMode.scientific:
        return _buildScientificGrid(context);
      case CalculatorMode.programmer:
        return _buildProgrammerGrid(context);
    }
  }

  Widget _buildBasicGrid(BuildContext context) {
    final rows = [
      ['MC', 'MR', 'M-', 'M+'],
      ['C', '⌫', '%', '÷'],
      ['7', '8', '9', '×'],
      ['4', '5', '6', '−'],
      ['1', '2', '3', '+'],
      ['±', '0', '.', '='],
    ];

    return Column(
      children: [
        for (List<String> row in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              children: [
                for (String btn in row)
                  Expanded(child: _buildButton(context, btn)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildScientificGrid(BuildContext context) {
    final buttons = [
      ['2nd', 'sin', 'cos', 'tan', 'ln', 'log'],
      ['x²', '√', 'xʸ', '(', ')', '÷'],
      ['MC', '7', '8', '9', 'C', '×'],
      ['MR', '4', '5', '6', 'CE', '−'],
      ['M+', '1', '2', '3', '%', '+'],
      ['M-', '±', '0', '.', 'π', '='],
    ];

    return Column(
      children: [
        for (List<String> row in buttons)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                for (String btn in row)
                  Expanded(child: _buildScientificButton(context, btn)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildProgrammerGrid(BuildContext context) {
    final buttons = [
      ['BIN', 'OCT', 'DEC', 'HEX', 'AC'],
      ['AND', 'OR', 'XOR', '<<', '>>'],
      ['7', '8', '9', 'A', 'B'],
      ['4', '5', '6', 'C', 'D'],
      ['1', '2', '3', 'E', 'F'],
      ['0', 'CE', '=', '−', '×'],
      ['÷', '+', 'NOT', '', ''],
    ];

    return Column(
      children: [
        for (List<String> row in buttons)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                for (String btn in row)
                  Expanded(
                    child: btn.isEmpty
                        ? const SizedBox()
                        : _buildProgrammerButton(context, btn),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildScientificButton(BuildContext context, String label) {
    CalcButtonType type;

    switch (label) {
      case 'C':
        type = CalcButtonType.clear;
        break;
      case '=':
        type = CalcButtonType.equals;
        break;
      case '÷':
      case '×':
      case '−':
      case '+':
      case '%':
        type = CalcButtonType.operator;
        break;
      case '⌫':
      case 'CE':
      case '±':
      case 'DEG':
      case '2nd':
        type = CalcButtonType.function;
        break;
      case '(':
      case ')':
        type = CalcButtonType.parenthesis;
        break;
      default:
        type = CalcButtonType.number;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: CalculatorButton(
        label: label,
        type: type,
        onPressed: () => onButtonPressed(label),
        onLongPress: label == 'C' && onClearHistory != null
            ? onClearHistory!
            : null,
      ),
    );
  }

  Widget _buildProgrammerButton(BuildContext context, String label) {
    CalcButtonType type;

    switch (label) {
      case 'AC':
        type = CalcButtonType.clear;
        break;
      case '=':
        type = CalcButtonType.equals;
        break;
      case '÷':
      case '×':
      case '−':
      case '+':
        type = CalcButtonType.operator;
        break;
      case '⌫':
      case 'CE':
      case 'NOT':
      case 'AND':
      case 'OR':
      case 'XOR':
      case '<<':
      case '>>':
        type = CalcButtonType.function;
        break;
      default:
        type = CalcButtonType.number;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: CalculatorButton(
        label: label,
        type: type,
        onPressed: () => onButtonPressed(label),
        onLongPress: label == 'AC' && onClearHistory != null
            ? onClearHistory!
            : null,
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label) {
    CalcButtonType type;

    switch (label) {
      case 'C':
        type = CalcButtonType.clear;
        break;
      case '=':
        type = CalcButtonType.equals;
        break;
      case '÷':
      case '×':
      case '−':
      case '+':
      case '%':
        type = CalcButtonType.operator;
        break;
      case '⌫':
      case 'CE':
      case '±':
      case 'DEG':
        type = CalcButtonType.function;
        break;
      case '(':
      case ')':
        type = CalcButtonType.parenthesis;
        break;
      default:
        type = CalcButtonType.number;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: CalculatorButton(
        label: label,
        type: type,
        onPressed: () => onButtonPressed(label),
        onLongPress: label == 'C' && onClearHistory != null
            ? onClearHistory!
            : null,
      ),
    );
  }
}
