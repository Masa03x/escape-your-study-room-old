import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class ProgressSegments extends StatelessWidget {
  const ProgressSegments({
    super.key,
    required this.current,
    this.total = 5,
    this.height = 8,
  });

  final int current;
  final int total;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        final active = index < current;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            height: height,
            margin: EdgeInsets.only(right: index == total - 1 ? 0 : 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(height / 2),
              gradient: active
                  ? const LinearGradient(
                      colors: [AppColors.green, AppColors.greenLight],
                    )
                  : null,
              color: active ? null : Colors.white.withValues(alpha: 0.10),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: AppColors.green.withValues(alpha: 0.45),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}
