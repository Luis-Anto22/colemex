import 'package:flutter/material.dart';
import '../../../services/api_services/common_api.dart';
import '../../../services/api_services/api_client.dart';

class CalificacionesScreen extends StatefulWidget {
  const CalificacionesScreen({super.key});

  @override
  State<CalificacionesScreen> createState() => _CalificacionesScreenState();
}

class _CalificacionesScreenState extends State<CalificacionesScreen> {

  late Future<Map<String, dynamic>> futureCalificaciones;

  final CommonApi api = CommonApi(
  ApiClient(),
);

  @override
  void initState() {
    super.initState();
    futureCalificaciones = api.getCalificaciones(1);
  }

  @override
  Widget build(BuildContext context) {

    final gold = Theme.of(context).primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Calificaciones de usuarios"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: FutureBuilder<Map<String, dynamic>>(

          future: futureCalificaciones,

          builder: (context, snapshot) {

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}"),
              );
            }

            final data = snapshot.data ?? {};

            final List items = data['items'] ?? [];
            final double promedio =
                double.tryParse(data['promedio'].toString()) ?? 0;

            final int total =
                int.tryParse(data['total'].toString()) ?? 0;

            if (items.isEmpty) {
              return const Center(
                child: Text("Por el momento no tienes calificaciones"),
              );
            }

            return Column(
              children: [

                Icon(Icons.star_outline, size: 64, color: gold),

                const SizedBox(height: 12),

                const Text(
                  "Calificaciones",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  "Promedio y comentarios de usuarios",
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                /// Promedio
                Card(
                  child: ListTile(
                    leading: Icon(Icons.star, color: gold),

                    title: const Text("Promedio"),

                    subtitle: Text(
                      "${promedio.toStringAsFixed(1)} / 5.0 ($total calificaciones)",
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// Lista comentarios
                Expanded(
                  child: ListView.builder(

                    itemCount: items.length,

                    itemBuilder: (_, i) {

                      final cal = items[i];

                      final estrellas =
                          int.tryParse(cal['estrellas'].toString()) ?? 0;

                      return ListTile(

                        leading: Icon(Icons.person, color: gold),

                        title: Text(cal['cliente'] ?? "Cliente"),

                        subtitle: Text(
                          cal['comentario'] ?? "Sin comentario",
                        ),

                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            estrellas,
                            (index) => Icon(
                              Icons.star,
                              color: gold,
                              size: 18,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}