import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final obscurePassword = useState(true);
    final isLoading = useState(false);
    final isRegister = useState(false);
    final client = ref.watch(supabaseClientProvider);

    Future<void> submit() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      try {
        isLoading.value = true;

        if (isRegister.value) {
          // Register flow
          await client.auth.signUp(
            email: emailController.text.trim(),
            password: passwordController.text,
          );

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account created. Check your email to verify.')),
            );
          }

          // Optionally switch to sign-in mode
          isRegister.value = false;
        } else {
          // Sign in flow
          await client.auth.signInWithPassword(
            email: emailController.text.trim(),
            password: passwordController.text,
          );
        }
      } on AuthException catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
          dev.log(error.message, name: 'LoginScreen');
        }
      } catch (error) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Authentication failed: $error')));
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Sign in to continue', style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(obscurePassword.value ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => obscurePassword.value = !obscurePassword.value,
                      ),
                    ),
                    obscureText: obscurePassword.value,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  if (isRegister.value) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: confirmPasswordController,
                      decoration: const InputDecoration(
                        labelText: 'Confirm password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: obscurePassword.value,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Please confirm your password';
                        if (value != passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: isLoading.value ? null : submit,
                      child: isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isRegister.value ? 'Create account' : 'Sign in'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      isRegister.value = !isRegister.value;
                    },
                    child: Text(
                      isRegister.value ? 'Have an account? Sign in' : 'Create an account',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
