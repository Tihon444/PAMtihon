import 'package:flutter/material.dart';

class RemoteAvatar extends StatelessWidget {
  const RemoteAvatar({super.key, required this.url, this.size = 64});
  final String url;
  final double size;
  @override
  Widget build(BuildContext context) => ClipOval(
    child: Image.network(
      url,
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        width: size,
        height: size,
        color: const Color(0xffe7efff),
        child: const Icon(Icons.person),
      ),
    ),
  );
}

class StatusMessage extends StatelessWidget {
  const StatusMessage({super.key, required this.message, this.retry});
  final String message;
  final VoidCallback? retry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            retry == null ? Icons.search_off : Icons.error_outline,
            size: 48,
            color: Colors.grey,
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (retry != null)
            TextButton(onPressed: retry, child: const Text('Reîncearcă')),
        ],
      ),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 12),
    child: Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
  );
}
