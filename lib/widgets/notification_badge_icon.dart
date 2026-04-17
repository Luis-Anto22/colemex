import 'dart:async';

import 'package:flutter/material.dart';

import '../services/api_services/api_client.dart';
import '../services/api_services/notificaciones_api.dart';

class NotificationBadgeIcon extends StatefulWidget {
  final int? profesionalId;
  final VoidCallback onPressed;
  final String tooltip;
  final Duration refreshInterval;
  final IconData icon;

  const NotificationBadgeIcon({
    super.key,
    required this.profesionalId,
    required this.onPressed,
    this.tooltip = 'Notificaciones',
    this.refreshInterval = const Duration(seconds: 25),
    this.icon = Icons.notifications_none,
  });

  @override
  State<NotificationBadgeIcon> createState() => _NotificationBadgeIconState();
}

class _NotificationBadgeIconState extends State<NotificationBadgeIcon> {
  final NotificacionesApi _api = NotificacionesApi(ApiClient());
  Timer? _timer;
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _refreshCount();
    _timer = Timer.periodic(widget.refreshInterval, (_) => _refreshCount());
  }

  @override
  void didUpdateWidget(covariant NotificationBadgeIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profesionalId != widget.profesionalId) {
      _refreshCount();
    }
  }

  Future<void> _refreshCount() async {
    final id = widget.profesionalId ?? 0;
    if (id <= 0) {
      if (!mounted) return;
      setState(() => _count = 0);
      return;
    }

    try {
      final c = await _api.countNoLeidas(profesionalId: id);
      if (!mounted) return;
      setState(() => _count = c);
    } catch (_) {
      // Si falla el API, mantenemos el icono sin badge para no romper UI.
      if (!mounted) return;
      setState(() => _count = 0);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badgeText = _count > 99 ? '99+' : '$_count';

    return IconButton(
      tooltip: widget.tooltip,
      onPressed: widget.onPressed,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(widget.icon),
          if (_count > 0)
            Positioned(
              right: -8,
              top: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 14),
                child: Text(
                  badgeText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
