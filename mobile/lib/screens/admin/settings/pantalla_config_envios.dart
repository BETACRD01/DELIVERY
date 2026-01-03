import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../apis/admin/envios_admin_api.dart';
import '../../../theme/jp_theme.dart';

class PantallaConfigEnviosAdmin extends StatefulWidget {
  const PantallaConfigEnviosAdmin({super.key});

  @override
  State<PantallaConfigEnviosAdmin> createState() =>
      _PantallaConfigEnviosAdminState();
}

class _PantallaConfigEnviosAdminState extends State<PantallaConfigEnviosAdmin> {
  final EnviosAdminApi _api = EnviosAdminApi();

  List<dynamic> _zonas = [];
  List<dynamic> _ciudades = [];
  bool _loading = true;
  String? _error;

  final _recargoCtrl = TextEditingController();
  final _horaInicioCtrl = TextEditingController();
  final _horaFinCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final config = await _api.obtenerConfiguracion();
      final zonas = await _api.listarZonas();
      final ciudades = await _api.listarCiudades();

      _recargoCtrl.text = (config['recargo_nocturno'] ?? '').toString();
      _horaInicioCtrl.text = (config['hora_inicio_nocturno'] ?? '').toString();
      _horaFinCtrl.text = (config['hora_fin_nocturno'] ?? '').toString();

