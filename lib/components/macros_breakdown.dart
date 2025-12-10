import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show ColorScheme;
import 'package:nutrition/components/macro_circle.dart';

class MacrosBreakdown extends StatelessWidget {
  const MacrosBreakdown({
    super.key,
    required this.protein,
    required this.proteinGoal,
    required this.carbs,
    required this.carbsGoal,
    required this.fat,
    required this.fatGoal,
    required this.colorScheme,
  });

  final double protein;
  final double proteinGoal;
  final double carbs;
  final double carbsGoal;
  final double fat;
  final double fatGoal;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        MacroCircle(
          label: 'Protein',
          value: protein,
          goal: proteinGoal,
          color: CupertinoColors.systemRed,
          colorScheme: colorScheme,
        ),
        MacroCircle(
          label: 'Carbs',
          value: carbs,
          goal: carbsGoal,
          color: CupertinoColors.systemBlue,
          colorScheme: colorScheme,
        ),
        MacroCircle(
          label: 'Fat',
          value: fat,
          goal: fatGoal,
          color: CupertinoColors.systemOrange,
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}
