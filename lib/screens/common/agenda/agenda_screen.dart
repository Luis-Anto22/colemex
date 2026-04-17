import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_services/api_client.dart';
import '../../../services/api_services/common_api.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {

  final CommonApi api = CommonApi(ApiClient());

  bool cargando = true;
  String mensaje = '';

  int profesionalId = 0;

  List<dynamic> items = [];
  List<dynamic> clientes = [];

  int? clienteSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {

    final prefs = await SharedPreferences.getInstance();
    profesionalId = prefs.getInt('id') ?? 0;

    if (profesionalId <= 0) {
      setState(() {
        cargando = false;
        mensaje = 'ID no válido';
      });
      return;
    }

    try {

      final agenda = await api.getAgenda(profesionalId);
      final listaClientes = await api.getClientes();

      if (!mounted) return;

      setState(() {
        items = agenda;
        clientes = listaClientes;
        cargando = false;
        mensaje = '';
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        cargando = false;
        mensaje = 'Error: $e';
      });

    }

  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _fmt(DateTime dt) {
    return '${dt.year}-${_two(dt.month)}-${_two(dt.day)} '
        '${_two(dt.hour)}:${_two(dt.minute)}:00';
  }

  /// Obtener nombre del cliente
  String _nombreCliente(int? id) {

    if (id == null) return "Cliente";

    try {

      final c = clientes.firstWhere((c) => c['id'] == id);

      return c['nombre'] ?? "Cliente";

    } catch (_) {

      return "Cliente #$id";

    }

  }

  Future<DateTime?> _pickDateTime() async {

    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
    );

    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );

    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);

  }

  Future<void> _crearCita() async {

    if (profesionalId <= 0) return;

    DateTime? inicio;
    int? clienteId = clienteSeleccionado;

    final ok = await showDialog<bool>(

      context: context,

      builder: (_) => StatefulBuilder(

        builder: (context, setModalState) => AlertDialog(

          title: const Text('Nueva cita'),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              DropdownButtonFormField<int>(

                initialValue: clienteId,

                decoration: const InputDecoration(
                  labelText: 'Seleccionar cliente',
                ),

                items: clientes.map<DropdownMenuItem<int>>((c) {

                  return DropdownMenuItem<int>(
                    value: c['id'] as int,
                    child: Text(c['nombre']),
                  );

                }).toList(),

                onChanged: (v) {

                  setModalState(() {
                    clienteId = v;
                  });

                },

              ),

              const SizedBox(height: 16),

              ElevatedButton.icon(

                onPressed: () async {

                  final dt = await _pickDateTime();

                  if (dt == null) return;

                  setModalState(() {
                    inicio = dt;
                  });

                },

                icon: const Icon(Icons.calendar_today),

                label: Text(
                  inicio == null
                      ? 'Seleccionar fecha y hora'
                      : _fmt(inicio!),
                ),

              ),

            ],
          ),

          actions: [

            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),

            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Guardar'),
            ),

          ],
        ),
      ),
    );

    if (ok != true || inicio == null || clienteId == null) {
      return;
    }

    try {

      await api.crearAgenda(
        profesionalId: profesionalId,
        clienteId: clienteId!,   // ✔ CORREGIDO
        inicio: _fmt(inicio!),   // ✔ CORREGIDO
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cita creada')),
      );

      await _cargar();

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );

    }

  }

  @override
  Widget build(BuildContext context) {

    final gold = Theme.of(context).primaryColor;

    return Scaffold(

      appBar: AppBar(
        title: const Text('Agenda / citas'),
        actions: [
          IconButton(
            onPressed: _cargar,
            icon: const Icon(Icons.refresh),
          )
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _crearCita,
        child: const Icon(Icons.add),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            Icon(Icons.event_available_outlined, size: 64, color: gold),

            const SizedBox(height: 12),

            const Text(
              'Agenda',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Citas, disponibilidad y horarios.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            if (cargando)

              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )

            else if (items.isEmpty)

              Expanded(
                child: Center(
                  child: Text(
                    mensaje.isEmpty
                        ? 'Sin citas registradas.'
                        : mensaje,
                  ),
                ),
              )

            else

              Expanded(
                child: ListView.separated(

                  itemCount: items.length,

                  separatorBuilder: (_, __) => const Divider(),

                  itemBuilder: (_, i) {

                    final a = items[i] as Map<String, dynamic>;

                    final clienteId = a['cliente_id'] as int?;

                    return ListTile(

                      leading: Icon(Icons.calendar_today, color: gold),

                      title: Text(
                        _nombreCliente(clienteId),
                      ),

                      subtitle: Text(
                        (a['inicio'] ?? '').toString(),
                      ),

                      trailing: Text(
                        (a['estado'] ?? '').toString(),
                      ),

                    );

                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}