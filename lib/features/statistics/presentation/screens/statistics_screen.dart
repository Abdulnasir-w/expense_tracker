import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

/// Statistics screen — tab 3 of the bottom nav.
/// Phase 3 will add charts (income vs expense bar, category pie).
class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Statistics'),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bar_chart_rounded, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Charts coming in Phase 3 🚀',
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

