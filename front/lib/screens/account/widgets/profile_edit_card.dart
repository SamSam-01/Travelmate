import 'package:flutter/material.dart';
import 'package:front/core/constants/app_spacing.dart';

class ProfileEditCard extends StatelessWidget {
  const ProfileEditCard({
    super.key,
    required this.title,
    required this.usernameLabel,
    required this.displayNameLabel,
    required this.avatarUrlLabel,
    required this.privateLabel,
    required this.submitLabel,
    required this.usernameController,
    required this.displayNameController,
    required this.avatarUrlController,
    required this.isPrivate,
    required this.isSaving,
    required this.onPrivateChanged,
    required this.onSubmit,
  });

  final String title;
  final String usernameLabel;
  final String displayNameLabel;
  final String avatarUrlLabel;
  final String privateLabel;
  final String submitLabel;
  final TextEditingController usernameController;
  final TextEditingController displayNameController;
  final TextEditingController avatarUrlController;
  final bool isPrivate;
  final bool isSaving;
  final ValueChanged<bool> onPrivateChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: usernameController,
              decoration: InputDecoration(labelText: usernameLabel),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: displayNameController,
              decoration: InputDecoration(labelText: displayNameLabel),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: avatarUrlController,
              decoration: InputDecoration(labelText: avatarUrlLabel),
            ),
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: isPrivate,
              onChanged: onPrivateChanged,
              title: Text(privateLabel),
            ),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : onSubmit,
                child: Text(submitLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
