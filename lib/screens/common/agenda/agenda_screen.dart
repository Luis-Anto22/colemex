import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/api_client.dart';
import '../../../services/common_api.dart';

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
        mensaje = 'ID no valido';
      });
      return;
    }

    try {
      final data = await api.getAgenda(profesionalId);
      if (!mounted) return;
      setState(() {
        items = data;
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
    final clienteCtrl = TextEditingController();
    DateTime? inicio;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          title: const Text('Nueva cita'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: clienteCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'ID cliente'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () async {
                  final dt = await _pickDateTime();
                  if (dt == null) return;
                  setModalState(() => inicio = dt);
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  inicio == null ? 'Seleccionar fecha y hora' : _fmt(inicio!),
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

    final clienteId = int.tryParse(clienteCtrl.text.trim()) ?? 0;
    if (ok != true || inicio == null || clienteId <= 0) {
      return;
    }

    try {
      await api.crearAgenda(
        profesionalId: profesionalId,
        clienteId: clienteId,
        inicio: _fmt(inicio!),
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
          IconButton(onPressed: _cargar, icon: const Icon(Icons.refresh)),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const Text(
              'Citas, disponibilidad y horarios.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (cargando)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else if (items.isEmpty)
              Expanded(
                child: Center(
                  child: Text(mensaje.isEmpty ? 'Sin citas registradas.' : mensaje),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, i) {
                    final a = items[i] as Map<String, dynamic>;
                    return ListTile(
                      leading: Icon(Icons.calendar_today, color: gold),
                      title: Text('Cita cliente #${a['cliente_id'] ?? ''}'),
                      subtitle: Text((a['inicio'] ?? '').toString()),
                      trailing: Text((a['estado'] ?? '').toString()),
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