      if (mounted) {
        setState(() {
          _zonas = zonas;
          _ciudades = ciudades;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'No se pudo cargar la configuración: $e';
          _loading = false;
        });
      }
    }
  }

  Future<void> _guardarConfig() async {
    try {
      final payload = {
        'recargo_nocturno': double.tryParse(_recargoCtrl.text) ?? 0,
        'hora_inicio_nocturno': int.tryParse(_horaInicioCtrl.text) ?? 0,
        'hora_fin_nocturno': int.tryParse(_horaFinCtrl.text) ?? 0,
      };
      final data = await _api.actualizarConfiguracion(payload);
      if (!mounted) return;
      _mostrarMensajeExito('Configuración guardada');
      setState(() {
        _recargoCtrl.text = (data['recargo_nocturno'] ?? '').toString();
        _horaInicioCtrl.text = (data['hora_inicio_nocturno'] ?? '').toString();
        _horaFinCtrl.text = (data['hora_fin_nocturno'] ?? '').toString();
      });
    } catch (e) {
      if (!mounted) return;
      _mostrarError('Error al guardar: $e');
    }
  }

  Future<void> _editarZona(Map<String, dynamic> zona) async {
    final nombreCtrl = TextEditingController(
      text: zona['nombre_display']?.toString() ?? '',
    );
    final baseCtrl = TextEditingController(
      text: zona['tarifa_base']?.toString() ?? '',
    );
    final incluidosCtrl = TextEditingController(
      text: zona['km_incluidos']?.toString() ?? '',
    );
    final extraCtrl = TextEditingController(
      text: zona['precio_km_extra']?.toString() ?? '',
    );
    final maxCtrl = TextEditingController(
      text: zona['max_distancia_km']?.toString() ?? '',
    );
    final ordenCtrl = TextEditingController(
      text: zona['orden']?.toString() ?? '',
    );

    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text('✏️ Editar Zona ${zona['codigo']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: JPCupertinoColors.systemGrey6(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '💡 Configura los parámetros de esta zona tarifaria.',
                  style: TextStyle(
                    fontSize: 12,
                    color: JPCupertinoColors.secondaryLabel(context),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildDialogField(
                controller: nombreCtrl,
                label: 'Nombre para Mostrar',
                hint: 'Ej: Zona Urbana Centro',
                helpText: 'Nombre visible para los usuarios',
              ),
              _buildDialogField(
                controller: baseCtrl,
                label: 'Tarifa Base (USD)',
                hint: 'Ej: 3.50',
                helpText: 'Costo inicial del envío en esta zona',
                isNumber: true,
              ),
              _buildDialogField(
                controller: incluidosCtrl,
                label: 'Kilómetros Incluidos',
                hint: 'Ej: 5',
                helpText: 'Km cubiertos por la tarifa base',
                isNumber: true,
              ),
              _buildDialogField(
                controller: extraCtrl,
                label: 'Precio por Km Extra (USD)',
                hint: 'Ej: 0.50',
                helpText:
                    'Costo adicional por cada km después de los incluidos',
                isNumber: true,
              ),
              _buildDialogField(
                controller: maxCtrl,
                label: 'Distancia Máxima (km)',
                hint: 'Vacío = sin límite',
                helpText: 'Límite de cobertura (dejar vacío para ∞)',
                isNumber: true,
              ),
              _buildDialogField(
                controller: ordenCtrl,
                label: 'Orden de Prioridad',
                hint: 'Ej: 1',
                helpText: 'Orden de aparición (menor = primero)',
                isNumber: true,
                isLast: true,
              ),
            ],
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context, false),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            child: const Text('💾 Guardar'),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final payload = {
      'nombre_display': nombreCtrl.text,
      'tarifa_base': double.tryParse(baseCtrl.text) ?? 0,
      'km_incluidos': double.tryParse(incluidosCtrl.text) ?? 0,
      'precio_km_extra': double.tryParse(extraCtrl.text) ?? 0,
      'max_distancia_km': maxCtrl.text.isEmpty
          ? null
          : double.tryParse(maxCtrl.text),
      'orden': int.tryParse(ordenCtrl.text) ?? 0,
    };

    await _api.actualizarZona(zona['id'] as int, payload);
    await _cargar();
  }

  Widget _buildDialogField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String helpText,
    bool isNumber = false,
    bool isLast = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: JPCupertinoColors.label(context),
          ),
        ),
        const SizedBox(height: 4),
        CupertinoTextField(
          controller: controller,
          placeholder: hint,
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
        ),
        const SizedBox(height: 2),
        Text(
          helpText,
          style: TextStyle(
            fontSize: 10,
            color: JPCupertinoColors.secondaryLabel(context),
          ),
        ),
        if (!isLast) const SizedBox(height: 12),
      ],
    );
  }

  Future<void> _editarCiudad(Map<String, dynamic> ciudad) async {
    final nombreCtrl = TextEditingController(
      text: ciudad['nombre']?.toString() ?? '',
    );
    final latCtrl = TextEditingController(
      text: ciudad['lat']?.toString() ?? '',
    );
    final lngCtrl = TextEditingController(
      text: ciudad['lng']?.toString() ?? '',
    );
    final radioCtrl = TextEditingController(
      text: ciudad['radio_max_cobertura_km']?.toString() ?? '',
    );
    bool activo = ciudad['activo'] == true;

    // Use StatefulBuilder to handle switch state inside dialog
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return CupertinoAlertDialog(
            title: Text('🏢 Editar Hub ${ciudad['codigo'] ?? ''}'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: JPCupertinoColors.systemGrey6(context),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '💡 Configura los parámetros de este centro de operaciones (Hub).',
                      style: TextStyle(
                        fontSize: 12,
                        color: JPCupertinoColors.secondaryLabel(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDialogField(
                    controller: nombreCtrl,
                    label: 'Nombre del Hub',
                    hint: 'Ej: Centro Comercial Plaza',
                    helpText: 'Nombre identificador del punto de operación',
                  ),
                  Text(
                    'Ubicación en el Mapa',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: JPCupertinoColors.label(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Coordenadas GPS del centro del hub',
                    style: TextStyle(
                      fontSize: 10,
                      color: JPCupertinoColors.secondaryLabel(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: CupertinoTextField(
                          controller: latCtrl,
                          placeholder: 'Latitud',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          prefix: const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text('📍', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: CupertinoTextField(
                          controller: lngCtrl,
                          placeholder: 'Longitud',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          prefix: const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Text('📍', style: TextStyle(fontSize: 12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildDialogField(
                    controller: radioCtrl,
                    label: 'Radio de Cobertura (km)',
                    hint: 'Ej: 15',
                    helpText:
                        'Distancia máxima que cubre este hub desde su centro',
                    isNumber: true,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: activo
                          ? CupertinoColors.activeGreen
                                .resolveFrom(context)
                                .withValues(alpha: 0.1)
                          : JPCupertinoColors.systemRed(
                              context,
                            ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: activo
                            ? CupertinoColors.activeGreen
                                  .resolveFrom(context)
                                  .withValues(alpha: 0.3)
                            : JPCupertinoColors.systemRed(
                                context,
                              ).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activo ? 'Hub Activo' : 'Hub Inactivo',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: activo
                                      ? CupertinoColors.activeGreen.resolveFrom(
                                          context,
                                        )
                                      : JPCupertinoColors.systemRed(context),
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                activo
                                    ? 'Recibe pedidos normalmente'
                                    : 'No recibirá pedidos nuevos',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: JPCupertinoColors.secondaryLabel(
                                    context,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        CupertinoSwitch(
                          value: activo,
                          onChanged: (v) => setStateDialog(() => activo = v),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              CupertinoDialogAction(
                isDestructiveAction: true,
                child: const Text('Cancelar'),
                onPressed: () => Navigator.pop(context, false),
              ),
              CupertinoDialogAction(
                isDefaultAction: true,
                child: const Text('💾 Guardar'),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          );
        },
      ),
    );

    if (confirmed != true) return;

    final payload = {
      'nombre': nombreCtrl.text,
      'lat': double.tryParse(latCtrl.text) ?? 0,
      'lng': double.tryParse(lngCtrl.text) ?? 0,
      'radio_max_cobertura_km': double.tryParse(radioCtrl.text) ?? 0,
      'activo': activo,
    };

    await _api.actualizarCiudad(ciudad['id'] as int, payload);
    await _cargar();
  }

  void _mostrarMensajeExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: JPCupertinoColors.activeGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: JPColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = JPCupertinoColors.background(context);
    final primaryColor = JPCupertinoColors.primary(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Configurar Envíos'),
        backgroundColor: bgColor,
        scrolledUnderElevation: 0,
        centerTitle: true,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: JPCupertinoColors.label(context),
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        iconTheme: IconThemeData(color: primaryColor),
      ),
      body: _loading
          ? const Center(child: CupertinoActivityIndicator())
          : _error != null
          ? Center(
              child: Text(
                _error!,
                style: TextStyle(color: JPCupertinoColors.label(context)),
              ),
            )
          : RefreshIndicator(
              onRefresh: _cargar,
              color: primaryColor,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildSectionTitle('Configuración General'),
                  _buildConfigCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Zonas Tarifarias'),
                  _buildZonasList(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Hubs / Ciudades'),
                  _buildCiudadesList(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: JPCupertinoColors.secondaryLabel(context),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildConfigCard() {
    final cardColor = JPCupertinoColors.surface(context);
    final textColor = JPCupertinoColors.label(context);
    final hintColor = JPCupertinoColors.secondaryLabel(context);
    final primaryColor = JPCupertinoColors.primary(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Descripción de la sección
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(CupertinoIcons.info_circle, color: primaryColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Configura el recargo adicional que se aplica a los envíos realizados en horario nocturno.',
                    style: TextStyle(color: hintColor, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Recargo Nocturno (USD)',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Monto adicional que se suma a la tarifa base durante las horas nocturnas.',
            style: TextStyle(color: hintColor, fontSize: 12),
          ),
          const SizedBox(height: 8),
          CupertinoTextField(
            controller: _recargoCtrl,
            placeholder: 'Ej: 2.50',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(color: textColor),
            prefix: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Text('\$', style: TextStyle(color: hintColor)),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Horario Nocturno',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Define el rango de horas en formato 24h (0-23) donde aplica el recargo.',
            style: TextStyle(color: hintColor, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hora Inicio',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _horaInicioCtrl,
                      placeholder: 'Ej: 18 (6:00 PM)',
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: textColor),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  CupertinoIcons.arrow_right,
                  color: hintColor,
                  size: 16,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hora Fin',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    CupertinoTextField(
                      controller: _horaFinCtrl,
                      placeholder: 'Ej: 6 (6:00 AM)',
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: textColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '💡 Ejemplo: Si configuras 18 a 6, el recargo aplica de 6:00 PM a 6:00 AM.',
            style: TextStyle(
              color: hintColor,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton.filled(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              minimumSize: const Size(200, 50),
              onPressed: _guardarConfig,
              child: const Text('Guardar Configuración'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZonasList() {
    final cardColor = JPCupertinoColors.surface(context);
    final textColor = JPCupertinoColors.label(context);
    final hintColor = JPCupertinoColors.secondaryLabel(context);
    final primaryColor = JPCupertinoColors.primary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Descripción explicativa
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: JPColors.dashboardAmber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: JPColors.dashboardAmber.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.map,
                    color: JPColors.dashboardAmber,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '¿Cómo funcionan las zonas?',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• Tarifa Base: Costo inicial del envío\n'
                '• Km Incluidos: Distancia cubierta por la tarifa base\n'
                '• Precio Km Extra: Costo por cada km adicional\n'
                '• Max Distancia: Límite máximo de cobertura (∞ = sin límite)',
                style: TextStyle(color: hintColor, fontSize: 12, height: 1.5),
              ),
            ],
          ),
        ),
        // Lista de zonas
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: _zonas.asMap().entries.map((entry) {
              final index = entry.key;
              final z = entry.value;
              final isLast = index == _zonas.length - 1;

              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            z['codigo'] ?? '',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            z['nombre_display'] ?? 'Sin nombre',
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildZonaChip('💰 Base', '\$${z['tarifa_base']}'),
                          _buildZonaChip(
                            '📏 Incluye',
                            '${z['km_incluidos']} km',
                          ),
                          _buildZonaChip(
                            '➕ Extra',
                            '\$${z['precio_km_extra']}/km',
                          ),
                          _buildZonaChip(
                            '🎯 Max',
                            '${z['max_distancia_km'] ?? '∞'} km',
                          ),
                        ],
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        CupertinoIcons.pencil,
                        color: primaryColor,
                        size: 18,
                      ),
                    ),
                    onTap: () => _editarZona(Map<String, dynamic>.from(z)),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 16,
                      color: JPCupertinoColors.separator(context),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildZonaChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: JPCupertinoColors.systemGrey6(context),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: JPCupertinoColors.secondaryLabel(context),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCiudadesList() {
    final cardColor = JPCupertinoColors.surface(context);
    final textColor = JPCupertinoColors.label(context);
    final hintColor = JPCupertinoColors.secondaryLabel(context);
    final primaryColor = JPCupertinoColors.primary(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Descripción explicativa
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: JPColors.dashboardBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: JPColors.dashboardBlue.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    CupertinoIcons.building_2_fill,
                    color: JPColors.dashboardBlue,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '¿Qué son los Hubs?',
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• Hub: Centro de operaciones desde donde salen los envíos\n'
                '• Coordenadas (Lat/Lng): Ubicación exacta del hub en el mapa\n'
                '• Radio de Cobertura: Distancia máxima que cubre el hub\n'
                '• Estado: Activo permite recibir pedidos, Inactivo lo desactiva',
                style: TextStyle(color: hintColor, fontSize: 12, height: 1.5),
              ),
            ],
          ),
        ),
        // Lista de ciudades/hubs
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: _ciudades.asMap().entries.map((entry) {
              final index = entry.key;
              final c = entry.value;
              final isLast = index == _ciudades.length - 1;
              final isActive = c['activo'] == true;

              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    title: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isActive
                                ? JPColors.success.withValues(alpha: 0.15)
                                : JPCupertinoColors.systemGrey(
                                    context,
                                  ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            CupertinoIcons.location_solid,
                            color: isActive
                                ? JPColors.success
                                : JPCupertinoColors.systemGrey(context),
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c['nombre'] ?? 'Sin nombre',
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                c['codigo'] ?? '',
                                style: TextStyle(
                                  color: hintColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? JPColors.success.withValues(alpha: 0.15)
                                : JPColors.error.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? JPColors.success
                                      : JPColors.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isActive ? 'ACTIVO' : 'INACTIVO',
                                style: TextStyle(
                                  color: isActive
                                      ? JPColors.success
                                      : JPColors.error,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildCiudadChip('📍 Lat', '${c['lat']}'),
                          _buildCiudadChip('📍 Lng', '${c['lng']}'),
                          _buildCiudadChip(
                            '📡 Radio',
                            '${c['radio_max_cobertura_km']} km',
                          ),
                        ],
                      ),
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        CupertinoIcons.pencil,
                        color: primaryColor,
                        size: 18,
                      ),
                    ),
                    onTap: () => _editarCiudad(Map<String, dynamic>.from(c)),
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      indent: 16,
                      color: JPCupertinoColors.separator(context),
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildCiudadChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: JPCupertinoColors.systemGrey6(context),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: JPCupertinoColors.secondaryLabel(context),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
