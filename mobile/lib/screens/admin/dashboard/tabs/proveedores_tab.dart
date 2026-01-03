// lib/screens/admin/dashboard/tabs/proveedores_tab.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../controllers/admin/dashboard_controller.dart';
import '../../../../theme/jp_theme.dart';

class ProveedoresTab extends StatelessWidget {
  const ProveedoresTab({super.key});

  Widget build(BuildContext context) {
    return Consumer<DashboardController>(
      builder: (context, controller, child) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.store_mall_directory_outlined,
                  size: 80,
                  color: JPCupertinoColors.systemGrey5(context),
                ),
                const SizedBox(height: 16),
                Text(
                  'Gestión de Proveedores',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: JPCupertinoColors.secondaryLabel(context),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Verifica y gestiona los proveedores de la plataforma',
                  style: TextStyle(
                    fontSize: 15,
                    color: JPCupertinoColors.tertiaryLabel(context),
                  ),
                  textAlign: TextAlign.center,
                ),
                if (controller.proveedoresPendientes > 0) ...[
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: JPColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: JPColors.warning.withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          CupertinoIcons.exclamationmark_triangle_fill,
                          color: JPColors.warning,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${controller.proveedoresPendientes} proveedores esperando verificación',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: JPCupertinoColors.label(context),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
