import 'package:flutter/material.dart';
import '../app/constants.dart';

class PromoBanner extends StatelessWidget {
  final VoidCallback onPressed;

  const PromoBanner({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: const LinearGradient(
          colors: [Color(0xFF95D5A0), Color(0xFFDFF4E2)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Descubre y organiza\neventos en tu ciudad',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontSize: 24,
                        height: 1.2,
                      ),
                ),
                const SizedBox(height: 16),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide.none,
                    foregroundColor: AppColors.primary,
                  ),
                  onPressed: onPressed,
                  child: const Text('Ver más'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.groups_2_rounded,
            size: 72,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}