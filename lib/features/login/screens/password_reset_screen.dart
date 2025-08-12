import 'package:flutter/material.dart';

class PasswordResetScreen extends StatelessWidget {
  const PasswordResetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This is a placeholder for the second step of the password reset flow.
    // In a real implementation, this screen would be accessed via a deep link
    // from the user's email, containing a token to verify the reset request.
    // The UI would include fields for the new password and a confirmation,
    // and a provider would handle the logic to update the password using
    // Supabase's `updateUser` method.

    return Scaffold(
      appBar: AppBar(
        title: const Text('新しいパスワードを設定'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '新しいパスワードを設定してください。',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '新しいパスワード',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'パスワードを確認',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: null, // Placeholder
                child: Text('パスワードを更新'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 