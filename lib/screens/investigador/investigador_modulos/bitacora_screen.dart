import 'package:flutter/material.dart';

class BitacoraScreen extends StatelessWidget {
  const BitacoraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = theme.primaryColor;
    final headerBg = theme.appBarTheme.backgroundColor ?? gold;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitácora / Seguimiento'),
        backgroundColor: headerBg,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(18),
          constraints: const BoxConstraints(maxWidth: 720),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: const Color(0xFF12161C),
            border: Border.all(color: gold.withOpacity(.22)),
          ),
          child: Text(
            'Aquí podrás escribir notas, avances y estatus del caso.',
            style: TextStyle(color: Colors.white.withOpacity(.72)),
          ),
        ),
      ),
    );
  }
}
