import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:colemex/screens/login_screen.dart';

class HomePublicScreen extends StatefulWidget {
  const HomePublicScreen({super.key});

  @override
  State<HomePublicScreen> createState() => _HomePublicScreenState();
}

class _HomePublicScreenState extends State<HomePublicScreen> {
  bool mostrarBeneficios = true;

  @override
  void initState() {
    super.initState();
    verificarPrimeraVez();
  }

  Future<void> verificarPrimeraVez() async {
    final prefs = await SharedPreferences.getInstance();
    final yaMostrado = prefs.getBool('beneficiosMostrados') ?? false;

    if (!yaMostrado) {
      // Primera vez → mostrar beneficios
      setState(() {
        mostrarBeneficios = true;
      });
    } else {
      // Ya se mostró antes → saltar directo al login
      setState(() {
        mostrarBeneficios = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: mostrarBeneficios
          ? PageView(
              children: const [
                BeneficiosClientePage(),
                BeneficiosAbogadoPage(),
                FinalIntroPage(), // ✅ Nueva página con botón "Continuar"
              ],
            )
          : const LoginScreen(),
    );
  }
}

// 🔹 Función para abrir URLs
Future<void> abrirPagina(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    debugPrint('❌ No se pudo abrir $url');
  }
}

// 🔹 Widget base con fondo y logo
class BasePage extends StatelessWidget {
  final String title;
  final String content;
  final Widget? extra;

  const BasePage({
    super.key,
    required this.title,
    required this.content,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/iconos/mazo-libro.png"), // 👈 Fondo institucional
          fit: BoxFit.cover,
          opacity: 0.15,
        ),
      ),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Image.asset(
              "assets/iconos/logo.png",
              height: 100,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            content,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          if (extra != null) ...[
            const SizedBox(height: 24),
            extra!,
          ],
        ],
      ),
    );
  }
}

class BeneficiosClientePage extends StatelessWidget {
  const BeneficiosClientePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BasePage(
      title: "Beneficios como Cliente",
      content:
          "✔ Acceso rápido a seguros personalizados\n"
          "✔ Atención legal inmediata\n"
          "✔ Plataforma digital segura",
    );
  }
}

class BeneficiosAbogadoPage extends StatelessWidget {
  const BeneficiosAbogadoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const BasePage(
      title: "Beneficios como Abogado",
      content:
          "✔ Mayor visibilidad con clientes\n"
          "✔ Herramientas digitales para gestión de casos\n"
          "✔ Red profesional de colegas",
    );
  }
}

// ✅ Página final con botón para continuar al login
class FinalIntroPage extends StatelessWidget {
  const FinalIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BasePage(
      title: "Bienvenido a COLEMEX",
      content: "Tu plataforma legal digital segura y confiable.",
      extra: ElevatedButton(
        onPressed: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('beneficiosMostrados', true);

          // ✅ Redirigir al login y no volver atrás
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        },
        child: const Text("Continuar"),
      ),
    );
  }
}