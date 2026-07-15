import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSubmittedSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).sendForgotPassword(
          _emailController.text.trim(),
        );

    if (success) {
      setState(() => _isSubmittedSuccess = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    // Error handler
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.colorScheme.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Organic Green Success States vs Request State
              if (!_isSubmittedSuccess) ...[
                Text(
                  'Reset Password',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade(duration: 400.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 12),
                
                Text(
                  'Enter the email address registered with your driver profile. We will email you password recovery instructions.',
                  style: theme.textTheme.bodyMedium,
                ).animate().fade(delay: 150.ms, duration: 400.ms),
                
                const SizedBox(height: 36),
                
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Registered Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                ).animate().fade(delay: 300.ms),
                
                const SizedBox(height: 28),
                
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _submit,
                  child: authState.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text('Send Recovery Link'),
                ).animate().fade(delay: 450.ms),
              ] else ...[
                // Success screen representation
                const Spacer(),
                Icon(
                  Icons.mark_email_read_rounded,
                  size: 100,
                  color: theme.colorScheme.primary,
                ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                
                const SizedBox(height: 24),
                
                Text(
                  'Instructions Sent!',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fade(delay: 150.ms),
                
                const SizedBox(height: 16),
                
                Text(
                  'We have dispatched password retrieval guidelines to ${_emailController.text}. Please check your inbox and spam folder.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ).animate().fade(delay: 300.ms),
                
                const Spacer(),
                
                ElevatedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Back to Login'),
                ).animate().fade(delay: 450.ms),
                
                const SizedBox(height: 20),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
