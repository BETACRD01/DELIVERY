import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../../../apis/auth/dispositivos_api.dart';
import '../../../../theme/jp_theme.dart';

class PantallaDispositivosConectados extends StatefulWidget {
  const PantallaDispositivosConectados({super.key});

  @override
  State<PantallaDispositivosConectados> createState() =>
      _PantallaDispositivosConectadosState();
}

class _PantallaDispositivosConectadosState
    extends State<PantallaDispositivosConectados> {
  final _api = DispositivosApi();
  bool _cargando = true;
  List<dynamic> _dispositivos = [];

  @override
  void initState() {
    super.initState();
    _cargarDispositivos();
  }

  Future<void> _cargarDispositivos() async {
    try {
      final res = await _api.listarDispositivos();
      if (mounted) {
        setState(() {
          _dispositivos = res;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
        _mostrarError(e.toString());
      }
    }
  }

  Future<void> _cerrarSesion(int id, String nombreDispositivo) async {
    // Confirmación estilo iOS
    final confirm = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Cerrar Sesión'),
        content: Text('¿Deseas cerrar la sesión en "$nombreDispositivo"?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _api.cerrarSesionDispositivo(id);
      if (mounted) {
        _mostrarExito('Sesión cerrada correctamente');
        await _cargarDispositivos();
      }
    } catch (e) {
      if (mounted) {
        _mostrarError('Error al cerrar sesión: $e');
      }
    }
  }

  void _mostrarError(String mensaje) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(mensaje),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: JPColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatearFecha(String? fechaIso) {
    if (fechaIso == null) return 'Desconocido';
    try {
      final dt = DateTime.parse(fechaIso).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (e) {
      return fechaIso;
    }
  }

  IconData _getDeviceIcon(String userAgent) {
    final ua = userAgent.toLowerCase();
    if (ua.contains('iphone') || ua.contains('ipad') || ua.contains('ios')) {
      return CupertinoIcons.device_phone_portrait;
    } else if (ua.contains('android')) {
      return Icons.android;
    } else if (ua.contains('macintosh') || ua.contains('mac os')) {
      return CupertinoIcons.device_laptop;
    } else if (ua.contains('windows')) {
      return Icons.desktop_windows;
    }
    return CupertinoIcons.device_phone_portrait; // Default mobile app
  }

  String _getDeviceName(String? userAgent) {
    if (userAgent == null) return 'Dispositivo Desconocido';
    final ua = userAgent.toLowerCase();
    if (ua.contains('iphone')) return 'iPhone';
    if (ua.contains('ipad')) return 'iPad';
    if (ua.contains('android')) return 'Android';
    if (ua.contains('macintosh')) return 'Mac';
    if (ua.contains('windows')) return 'Windows PC';
    return 'Dispositivo';
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = JPCupertinoColors.background(context);
    final primaryColor = JPCupertinoColors.primary(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Dispositivos'),
        backgroundColor: bgColor,
        scrolledUnderElevation: 0,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: JPCupertinoColors.label(context),
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: _cargando
          ? const Center(child: CupertinoActivityIndicator())
          : _dispositivos.isEmpty
          ? _buildEmptyState()
          : ListView(
              padding: const EdgeInsets.only(top: 20),
              children: [
                _buildSectionHeader('SESIONES ACTIVAS'),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: JPCupertinoColors.surface(context),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: List.generate(_dispositivos.length, (index) {
                      final disp = _dispositivos[index];
                      final isLast = index == _dispositivos.length - 1;
                      return Column(
                        children: [
                          _buildDeviceRow(disp, isLast),
                          if (!isLast) _buildDivider(),
                        ],
                      );
                    }),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Si cierras una sesión, tendrás que volver a iniciar sesión en ese dispositivo.',
                    style: TextStyle(
                      color: JPCupertinoColors.secondaryLabel(context),
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: JPCupertinoColors.secondaryLabel(context),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      color: JPCupertinoColors.separator(context),
    );
  }

  Widget _buildDeviceRow(Map<String, dynamic> disp, bool isLast) {
    final ua = disp['user_agent'] as String? ?? '';
    final deviceName = _getDeviceName(ua);
    final isCurrent = disp['actual'] == true; // Backend should provide this

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isCurrent
                  ? JPColors.success
                  : JPCupertinoColors.systemGrey(context),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(_getDeviceIcon(ua), color: Colors.white, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCurrent ? '$deviceName (Este dispositivo)' : deviceName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: JPCupertinoColors.label(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${disp['ip'] ?? 'IP Desconocida'} • ${_formatearFecha(disp['creado'])}',
                  style: TextStyle(
                    fontSize: 13,
                    color: JPCupertinoColors.secondaryLabel(context),
                  ),
                ),
              ],
            ),
          ),
          if (!isCurrent)
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _cerrarSesion(disp['id'], deviceName),
              child: const Icon(
                CupertinoIcons.minus_circle_fill,
                color: JPColors.error,
                size: 22,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.device_phone_portrait,
            size: 64,
            color: JPCupertinoColors.tertiaryLabel(context),
          ),
          const SizedBox(height: 16),
          Text(
            'No hay sesiones activas',
            style: TextStyle(
              color: JPCupertinoColors.secondaryLabel(context),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
