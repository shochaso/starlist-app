import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../ui/app_button.dart';
import '../ui/app_card.dart';
import '../ui/app_text_field.dart';

class StyleGuidePage extends StatefulWidget {
  const StyleGuidePage({super.key});

  @override
  State<StyleGuidePage> createState() => _StyleGuidePageState();
}

class _StyleGuidePageState extends State<StyleGuidePage> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    final theme = _isDark ? AppTheme.darkTheme : AppTheme.lightTheme;

    return Theme(
      data: theme,
      child: Builder(
        builder: (context) {
          final tokens = context.tokens;
          final colorScheme = Theme.of(context).colorScheme;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Style Guide'),
              actions: [
                Row(
                  children: [
                    const Text('Light'),
                    Switch(
                      value: _isDark,
                      onChanged: (value) => setState(() => _isDark = value),
                    ),
                    const Text('Dark'),
                    SizedBox(width: tokens.spacing.md),
                  ],
                ),
              ],
            ),
            body: ListView(
              padding: EdgeInsets.all(tokens.spacing.lg),
              children: [
                _Section(
                  title: 'Color Palette',
                  child: Wrap(
                    spacing: tokens.spacing.sm,
                    runSpacing: tokens.spacing.sm,
                    children: [
                      _ColorTile('Primary', colorScheme.primary, colorScheme.onPrimary),
                      _ColorTile('Secondary', colorScheme.secondary, colorScheme.onSecondary),
                      _ColorTile('Surface', colorScheme.surface, colorScheme.onSurface),
                      _ColorTile('Background', colorScheme.background, colorScheme.onBackground),
                      _ColorTile('Success', colorScheme.tertiary, colorScheme.onTertiary),
                      _ColorTile('Warning', colorScheme.tertiaryContainer, colorScheme.onTertiaryContainer),
                      _ColorTile('Danger', colorScheme.error, colorScheme.onError),
                    ],
                  ),
                ),
                _Section(
                  title: 'Typography Scale',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Display Large', style: Theme.of(context).textTheme.displayLarge),
                      SizedBox(height: tokens.spacing.sm),
                      Text('Headline Medium', style: Theme.of(context).textTheme.headlineMedium),
                      SizedBox(height: tokens.spacing.sm),
                      Text('Title Large', style: Theme.of(context).textTheme.titleLarge),
                      SizedBox(height: tokens.spacing.sm),
                      Text('Body Large', style: Theme.of(context).textTheme.bodyLarge),
                      SizedBox(height: tokens.spacing.sm),
                      Text('Label Large', style: Theme.of(context).textTheme.labelLarge),
                    ],
                  ),
                ),
                _Section(
                  title: 'Buttons',
                  child: Wrap(
                    spacing: tokens.spacing.sm,
                    runSpacing: tokens.spacing.sm,
                    children: [
                      const AppButton('Primary'),
                      const AppButton('Secondary', variant: AppButtonVariant.secondary),
                      const AppButton('Tonal', variant: AppButtonVariant.tonal),
                      const AppButton('Text', variant: AppButtonVariant.text),
                      const AppButton(
                        'With Icon',
                        leading: Icon(Icons.star),
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Inputs',
                  child: Column(
                    children: const [
                      AppTextField(
                        labelText: 'Email',
                        hintText: 'user@starlist.app',
                        prefix: Icon(Icons.mail_outline),
                      ),
                      SizedBox(height: 16),
                      AppTextField(
                        labelText: 'Password',
                        hintText: 'Enter secure password',
                        prefix: Icon(Icons.lock_outline),
                        obscureText: true,
                      ),
                      SizedBox(height: 16),
                      AppTextField(
                        labelText: 'API Token',
                        helperText: 'Looks good',
                        state: AppTextFieldState.success,
                        prefix: Icon(Icons.verified_outlined),
                      ),
                      SizedBox(height: 16),
                      AppTextField(
                        labelText: 'Promo Code',
                        errorText: 'Invalid code',
                        state: AppTextFieldState.danger,
                        prefix: Icon(Icons.error_outline),
                      ),
                    ],
                  ),
                ),
                _Section(
                  title: 'Cards',
                  child: AppCard(
                    title: 'Analytics',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '12,345 Fans',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(color: colorScheme.primary),
                        ),
                        SizedBox(height: tokens.spacing.xs),
                        Text(
                          '+18% MoM',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: colorScheme.tertiary),
                        ),
                      ],
                    ),
                  ),
                ),
                _Section(
                  title: 'Tabs & Chips',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultTabController(
                        length: 3,
                        child: Column(
                          children: [
                            TabBar(
                              tabs: const [
                                Tab(text: 'Overview'),
                                Tab(text: 'Audience'),
                                Tab(text: 'Revenue'),
                              ],
                              isScrollable: false,
                            ),
                            SizedBox(
                              height: 80,
                              child: TabBarView(
                                children: [
                                  Center(child: Text('Overview content', style: Theme.of(context).textTheme.bodyMedium)),
                                  Center(child: Text('Audience content', style: Theme.of(context).textTheme.bodyMedium)),
                                  Center(child: Text('Revenue content', style: Theme.of(context).textTheme.bodyMedium)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: tokens.spacing.md),
                      Wrap(
                        spacing: tokens.spacing.sm,
                        runSpacing: tokens.spacing.xs,
                        children: [
                          FilterChip(
                            label: const Text('Premium'),
                            selected: true,
                            onSelected: (_) {},
                          ),
                          const Chip(label: Text('Engaged')),
                          ActionChip(label: const Text('Add filter'), onPressed: () {}),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Padding(
      padding: EdgeInsets.only(bottom: tokens.spacing.section),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          SizedBox(height: tokens.spacing.sm),
          child,
        ],
      ),
    );
  }
}

class _ColorTile extends StatelessWidget {
  const _ColorTile(this.label, this.color, this.foregroundColor);

  final String label;
  final Color color;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      width: 160,
      padding: EdgeInsets.all(tokens.spacing.md),
      decoration: BoxDecoration(
        color: color,
        borderRadius: tokens.radius.lgRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: tokens.elevations.md,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: foregroundColor)),
          SizedBox(height: tokens.spacing.xs),
          Text('#${color.value.toRadixString(16).padLeft(8, '0').toUpperCase().substring(2)}',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: foregroundColor.withOpacity(0.72))),
        ],
      ),
    );
  }
}
