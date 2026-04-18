import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GeneradorDocumentosScreen extends StatelessWidget {
  const GeneradorDocumentosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final documentos = <_DocumentoItem>[
      _DocumentoItem(
        titulo: 'Carta poder',
        descripcion: 'Formato simple para autorizar a otra persona.',
        tipo: TipoDocumento.cartaPoder,
      ),
      _DocumentoItem(
        titulo: 'Pagaré simple',
        descripcion: 'Reconocimiento de deuda con fecha de pago.',
        tipo: TipoDocumento.pagareSimple,
      ),
      _DocumentoItem(
        titulo: 'Recibo de honorarios',
        descripcion: 'Constancia simple de pago recibido.',
        tipo: TipoDocumento.reciboHonorarios,
      ),
      _DocumentoItem(
        titulo: 'Contrato simple',
        descripcion: 'Acuerdo básico entre dos partes.',
        tipo: TipoDocumento.contratoSimple,
      ),
      _DocumentoItem(
        titulo: 'Convenio simple',
        descripcion: 'Acuerdo sencillo con obligaciones básicas.',
        tipo: TipoDocumento.convenioSimple,
      ),
      _DocumentoItem(
        titulo: 'Escrito libre',
        descripcion: 'Formato abierto para redactado básico.',
        tipo: TipoDocumento.escritoLibre,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Generador de documentos'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: documentos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final item = documentos[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(item.titulo),
              subtitle: Text(item.descripcion),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DocumentoFormularioScreen(item: item),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DocumentoFormularioScreen extends StatefulWidget {
  final _DocumentoItem item;

  const DocumentoFormularioScreen({
    super.key,
    required this.item,
  });

  @override
  State<DocumentoFormularioScreen> createState() =>
      _DocumentoFormularioScreenState();
}

class _DocumentoFormularioScreenState extends State<DocumentoFormularioScreen> {
  final _formKey = GlobalKey<FormState>();

  final ciudadController = TextEditingController();
  final fechaController = TextEditingController();
  final nombreUnoController = TextEditingController();
  final nombreDosController = TextEditingController();
  final direccionController = TextEditingController();
  final cantidadController = TextEditingController();
  final conceptoController = TextEditingController();
  final detalleController = TextEditingController();

  String documentoGenerado = '';

  @override
  void dispose() {
    ciudadController.dispose();
    fechaController.dispose();
    nombreUnoController.dispose();
    nombreDosController.dispose();
    direccionController.dispose();
    cantidadController.dispose();
    conceptoController.dispose();
    detalleController.dispose();
    super.dispose();
  }

  void generarDocumento() {
    if (!_formKey.currentState!.validate()) return;

    final ciudad = ciudadController.text.trim();
    final fecha = fechaController.text.trim();
    final nombreUno = nombreUnoController.text.trim();
    final nombreDos = nombreDosController.text.trim();
    final direccion = direccionController.text.trim();
    final cantidad = cantidadController.text.trim();
    final concepto = conceptoController.text.trim();
    final detalle = detalleController.text.trim();

    String texto = '';

    switch (widget.item.tipo) {
      case TipoDocumento.cartaPoder:
        texto = '''
CARTA PODER

En la ciudad de $ciudad, con fecha $fecha, yo, $nombreUno, otorgo poder amplio, cumplido y bastante a $nombreDos para que a mi nombre y representación realice las gestiones necesarias relacionadas con: $concepto.

La persona autorizada podrá presentar documentos, firmar de recibido y llevar a cabo actos relacionados con la gestión antes descrita.

Domicilio de referencia: $direccion.

ATENTAMENTE

____________________________
$nombreUno

ACEPTO EL PODER

____________________________
$nombreDos
''';
        break;

      case TipoDocumento.pagareSimple:
        texto = '''
PAGARÉ SIMPLE

Debo y pagaré incondicionalmente a la orden de $nombreDos la cantidad de $cantidad, en la ciudad de $ciudad, con fecha de pago $fecha.

Yo, $nombreUno, reconozco adeudar dicha cantidad por concepto de: $concepto.

Para cualquier notificación, señalo como domicilio: $direccion.

FIRMA DEL DEUDOR

____________________________
$nombreUno
''';
        break;

      case TipoDocumento.reciboHonorarios:
        texto = '''
RECIBO DE HONORARIOS

En la ciudad de $ciudad, con fecha $fecha, yo, $nombreUno, hago constar que recibí de $nombreDos la cantidad de $cantidad por concepto de $concepto.

Domicilio relacionado: $direccion.

Se expide el presente recibo para los fines legales correspondientes.

RECIBE

____________________________
$nombreUno
''';
        break;

      case TipoDocumento.contratoSimple:
        texto = '''
CONTRATO SIMPLE

En la ciudad de $ciudad, con fecha $fecha, celebran por una parte $nombreUno y por la otra $nombreDos, el presente contrato respecto de: $concepto.

PRIMERA. Ambas partes manifiestan su voluntad de obligarse en los términos del presente acuerdo.

SEGUNDA. El objeto del contrato consiste en: $detalle.

TERCERA. Como referencia económica, se establece la cantidad de $cantidad.

CUARTA. Para cualquier notificación, las partes señalan como domicilio: $direccion.

Leído que fue el presente contrato, ambas partes lo firman de conformidad.

____________________________
$nombreUno

____________________________
$nombreDos
''';
        break;

      case TipoDocumento.convenioSimple:
        texto = '''
CONVENIO SIMPLE

En la ciudad de $ciudad, con fecha $fecha, comparecen $nombreUno y $nombreDos para celebrar el presente convenio respecto de: $concepto.

PRIMERA. Las partes acuerdan resolver o regular lo relacionado con: $detalle.

SEGUNDA. Como parte del cumplimiento del presente convenio, se considera la cantidad de $cantidad.

TERCERA. Las partes señalan como domicilio para oír y recibir notificaciones: $direccion.

Las partes firman el presente convenio de conformidad.

____________________________
$nombreUno

____________________________
$nombreDos
''';
        break;

      case TipoDocumento.escritoLibre:
        texto = '''
ESCRITO LIBRE

C. AUTORIDAD / A QUIEN CORRESPONDA
P R E S E N T E

Yo, $nombreUno, señalando como domicilio $direccion, comparezco para exponer lo siguiente:

$detalle

Lo anterior se relaciona con: $concepto.

Por lo antes expuesto, solicito se me tenga por presentado con este escrito para los efectos legales conducentes.

$ciudad, $fecha.

ATENTAMENTE

____________________________
$nombreUno
''';
        break;
    }

    setState(() {
      documentoGenerado = texto;
    });
  }

  Future<void> copiarDocumento() async {
    if (documentoGenerado.trim().isEmpty) return;

    await Clipboard.setData(ClipboardData(text: documentoGenerado));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Documento copiado al portapapeles'),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool requiereCantidad = widget.item.tipo == TipoDocumento.pagareSimple ||
        widget.item.tipo == TipoDocumento.reciboHonorarios ||
        widget.item.tipo == TipoDocumento.contratoSimple ||
        widget.item.tipo == TipoDocumento.convenioSimple;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item.titulo),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'Llena los datos para generar el formato base',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: ciudadController,
                        decoration: _inputDecoration('Ciudad'),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: fechaController,
                        decoration: _inputDecoration('Fecha'),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nombreUnoController,
                        decoration: _inputDecoration(
                          widget.item.tipo == TipoDocumento.reciboHonorarios
                              ? 'Nombre de quien recibe'
                              : 'Nombre de la primera persona',
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nombreDosController,
                        decoration: _inputDecoration(
                          widget.item.tipo == TipoDocumento.reciboHonorarios
                              ? 'Nombre de quien paga'
                              : 'Nombre de la segunda persona',
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: direccionController,
                        decoration: _inputDecoration('Dirección'),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: conceptoController,
                        decoration: _inputDecoration('Concepto principal'),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
                      ),
                      const SizedBox(height: 12),
                      if (requiereCantidad) ...[
                        TextFormField(
                          controller: cantidadController,
                          decoration: _inputDecoration('Cantidad'),
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
                        ),
                        const SizedBox(height: 12),
                      ],
                      TextFormField(
                        controller: detalleController,
                        maxLines: 4,
                        decoration: _inputDecoration('Detalle / descripción'),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: generarDocumento,
                          icon: const Icon(Icons.description_outlined),
                          label: const Text('Generar documento'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (documentoGenerado.isNotEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Vista previa',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: copiarDocumento,
                            icon: const Icon(Icons.copy),
                            label: const Text('Copiar'),
                          ),
                        ],
                      ),
                      const Divider(),
                      SelectableText(
                        documentoGenerado,
                        style: const TextStyle(fontSize: 15, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum TipoDocumento {
  cartaPoder,
  pagareSimple,
  reciboHonorarios,
  contratoSimple,
  convenioSimple,
  escritoLibre,
}

class _DocumentoItem {
  final String titulo;
  final String descripcion;
  final TipoDocumento tipo;

  _DocumentoItem({
    required this.titulo,
    required this.descripcion,
    required this.tipo,
  });
}