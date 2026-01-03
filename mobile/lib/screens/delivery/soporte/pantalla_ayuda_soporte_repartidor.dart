// lib/screens/delivery/soporte/pantalla_ayuda_soporte_repartidor.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/jp_theme.dart';

/// 🧰 Pantalla de Ayuda y Soporte para Repartidor
/// Diseño nativo iOS (Cupertino)
class PantallaAyudaSoporteRepartidor extends StatelessWidget {
  const PantallaAyudaSoporteRepartidor({super.key});

  @override
  Widget build(BuildContext context) {
    // Colores dinámicos del tema
    final backgroundColor = JPCupertinoColors.background(context);
    final navBarColor = JPCupertinoColors.surface(
      context,
    ).withValues(alpha: 0.9);

    return Material(
      type: MaterialType.transparency,
      child: CupertinoPageScaffold(
        backgroundColor: backgroundColor,
        navigationBar: CupertinoNavigationBar(
          backgroundColor: navBarColor,
          border: null,
          middle: const Text(
            'Ayuda y Soporte',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildSeccionContacto(context),
                const SizedBox(height: 24),
                _buildSeccionFAQ(context),
                const SizedBox(height: 32),
                _buildBotonSoporte(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final primaryColor = JPCupertinoColors.systemBlue(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.chat_bubble_2_fill,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Necesitas ayuda?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Estamos aquí para ayudarte',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeccionContacto(BuildContext context) {
    final cardBg = JPCupertinoColors.secondarySurface(context);
    final cardBorder = JPCupertinoColors.separator(context);
    final successColor = JPCupertinoColors.success(context);
    final accentColor = JPCupertinoColors.systemBlue(context);
    final whatsappColor = const Color(
      0xFF25D366,
    ); // WhatsApp brand color usually stays explicit

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'CONTACTO DIRECTO'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            children: [
              _buildContactTile(
                context,
                icon: CupertinoIcons.phone_fill,
                iconColor: successColor,
                title: 'Línea de Soporte',
                subtitle: '+593 98 765 4321',
                onTap: () => _llamar('+593987654321'),
              ),
              Container(
                height: 0.5,
                margin: const EdgeInsets.only(left: 54),
                color: cardBorder,
              ),
              _buildContactTile(
                context,
                icon: CupertinoIcons.bubble_left_fill,
                iconColor: whatsappColor,
                title: 'WhatsApp',
                subtitle: 'Escríbenos por WhatsApp',
                onTap: () => _abrirWhatsApp('+593987654321'),
              ),
              Container(
                height: 0.5,
                margin: const EdgeInsets.only(left: 54),
                color: cardBorder,
              ),
              _buildContactTile(
                context,
                icon: CupertinoIcons.mail_solid,
                iconColor: accentColor,
                title: 'Correo de Soporte',
                subtitle: 'soporte@deliberapp.com',
                onTap: () => _enviarCorreo('soporte@deliberapp.com'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: JPCupertinoColors.label(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: JPCupertinoColors.secondaryLabel(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              CupertinoIcons.chevron_forward,
              size: 16,
              color: JPCupertinoColors.systemGrey3(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccionFAQ(BuildContext context) {
    final cardBg = JPCupertinoColors.secondarySurface(context);
    final cardBorder = JPCupertinoColors.separator(context);

    final faqs = [
      {
        'pregunta': '¿Cómo acepto un pedido?',
        'respuesta':
            'Cuando estés disponible, los pedidos cercanos aparecerán en la lista de Pendientes. Selecciona uno y presiona "Aceptar pedido".',
      },
      {
        'pregunta': '¿Qué hago si no puedo completar una entrega?',
        'respuesta':
            'Contacta al soporte a través de WhatsApp o teléfono para reportar el problema y recibir instrucciones.',
      },
      {
        'pregunta': '¿Cómo cambio mi disponibilidad?',
        'respuesta':
            'En la pestaña Perfil, usa el botón para activar o desactivar tu disponibilidad para recibir pedidos.',
      },
      {
        'pregunta': '¿Cómo actualizo mi perfil y datos bancarios?',
        'respuesta':
            'Desde "Mi Perfil" puedes editar tu foto, teléfono y datos bancarios para recibir pagos.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'PREGUNTAS FRECUENTES'),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            children: faqs.asMap().entries.map((entry) {
              final isLast = entry.key == faqs.length - 1;
              return Column(
                children: [
                  _buildFAQItem(context, entry.value),
                  if (!isLast)
                    Container(
                      height: 0.5,
                      margin: const EdgeInsets.only(left: 16),
                      color: cardBorder,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(BuildContext context, Map<String, String> faq) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Text(
          faq['pregunta']!,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: JPCupertinoColors.label(context),
          ),
        ),
        iconColor: JPCupertinoColors.systemGrey(context),
        collapsedIconColor: JPCupertinoColors.systemGrey(context),
        children: [
          Text(
            faq['respuesta']!,
            style: TextStyle(
              fontSize: 14,
              color: JPCupertinoColors.secondaryLabel(context),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonSoporte(BuildContext context) {
    final successColor = JPCupertinoColors.success(context);

    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () => _abrirWhatsApp('+593987654321'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [successColor, successColor.withValues(alpha: 0.85)],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: successColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.chat_bubble_fill,
              color: Colors.white,
              size: 22,
            ),
            SizedBox(width: 10),
            Text(
              'Contactar por WhatsApp',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: JPCupertinoColors.systemGrey(context),
          letterSpacing: -0.08,
        ),
      ),
    );
  }

  // Acciones
  Future<void> _llamar(String telefono) async {
    final url = Uri.parse('tel:$telefono');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _abrirWhatsApp(String telefono) async {
    final url = Uri.parse(
      'https://wa.me/$telefono?text=Hola, necesito ayuda con la app de repartidor',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _enviarCorreo(String email) async {
    final url = Uri.parse('mailto:$email?subject=Soporte Repartidor');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
