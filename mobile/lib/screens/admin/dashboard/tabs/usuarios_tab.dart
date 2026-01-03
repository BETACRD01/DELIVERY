// lib/screens/admin/dashboard/tabs/usuarios_tab.dart
import 'package:mobile/theme/jp_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UsuariosTab extends StatelessWidget {
  const UsuariosTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.person_2_fill,
              size: 80,
              color: JPCupertinoColors.systemGrey5(context),
            ),
            const SizedBox(height: 16),
            Text(
              'Gestión de Usuarios',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: JPCupertinoColors.secondaryLabel(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aquí podrás ver y gestionar todos los usuarios',
              style: TextStyle(
                fontSize: 15,
                color: JPCupertinoColors.tertiaryLabel(context),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            CupertinoButton.filled(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Gestión de usuarios estará disponible pronto',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Agregar Usuario'),
            ),
          ],
        ),
      ),
    );
  }
}
