import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/colors.dart';
import '../../state/auth_provider.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('PROFILE OVERVIEW',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: AppColors.muted)),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(colors: [Color(0xFF4C1D95), AppColors.purple]),
                  border: Border.all(color: AppColors.purple, width: 2),
                ),
                child: Center(child: Text(user?.initial ?? '?',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white))),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user?.displayName.toUpperCase() ?? '',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text)),
                  const SizedBox(height: 2),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.purpleGlow,
                      border: Border.all(color: AppColors.purple),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('⚡ LEVEL 1', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.purple2)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: 0.2,
              minHeight: 4,
              backgroundColor: AppColors.surface2,
              valueColor: const AlwaysStoppedAnimation(AppColors.purple2),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(child: _Stat(value: '0', label: 'Games')),
              Expanded(child: _Stat(value: '0', label: 'Hours')),
              Expanded(child: _Stat(value: '0', label: 'Achieve.')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.text)),
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 8, color: AppColors.muted, letterSpacing: 0.5)),
      ],
    );
  }
}
