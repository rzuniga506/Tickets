import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../logic/equipos/equipo_cubit.dart';
import '../../../logic/equipos/equipo_state.dart';
import '../../../config/theme.dart';
import '../../../core/di/injection.dart';
import 'equipo_detail_screen.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController? _scannerController;
  bool _isProcessing = false;
  bool _flashOn = false;
  bool _frontCamera = false;

  @override
  void initState() {
    super.initState();
    _initializeScanner();
  }

  void _initializeScanner() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: _frontCamera ? CameraFacing.front : CameraFacing.back,
      torchEnabled: _flashOn,
    );
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String? code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() {
      _isProcessing = true;
    });

    // Buscar equipo por código QR
    context.read<EquipoCubit>().getEquipoByQR(code);
  }

  void _toggleFlash() {
    setState(() {
      _flashOn = !_flashOn;
    });
    _scannerController?.toggleTorch();
  }

  void _switchCamera() {
    setState(() {
      _frontCamera = !_frontCamera;
    });
    _scannerController?.dispose();
    _initializeScanner();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear Código QR'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: _toggleFlash,
          ),
          IconButton(
            icon: Icon(
                _frontCamera ? Icons.camera_front : Icons.camera_rear),
            onPressed: _switchCamera,
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: BlocConsumer<EquipoCubit, EquipoState>(
        listener: (context, state) {
          if (state is EquipoFoundByQR) {
            // Navegar al detalle del equipo encontrado
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => getIt<EquipoCubit>(),
                  child: EquipoDetailScreen(equipoId: state.equipo.id),
                ),
              ),
            );
          } else if (state is EquipoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
                action: SnackBarAction(
                  label: 'Reintentar',
                  textColor: Colors.white,
                  onPressed: () {
                    setState(() {
                      _isProcessing = false;
                    });
                  },
                ),
              ),
            );
            setState(() {
              _isProcessing = false;
            });
          }
        },
        builder: (context, state) {
          return Stack(
            children: [
              // Scanner
              if (_scannerController != null)
                MobileScanner(
                  controller: _scannerController!,
                  onDetect: _onDetect,
                ),

              // Overlay con marco de escaneo
              CustomPaint(
                painter: ScannerOverlayPainter(),
                child: Container(),
              ),

              // Instrucciones
              Positioned(
                top: MediaQuery.of(context).padding.top + 80,
                left: 0,
                right: 0,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Apunta la cámara al código QR del equipo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              // Indicador de carga
              if (state is EquipoActionLoading || _isProcessing)
                Container(
                  color: Colors.black.withOpacity(0.7),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Buscando equipo...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Botón de entrada manual
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: OutlinedButton.icon(
                    onPressed: _isProcessing
                        ? null
                        : () => _showManualEntryDialog(),
                    icon: const Icon(Icons.keyboard, color: Colors.white),
                    label: const Text(
                      'Ingresar Código Manualmente',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white, width: 2),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showManualEntryDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ingresar Código QR'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Código QR',
            hintText: 'Ingrese el código del equipo',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(dialogContext);
                setState(() {
                  _isProcessing = true;
                });
                context.read<EquipoCubit>().getEquipoByQR(controller.text);
              }
            },
            child: const Text('Buscar'),
          ),
        ],
      ),
    );
  }
}

/// Painter para dibujar el marco de escaneo
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final cutoutSize = size.width * 0.7;
    final cutoutLeft = (size.width - cutoutSize) / 2;
    final cutoutTop = (size.height - cutoutSize) / 2;

    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(cutoutLeft, cutoutTop, cutoutSize, cutoutSize),
          const Radius.circular(16),
        ),
      );

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path.combine(PathOperation.difference, backgroundPath, cutoutPath),
      backgroundPaint,
    );

    // Dibujar las esquinas del marco
    final cornerPaint = Paint()
      ..color = AppTheme.primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final cornerLength = 30.0;

    // Esquina superior izquierda
    canvas.drawLine(
      Offset(cutoutLeft, cutoutTop),
      Offset(cutoutLeft + cornerLength, cutoutTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutoutLeft, cutoutTop),
      Offset(cutoutLeft, cutoutTop + cornerLength),
      cornerPaint,
    );

    // Esquina superior derecha
    canvas.drawLine(
      Offset(cutoutLeft + cutoutSize, cutoutTop),
      Offset(cutoutLeft + cutoutSize - cornerLength, cutoutTop),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutoutLeft + cutoutSize, cutoutTop),
      Offset(cutoutLeft + cutoutSize, cutoutTop + cornerLength),
      cornerPaint,
    );

    // Esquina inferior izquierda
    canvas.drawLine(
      Offset(cutoutLeft, cutoutTop + cutoutSize),
      Offset(cutoutLeft + cornerLength, cutoutTop + cutoutSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutoutLeft, cutoutTop + cutoutSize),
      Offset(cutoutLeft, cutoutTop + cutoutSize - cornerLength),
      cornerPaint,
    );

    // Esquina inferior derecha
    canvas.drawLine(
      Offset(cutoutLeft + cutoutSize, cutoutTop + cutoutSize),
      Offset(cutoutLeft + cutoutSize - cornerLength, cutoutTop + cutoutSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(cutoutLeft + cutoutSize, cutoutTop + cutoutSize),
      Offset(cutoutLeft + cutoutSize, cutoutTop + cutoutSize - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
