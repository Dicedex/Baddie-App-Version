import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.message, size: 72, color: Colors.grey),
            SizedBox(height: 12),
            Text('Messages', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('No conversations yet. When you match someone you can message them here.', textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
