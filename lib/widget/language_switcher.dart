import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../utils/app_text.dart';
import '../viewmodel/language_view_model.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.watch<LanguageViewModel>();
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            Icons.language,
            color: theme.colorScheme.primary,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppText.get(context, 'language'),
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  AppText.get(context, 'switchLanguage'),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),

          DropdownButton<String>(
            value: language.locale.languageCode,
            underline: const SizedBox(),
            items: [
              DropdownMenuItem(
                value: 'en',
                child: Text(AppText.get(context, 'english')),
              ),
              DropdownMenuItem(
                value: 'ar',
                child: Text(AppText.get(context, 'arabic')),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;
              context.read<LanguageViewModel>().changeLanguage(value);
            },
          ),
        ],
      ),
    );
  }
}