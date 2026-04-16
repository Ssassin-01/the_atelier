import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_atelier/theme/app_theme.dart';
import 'package:material_symbols_icons/symbols.dart';

class SketchPad extends StatelessWidget {
  const SketchPad({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SketchPad(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(48)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 40,
            offset: Offset(0, -10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 16),
              Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  children: [
                    const SizedBox(width: 8), 
                    Expanded(
                      child: Text(
                        '아이디어 스케치',
                        style: GoogleFonts.notoSerif(
                          fontSize: 28, // Reduced slightly from 32
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.tertiaryFixedDim,
                        foregroundColor: AppColors.onTertiaryFixed,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      ),
                      child: const Text('저장하기', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
                    image: const DecorationImage(
                      image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuBlhtvX7-3S8xRKWe0_rDvJh-RI38URYr1apR2Pd_yCnnpYKnrt51YHqooNVIrK6t1TI1IYKbaaaOKbw-0Li-qR2wgjjQKUvEM9qf9OuODqgQNuS-IlvHaftsQmy4VmPGu_e9tNEIjh5_i1AlEMmcvqsRO80sL4PlKW2E6o0Qwmd8ThR1YBkbEzpXlrAkmu5ghjtq7rdha8aovsQ51PwYgCHqafsO6mfCQELa12YsEhNsYuirjIc6ruyP5HER7sjaaJi83mB43Kv8k'),
                      fit: BoxFit.cover,
                      opacity: 0.2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Opacity(
                          opacity: 0.6,
                          child: Image.network(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuC-CULQscIIBuSX-aDb9NJkB8CllPM4oOigx68vBRRt_h_Rv_Lk_yqedd3mJ6tm-L3kyOletcrGlfjWKg4HCwM4t_Qsz2jW8UczIh1gE8qDAdmexlfzIGbdwE-bnEpuKbprMKzAb6LZpql5JTwbJ4J3zDQpmUD13oEFdMR9nyVZ9qG8YwjblZE6GvYxsqVzWuWan_b_6LgS9lmPciNn7M8x_p_oCIOnGM1C98ng8y0eU1Gsg9dY5cKaJ5zHjNe5tfF3K78uHPKLbUo',
                            width: 300,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 24,
                        left: 24,
                        child: Text(
                          '베이스: 제누아즈 스폰지',
                          style: GoogleFonts.notoSerif(
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                            color: AppColors.primary.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 120), // Padding for toolbar
            ],
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: _buildDrawingToolbar(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawingToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.onSurface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 30),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToolBtn(Symbols.undo),
          _buildToolBtn(Symbols.edit, active: true),
          _buildToolBtn(Symbols.ink_eraser),
          const SizedBox(width: 16),
          Container(width: 1, height: 28, color: Colors.white12),
          const SizedBox(width: 16),
          _buildColorDot(const Color(0xFF4A3B32)),
          _buildColorDot(AppColors.primaryContainer),
          _buildColorDot(const Color(0xFFE9C46A), active: true),
          _buildColorDot(Colors.white),
        ],
      ),
    );
  }

  Widget _buildToolBtn(IconData icon, {bool active = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Icon(
        icon,
        color: active ? Colors.white : Colors.white60,
        size: 24,
      ),
    );
  }

  Widget _buildColorDot(Color color, {bool active = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: active ? Border.all(color: Colors.white, width: 2) : Border.all(color: Colors.white12),
      ),
    );
  }
}
