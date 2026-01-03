// lib/screens/user/catalogo/pantalla_notificaciones.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/core/notificacion_model.dart';
import '../../../providers/core/notificaciones_provider.dart';
import '../../../theme/jp_theme.dart';
import '../../../theme/primary_colors.dart';

/// Inbox unificado (push + internas) accesible desde la campana
class PantallaNotificaciones extends StatefulWidget {
  const PantallaNotificaciones({super.key});

  @override
  State<PantallaNotificaciones> createState() => _PantallaNotificacionesState();
}

class _PantallaNotificacionesState extends State<PantallaNotificaciones>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<NotificacionesProvider>().recargar();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificacionesProvider>(
      builder: (context, inbox, _) {
        final noLeidasCount = inbox.noLeidas.length;
        final totalCount = inbox.todas.length;
        final groupedBackground = CupertinoColors.systemGroupedBackground
            .resolveFrom(context);

        return Scaffold(
          backgroundColor: groupedBackground,
          appBar: AppBar(
            backgroundColor: groupedBackground,
            foregroundColor: JPCupertinoColors.label(context),
            title: Text(
              'Notificaciones',
              style: TextStyle(
                color: JPCupertinoColors.label(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            centerTitle: true,
            elevation: 0,
            actions: [
              if (noLeidasCount > 0)
                TextButton(
                  onPressed: inbox.marcarTodasComoLeidas,
                  child: Text(
                    'Marcar todas',
                    style: TextStyle(
                      color: AppColorsPrimary.main,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: JPCupertinoColors.systemGrey5(context),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: JPCupertinoColors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: JPCupertinoColors.label(context),
                    unselectedLabelColor: CupertinoColors.secondaryLabel
                        .resolveFrom(context),
                    tabs: [
                      Tab(text: 'No leídas ($noLeidasCount)'),
                      Tab(text: 'Todas ($totalCount)'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: _buildBody(inbox),
        );
      },
    );
  }

  Widget _buildBody(NotificacionesProvider inbox) {
    if (inbox.cargando) {
      return const Center(child: CupertinoActivityIndicator());
    }

    if (inbox.error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 56,
                color: JPCupertinoColors.placeholderText(context),
              ),
              SizedBox(height: 12),
              Text(
                inbox.error!,
                style: TextStyle(
                  color: JPCupertinoColors.secondaryLabel(context),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),
              TextButton(onPressed: inbox.recargar, child: Text('Reintentar')),
            ],
          ),
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildListaNotificaciones(inbox.noLeidas, inbox, esNoLeidas: true),
        _buildListaNotificaciones(inbox.todas, inbox, esNoLeidas: false),
      ],
    );
  }

  Widget _buildListaNotificaciones(
    List<NotificacionModel> notificaciones,
    NotificacionesProvider inbox, {
    required bool esNoLeidas,
  }) {
    if (notificaciones.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.bell_slash,
              size: 72,
              color: JPCupertinoColors.systemGrey3(context),
            ),
            SizedBox(height: 12),
            Text(
              esNoLeidas
                  ? 'No tienes notificaciones nuevas'
                  : 'No hay notificaciones',
              style: TextStyle(
                fontSize: 16,
                color: JPCupertinoColors.secondaryLabel(context),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: inbox.recargar,
      child: ListView.separated(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 20),
        itemCount: notificaciones.length,
        separatorBuilder: (_, _) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notificacion = notificaciones[index];
          return _NotificacionCard(
            notificacion: notificacion,
            onTap: () => _abrirNotificacion(notificacion, inbox),
            onMarcarLeida: () => _marcarComoLeida(notificacion, inbox),
            onEliminar: () => inbox.eliminar(notificacion.id),
          );
        },
      ),
    );
  }

  void _abrirNotificacion(
    NotificacionModel notificacion,
    NotificacionesProvider inbox,
  ) {
    if (!notificacion.leida) {
      _marcarComoLeida(notificacion, inbox);
    }

    switch (notificacion.tipo) {
      case 'pedido':
      case 'promocion':
      case 'pago':
        // En este paso solo marcamos como leída; la navegación específica se puede
        // agregar usando metadata cuando esté listo.
        break;
      default:
        _mostrarDetalleNotificacion(notificacion);
    }
  }

  void _mostrarDetalleNotificacion(NotificacionModel notificacion) {
    showCupertinoDialog(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Column(
          children: [
            Icon(notificacion.icono, color: notificacion.color, size: 32),
            SizedBox(height: 8),
            Text(notificacion.titulo),
          ],
        ),
        content: Column(
          children: [
            SizedBox(height: 8),
            Text(notificacion.mensaje),
            SizedBox(height: 8),
            Text(
              notificacion.tiempoTranscurrido,
              style: TextStyle(
                fontSize: 12,
                color: JPCupertinoColors.secondaryLabel(context),
              ),
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _marcarComoLeida(
    NotificacionModel notificacion,
    NotificacionesProvider inbox,
  ) {
    inbox.marcarComoLeida(notificacion.id);
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// WIDGETS AUXILIARES
// ═════════════════════════════════════════════════════════════════════════════

class _NotificacionCard extends StatelessWidget {
  final NotificacionModel notificacion;
  final VoidCallback onTap;
  final VoidCallback onMarcarLeida;
  final VoidCallback onEliminar;

  const _NotificacionCard({
    required this.notificacion,
    required this.onTap,
    required this.onMarcarLeida,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notificacion.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: JPCupertinoColors.error(context),
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        child: Icon(Icons.delete, color: JPCupertinoColors.white, size: 28),
      ),
      onDismissed: (_) => onEliminar(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: JPCupertinoColors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: JPCupertinoColors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: notificacion.leida
                  ? JPCupertinoColors.systemGrey5(context)
                  : notificacion.color.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: notificacion.leida
                      ? JPCupertinoColors.secondaryBackground(context)
                      : notificacion.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notificacion.icono,
                  color: notificacion.color,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notificacion.titulo,
                            style: TextStyle(
                              fontWeight: notificacion.leida
                                  ? FontWeight.w600
                                  : FontWeight.bold,
                              fontSize: 15,
                              color: JPCupertinoColors.label(context),
                            ),
                          ),
                        ),
                        if (!notificacion.leida)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: notificacion.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      notificacion.mensaje,
                      style: TextStyle(
                        fontSize: 13,
                        color: JPCupertinoColors.secondaryLabel(context),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          notificacion.tiempoTranscurrido,
                          style: TextStyle(
                            fontSize: 12,
                            color: JPCupertinoColors.systemGrey(context),
                          ),
                        ),
                        if (!notificacion.leida) ...[
                          SizedBox(width: 8),
                          TextButton(
                            onPressed: onMarcarLeida,
                            child: Text(
                              'Marcar leída',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
