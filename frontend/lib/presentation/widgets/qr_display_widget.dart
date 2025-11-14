import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../config/theme.dart';

/// Widget para mostrar código QR de un equipo
class QRDisplayWidget extends StatelessWidget {
  final String qrData;
  final String? equipoInfo;
  final double size;

  const QRDisplayWidget({
    super.key,
    required this.qrData,
    this.equipoInfo,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Código QR
          QrImageView(
            data: qrData,
            version: QrVersions.auto,
            size: size,
            backgroundColor: Colors.white,
            eyeStyle: const QrEyeStyle(
              eyeShape: QrEyeShape.square,
              color: AppTheme.primaryColor,
            ),
            dataModuleStyle: const QrDataModuleStyle(
              dataModuleShape: QrDataModuleShape.square,
              color: AppTheme.primaryColor,
            ),
            embeddedImage: null, // Se puede agregar logo si se desea
            embeddedImageStyle: const QrEmbeddedImageStyle(
              size: Size(40, 40),
            ),
          ),

          // Información del equipo (opcional)
          if (equipoInfo != null) ...[
            const SizedBox(height: 16),
            Text(
              equipoInfo!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],

          // Código debajo del QR
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.greyLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              qrData,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                color: AppTheme.greyDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog para mostrar código QR en pantalla completa
class QRDisplayDialog extends StatelessWidget {
  final String qrData;
  final String equipoInfo;

  const QRDisplayDialog({
    super.key,
    required this.qrData,
    required this.equipoInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Código QR',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            QRDisplayWidget(
              qrData: qrData,
              equipoInfo: equipoInfo,
              size: 250,
            ),
            const SizedBox(height: 24),
            const Text(
              'Escanea este código para identificar el equipo',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.greyDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
