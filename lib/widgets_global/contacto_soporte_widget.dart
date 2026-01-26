import 'package:flutter/material.dart';

class ContactoSoporteWidget extends StatelessWidget {
  const ContactoSoporteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: const [
          ListTile(
            leading: Icon(Icons.support_agent, color: Colors.blue),
            title: Text("Contacto con soporte"),
            subtitle: Text("soporte@tuapp.com"),
          ),
        ],
      ),
    );
  }
}