import 'package:flutter/material.dart';
import 'package:mobile/theme/jp_theme.dart';
import 'package:flutter/cupertino.dart';

class PantallaVerComprobanteUsuario extends StatelessWidget {
  final String comprobanteUrl;

  const PantallaVerComprobanteUsuario({
    super.key,
    required this.comprobanteUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JPCupertinoColors.black,
      appBar: AppBar(
        title: Text('Comprobante'),
        backgroundColor: JPCupertinoColors.black,
        foregroundColor: JPCupertinoColors.white,
      ),
      body: InteractiveViewer(
        minScale: 0.8,
        maxScale: 4,
        child: Center(
          child: Image.network(
            comprobanteUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CupertinoActivityIndicator(radius: 14),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  'No se pudo cargar el comprobante',
                  style: TextStyle(color: JPCupertinoColors.white),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
