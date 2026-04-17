import 'package:flutter/material.dart';

Widget sectionHeader(BuildContext context, String title, {String? subtitle}) {
  return Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Color.fromARGB(179, 255, 255, 255), // reemplazo de .withOpacity(.70)
            ),
          ),
        ],
      ],
    ),
  );
}

Widget card(BuildContext context, {required Widget child, Color? color}) {
  final theme = Theme.of(context);
  final gold = theme.primaryColor;

  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      color: color ?? const Color.fromARGB(15, 255, 255, 255), // color personalizado o default
      border: Border.all(
        color: gold.withAlpha(46), // reemplazo de .withOpacity(.18)
      ),
    ),
    child: child,
  );
}

Widget tile(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  final theme = Theme.of(context);
  final gold = theme.primaryColor;

  return InkWell(
    borderRadius: BorderRadius.circular(14),
    onTap: onTap,
    child: Ink(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: const Color.fromARGB(13, 255, 255, 255), // reemplazo de .withOpacity(.05)
        border: Border.all(
          color: gold.withAlpha(36), // reemplazo de .withOpacity(.14)
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: gold.withAlpha(25), // reemplazo de .withOpacity(.10)
              border: Border.all(
                color: gold.withAlpha(46), // reemplazo de .withOpacity(.18)
              ),
            ),
            child: Icon(icon, color: gold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color.fromARGB(184, 255, 255, 255), // reemplazo de .withOpacity(.72)
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: Color.fromARGB(153, 255, 255, 255), // reemplazo de .withOpacity(.60)
          ),
        ],
      ),
    ),
  );
}