import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import '../theme/app_theme.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final catalog = controller.catalog;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: catalog.length + 1,
          itemBuilder: (context, i) {
            if (i == 0) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Text(
                  'What are you sipping?',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
              );
            }
            final drink = catalog[i - 1];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Text(drink.emoji, style: const TextStyle(fontSize: 28)),
                title: Text(drink.name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(
                    '${drink.caffeineMg} mg · ${drink.sugarG}g sugar'),
                trailing: const Icon(Icons.add_circle_outline,
                    color: AppColors.accentDeep),
                onTap: () async {
                  await controller.logDrink(drink.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Logged ${drink.name} ${drink.emoji}')),
                    );
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}
