// lib/screens/user/perfil/editar/pantalla_editar_foto.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../theme/jp_theme.dart';
import '../../../../services/usuarios/usuarios_service.dart';
import 'package:mobile/services/core/api/api_exception.dart';
import '../../../../widgets/util/image_orientation_fixer.dart';

/// 📸 Pantalla para cambiar foto de perfil
class PantallaEditarFoto extends StatefulWidget {
  final String? fotoActual;

  const PantallaEditarFoto({super.key, this.fotoActual});

  @override
  State<PantallaEditarFoto> createState() => _PantallaEditarFotoState();
}

class _PantallaEditarFotoState extends State<PantallaEditarFoto> {
  final _usuarioService = UsuarioService();
  final _imagePicker = ImagePicker();

  File? _imagenSeleccionada;
  bool _guardando = false;

  // ══════════════════════════════════════════════════════════════════════════
  // 📸 SELECCIONAR IMAGEN
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _seleccionarDesdeGaleria() async {
    try {
      final XFile? imagen = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        requestFullMetadata: true, // Asegura corrección de orientación EXIF
      );

      if (imagen != null) {
        // Corregir orientación
        final fixedImage = await ImageOrientationFixer.fixAndCompress(
          File(imagen.path),
        );

        setState(() {
          _imagenSeleccionada = fixedImage;
        });
      }
    } catch (e) {
      if (!mounted) return;
      JPSnackbar.error(context, 'Error al seleccionar imagen: $e');
    }
  }

  Future<void> _tomarFoto() async {
    try {
      final XFile? imagen = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        preferredCameraDevice:
            CameraDevice.front, // Cámara frontal para selfies
        requestFullMetadata:
            true, // Corrige la orientación EXIF automáticamente
      );

      if (imagen != null) {
        // Corregir orientación
        final fixedImage = await ImageOrientationFixer.fixAndCompress(
          File(imagen.path),
        );

        setState(() {
          _imagenSeleccionada = fixedImage;
        });
      }
    } catch (e) {
      if (!mounted) return;
      JPSnackbar.error(context, 'Error al tomar foto: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 💾 GUARDAR CAMBIOS
  // ══════════════════════════════════════════════════════════════════════════
  Future<void> _guardarCambios() async {
    if (_imagenSeleccionada == null) {
      JPSnackbar.error(context, 'Selecciona una imagen primero');
      return;
    }

    setState(() => _guardando = true);

    try {
      await _usuarioService.subirFotoPerfil(_imagenSeleccionada!);

      if (!mounted) return;

      JPSnackbar.success(context, 'Foto actualizada exitosamente');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      JPSnackbar.error(context, e.getUserFriendlyMessage());
    } catch (e) {
      if (!mounted) return;
      JPSnackbar.error(context, 'Error al actualizar foto');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  Future<void> _eliminarFoto() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar foto'),
        content: Text('¿Estás seguro de eliminar tu foto de perfil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: JPCupertinoColors.error(context),
            ),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _guardando = true);

    try {
      await _usuarioService.eliminarFotoPerfil();

      if (!mounted) return;
      JPSnackbar.success(context, 'Foto eliminada');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) return;
      JPSnackbar.error(context, e.getUserFriendlyMessage());
    } catch (e) {
      if (!mounted) return;
      JPSnackbar.error(context, 'Error al eliminar foto');
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }
  // ══════════════════════════════════════════════════════════════════════════
  // 🎨 BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: JPCupertinoColors.background(context),
      appBar: AppBar(
        title: Text('Cambiar Foto de Perfil'),
        backgroundColor: JPCupertinoColors.white,
        foregroundColor: JPCupertinoColors.label(context),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: JPCupertinoColors.systemGrey5(context),
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeaderCard(),
            SizedBox(height: 24),
            if (_imagenSeleccionada == null) ...[
              _buildBotonOpcion(
                icono: Icons.photo_library_rounded,
                texto: 'Seleccionar de Galería',
                onTap: _seleccionarDesdeGaleria,
              ),
              SizedBox(height: 14),
              _buildBotonOpcion(
                icono: Icons.camera_alt_rounded,
                texto: 'Tomar Foto',
                onTap: _tomarFoto,
              ),
              if (widget.fotoActual != null) ...[
                SizedBox(height: 14),
                _buildBotonOpcion(
                  icono: Icons.delete_outline,
                  texto: 'Eliminar Foto Actual',
                  color: JPCupertinoColors.error(context),
                  onTap: _eliminarFoto,
                ),
              ],
            ] else ...[
              ElevatedButton.icon(
                onPressed: _guardando ? null : _guardarCambios,
                icon: _guardando
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CupertinoActivityIndicator(radius: 14),
                      )
                    : Icon(Icons.check_rounded),
                label: Text(_guardando ? 'Guardando...' : 'Guardar Cambios'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: JPCupertinoColors.success(context),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _guardando
                    ? null
                    : () {
                        setState(() => _imagenSeleccionada = null);
                      },
                icon: Icon(Icons.refresh_rounded),
                label: Text('Cambiar selección'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 22, horizontal: 16),
      decoration: BoxDecoration(
        color: JPCupertinoColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: JPCupertinoColors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Elige desde galería o toma una foto nueva.',
            style: TextStyle(
              color: JPCupertinoColors.secondaryLabel(context),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16),
          _buildPreview(),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: JPCupertinoColors.surface(context),
        boxShadow: [
          BoxShadow(
            color: JPCupertinoColors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        gradient: LinearGradient(
          colors: [
            JPCupertinoColors.systemGrey6(context),
            JPCupertinoColors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: ClipOval(
        child: _imagenSeleccionada != null
            ? Image.file(_imagenSeleccionada!, fit: BoxFit.cover)
            : widget.fotoActual != null
            ? Image.network(
                widget.fotoActual!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: JPCupertinoColors.primary(context).withValues(alpha: 0.1),
      child: Icon(
        Icons.person,
        size: 80,
        color: JPCupertinoColors.primary(context),
      ),
    );
  }

  Widget _buildBotonOpcion({
    required IconData icono,
    required String texto,
    required VoidCallback onTap,
    Color? color,
  }) {
    final baseColor = color ?? JPCupertinoColors.primary(context);
    return InkWell(
      onTap: _guardando ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: JPCupertinoColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: baseColor.withValues(alpha: 0.5),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: JPCupertinoColors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: baseColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icono, color: baseColor, size: 22),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: color != null
                      ? baseColor
                      : JPCupertinoColors.label(context),
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: baseColor),
          ],
        ),
      ),
    );
  }
}
