import 'package:flutter/material.dart';

class EstadoProfesionalWidget extends StatelessWidget {
  final String estadoActual;
  final ValueChanged<String> onChanged;
  final Color color;

  const EstadoProfesionalWidget({
    super.key,
    required this.estadoActual,
    required this.onChanged,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _chip('Disponible'),
        _chip('Ocupado'),
        _chip('Fuera de servicio'),
      ],
    );
  }

  Widget _chip(String label) {
    final active = estadoActual == label;

    return ChoiceChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => onChanged(label),
      labelStyle: TextStyle(
        color: active ? Colors.black : Colors.white.withOpacity(.88),
        fontWeight: FontWeight.w800,
      ),
      selectedColor: color,
      backgroundColor: Colors.white.withOpacity(.06),
      shape: StadiumBorder(
        side: BorderSide(color: color.withOpacity(.25)),
      ),
    );
  }
}
