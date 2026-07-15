import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signature/signature.dart';
import 'package:path_provider/path_provider.dart';
import '../../providers/delivery_provider.dart';

class ConfirmationScreen extends ConsumerStatefulWidget {
  const ConfirmationScreen({super.key});

  @override
  ConsumerState<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends ConsumerState<ConfirmationScreen> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 4,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  File? _imageFile;
  final ImagePicker _imagePicker = ImagePicker();
  bool _isUploading = false;

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto(ImageSource source) async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: source,
        imageQuality: 70,
        maxWidth: 1024,
      );

      if (photo != null) {
        setState(() => _imageFile = File(photo.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture photo: $e')),
      );
    }
  }

  // Simulation fallback: Creates mock empty files to complete testing easily
  Future<void> _simulateMockProof() async {
    setState(() => _isUploading = true);
    try {
      final tempDir = await getTemporaryDirectory();
      
      final mockPhoto = File('${tempDir.path}/mock_photo_proof.jpg');
      await mockPhoto.writeAsString('mock_photo_data');

      final mockSig = File('${tempDir.path}/mock_signature.png');
      await mockSig.writeAsString('mock_signature_data');

      setState(() {
        _imageFile = mockPhoto;
        _isUploading = false;
      });

      _submitProof(mockSig.path, mockPhoto.path);
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mock creation error: $e')),
      );
    }
  }

  Future<void> _submit() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please capture or upload a proof photo first.'),
          backgroundColor: Colors.amber,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_signatureController.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please collect a digital signature from the charity representative.'),
          backgroundColor: Colors.amber,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      final signatureBytes = await _signatureController.toPngBytes();
      if (signatureBytes == null) {
        throw Exception("Failed to serialize signature canvas.");
      }

      final tempDir = await getTemporaryDirectory();
      final sigFile = File('${tempDir.path}/sig_${DateTime.now().millisecondsSinceEpoch}.png');
      await sigFile.writeAsBytes(signatureBytes);

      _submitProof(sigFile.path, _imageFile!.path);
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Submission failed: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _submitProof(String sigPath, String photoPath) async {
    final success = await ref.read(deliveryProvider.notifier).completeActiveDelivery(
          signaturePath: sigPath,
          photoProofPath: photoPath,
        );

    if (success && mounted) {
      setState(() => _isUploading = false);
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.stars_rounded, size: 72, color: theme.colorScheme.primary)
                    .animate()
                    .scale(duration: 400.ms, curve: Curves.easeOutBack),
                const SizedBox(height: 16),
                Text(
                  'Rescue Completed!',
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Thank you for your service! You have successfully completed food delivery and nourished lives.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    context.pop(); // Close dialog
                    context.go('/dashboard'); // Go home
                  },
                  child: const Text('Back to Dashboard'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Delivery', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.colorScheme.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo Proof Header
              Text(
                '1. PHOTO PROOF',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
              const SizedBox(height: 8),
              
              // Picture Frame
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF16251B) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1D3524) : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, size: 40, color: theme.colorScheme.primary.withOpacity(0.5)),
                          const SizedBox(height: 10),
                          const Text('No photo captured', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton.icon(
                                onPressed: () => _capturePhoto(ImageSource.camera),
                                icon: const Icon(Icons.photo_camera),
                                label: const Text('Camera'),
                              ),
                              const SizedBox(width: 8),
                              TextButton.icon(
                                onPressed: () => _capturePhoto(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Gallery'),
                              ),
                            ],
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_imageFile!, fit: BoxFit.cover),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black.withOpacity(0.6),
                                radius: 18,
                                child: IconButton(
                                  icon: const Icon(Icons.delete, size: 16, color: Colors.white),
                                  onPressed: () => setState(() => _imageFile = null),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ).animate().fade(),
              
              const SizedBox(height: 24),
              
              // Signature Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '2. DIGITAL SIGNATURE',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  TextButton(
                    onPressed: () => _signatureController.clear(),
                    child: const Text('Clear Pad'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Signature Pad
              Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1D3524) : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Signature(
                    controller: _signatureController,
                    backgroundColor: Colors.white,
                  ),
                ),
              ).animate().fade(delay: 100.ms),
              
              const SizedBox(height: 32),

              // Loading indicator/Submission buttons
              if (_isUploading)
                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 12),
                      Text('Uploading verification payload...', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              else ...[
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Submit & Finalize Run', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ).animate().fade(delay: 200.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 12),
                
                // Emulator Bypass Helper
                OutlinedButton(
                  onPressed: _simulateMockProof,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.blueAccent, width: 1.5),
                  ),
                  child: const Text(
                    'Simulate Completion (Emulator)',
                    style: TextStyle(color: Colors.blueAccent),
                  ),
                ).animate().fade(delay: 300.ms),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
