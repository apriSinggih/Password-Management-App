import 'package:flutter/material.dart';

import '../../../../core/theme/neo_palette.dart';
import '../../../../core/widgets/neobrutal.dart';
import '../../domain/credential.dart';
import 'category_style.dart';

class CredentialTile extends StatelessWidget {
  const CredentialTile({
    super.key,
    required this.credential,
    required this.onTap,
  });

  final Credential credential;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final palette = NeoPalette.of(context);
    final color = CategoryStyle.colorFor(credential.category);

    return NeobrutalContainer(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: palette.border, width: 3),
            ),
            child: Text(
              credential.primaryInitial,
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  credential.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  credential.username.isEmpty
                      ? credential.category
                      : credential.username,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: palette.textSecondary,
                  ),
                ),
                if (credential.tags.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: credential.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: palette.muted,
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: palette.border,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          tag.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          Icon(
            Icons.arrow_forward,
            color: palette.textPrimary,
            size: 22,
          ),
        ],
      ),
    );
  }
}
