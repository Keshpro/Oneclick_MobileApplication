
import 'dart:math' as math;

import 'package:flutter/material.dart';

class ExpenseDonutChart extends StatelessWidget {
  const ExpenseDonutChart({
    super.key,
    required this.totals,
  });

  /// Category totals for the selected month, in LKR.
  final Map<String, double> totals;

  static const _categories = [
    _DonutCategory(
      'food', 'Food', Color(0xFFFFA45C),
    ),
    _DonutCategory(
      'doctor', 'Doctor', Color(0xFFEF7894),
    ),
    _DonutCategory(
      'groceries', 'Groceries', Color(0xFF4CBF9C),
    ),
    _DonutCategory(
      'quickfix', 'QuickFix', Color(0xFF6997E8),
    ),
    _DonutCategory(
      'drunk_drive', 'Drunk Drive', Color(0xFF9B80DD),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final values = [
      for (final category in _categories)
        _validAmount(totals[category.id]),
    ];

    final total = values.fold<double>(
      0.0,
      (runningTotal, value) => runningTotal + value,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFF0F1F7),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Spending Distribution',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF25263A),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Monthly spending by category',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF8B90A4),
            ),
          ),
          const SizedBox(height: 24),

          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 380;

              final donut = SizedBox(
                width: compact ? 200 : 220,
                height: compact ? 200 : 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size(
                        compact ? 200 : 220,
                        compact ? 200 : 220,
                      ),
                      painter: _ExpenseDonutPainter(
                        values: values,
                        total: total,
                        colors: [
                          for (final category in _categories)
                            category.color,
                        ],
                      ),
                    ),
                  ],
                ),
              );

              final legend = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < _categories.length; i++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: i == _categories.length - 1
                            ? 0
                            : 18,
                      ),
                      child: _legendRow(
                        _categories[i],
                        total > 0
                            ? (values[i] / total) * 100
                            : 0.0,
                      ),
                    ),
                ],
              );

              if (compact) {
                return Column(
                  children: [
                    Center(child: donut),
                    const SizedBox(height: 22),
                    legend,
                  ],
                );
              }

              return Row(
                children: [
                  donut,
                  const SizedBox(width: 24),
                  Expanded(child: legend),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  double _validAmount(double? amount) {
    if (amount == null || !amount.isFinite || amount <= 0) {
      return 0.0;
    }
    return amount;
  }

  Widget _legendRow(
    _DonutCategory category,
    double percentage,
  ) {
    return Row(
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: category.color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            category.label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF55596C),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF25263A),
          ),
        ),
      ],
    );
  }
}

class _DonutCategory {
  const _DonutCategory(
    this.id,
    this.label,
    this.color,
  );

  final String id;
  final String label;
  final Color color;
}

class _ExpenseDonutPainter extends CustomPainter {
  const _ExpenseDonutPainter({
    required this.values,
    required this.total,
    required this.colors,
  });

  final List<double> values;
  final double total;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );
    final radius =
        math.min(size.width, size.height) / 2 - 18;

    final rect = Rect.fromCircle(
      center: center,
      radius: radius,
    );

    const strokeWidth = 25.0;

    final backgroundPaint = Paint()
      ..color = const Color(0xFFEDEAF6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(
      center,
      radius,
      backgroundPaint,
    );

    if (total <= 0 || !total.isFinite) return;

    var startAngle = -math.pi / 2;

    for (var i = 0; i < values.length; i++) {
      if (values[i] <= 0) continue;

      final sweepAngle =
          (values[i] / total) * 2 * math.pi;

      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(
    covariant _ExpenseDonutPainter oldDelegate,
  ) {
    if (total != oldDelegate.total ||
        values.length != oldDelegate.values.length ||
        colors.length != oldDelegate.colors.length) {
      return true;
    }

    for (var i = 0; i < values.length; i++) {
      if (values[i] != oldDelegate.values[i] ||
          colors[i] != oldDelegate.colors[i]) {
        return true;
      }
    }

    return false;
  }
}