import 'dart:developer' as dev;

import 'package:flutter/cupertino.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nutrition/providers/supabase_providers.dart';
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
            showCupertinoDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: const Text('Success'),
                content: const Text('Account created. Check your email to verify.'),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
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
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Error'),
              content: Text(error.message),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          dev.log(error.message, name: 'LoginScreen');
        }
      } catch (error) {
        if (context.mounted) {
          showCupertinoDialog(
            context: context,
            builder: (context) => CupertinoAlertDialog(
              title: const Text('Error'),
              content: Text('Authentication failed: $error'),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFF000000),
      child: SafeArea(
        child: Center(
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
                    // Netflix-style logo/title
                    const Center(
                      child: Text(
                        'NUTRITION',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE50914),
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Sign in to continue',
                        style: TextStyle(fontSize: 16, color: CupertinoColors.systemGrey),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Email field
                    CupertinoTextField(
                      controller: emailController,
                      placeholder: 'Email',
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      style: const TextStyle(color: CupertinoColors.white),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),

                    // Password field
                    CupertinoTextField(
                      controller: passwordController,
                      placeholder: 'Password',
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      style: const TextStyle(color: CupertinoColors.white),
                      obscureText: obscurePassword.value,
                      suffix: CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: () => obscurePassword.value = !obscurePassword.value,
                        child: Icon(
                          obscurePassword.value
                              ? CupertinoIcons.eye_slash_fill
                              : CupertinoIcons.eye_fill,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ),

                    if (isRegister.value) ...[
                      const SizedBox(height: 12),
                      CupertinoTextField(
                        controller: confirmPasswordController,
                        placeholder: 'Confirm password',
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2C2C2E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        style: const TextStyle(color: CupertinoColors.white),
                        obscureText: obscurePassword.value,
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: const Color(0xFFE50914),
                        onPressed: isLoading.value ? null : submit,
                        child: isLoading.value
                            ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                            : Text(
                                isRegister.value ? 'Create account' : 'Sign in',
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Toggle button
                    Center(
                      child: CupertinoButton(
                        onPressed: () {
                          isRegister.value = !isRegister.value;
                        },
                        child: Text(
                          isRegister.value ? 'Have an account? Sign in' : 'Create an account',
                          style: const TextStyle(color: CupertinoColors.systemGrey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
