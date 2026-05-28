import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import '../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.controller});

  final AppController controller;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  bool _signUp = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              const Text('☕', textAlign: TextAlign.center, style: TextStyle(fontSize: 56)),
              const SizedBox(height: 12),
              const Text(
                'Caffein Tracker',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                c.useOfflineDemo
                    ? 'Supabase not configured — demo mode with local health'
                    : 'Sign in to sync drinks & health',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 32),
              if (_signUp)
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'Display name',
                    border: OutlineInputBorder(),
                  ),
                ),
              if (_signUp) const SizedBox(height: 12),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              if (c.error != null) ...[
                const SizedBox(height: 12),
                Text(c.error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: c.loading
                    ? null
                    : () async {
                        if (c.useOfflineDemo) {
                          if (c.profile == null) await c.init();
                          return;
                        }
                        if (_signUp) {
                          await c.signUp(
                            _email.text.trim(),
                            _password.text,
                            _name.text.trim().isEmpty ? 'Friend' : _name.text.trim(),
                          );
                        } else {
                          await c.signIn(_email.text.trim(), _password.text);
                        }
                      },
                child: Text(c.useOfflineDemo
                    ? 'Continue in demo mode'
                    : (_signUp ? 'Create account' : 'Sign in')),
              ),
              TextButton(
                onPressed: () => setState(() => _signUp = !_signUp),
                child: Text(_signUp
                    ? 'Already have an account? Sign in'
                    : 'New here? Create account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
