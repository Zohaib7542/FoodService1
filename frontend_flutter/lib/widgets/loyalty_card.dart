import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/theme.dart';

class LoyaltyCard extends StatelessWidget {
  final int points;

  const LoyaltyCard({super.key, required this.points});

  String get _currentTier {
    if (points >= 1000) return 'Gold';
    if (points >= 500) return 'Silver';
    return 'Bronze';
  }

  int get _pointsToNextTier {
    if (points >= 1000) return 0;
    if (points >= 500) return 1000 - points;
    return 500 - points;
  }

  double get _progress {
    if (points >= 1000) return 1.0;
    if (points >= 500) return (points - 500) / 500;
    return points / 500;
  }

  List<Color> get _tierColors {
    if (points >= 1000) return [const Color(0xFFFFD700), const Color(0xFFDAA520)];
    if (points >= 500) return [const Color(0xFFE0E0E0), const Color(0xFFA9A9A9)];
    return [const Color(0xFFCD7F32), const Color(0xFF8B4513)];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.surface.withAlpha(200),
            AppTheme.surface.withAlpha(100),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(20)),
        boxShadow: [
          BoxShadow(
            color: _tierColors[0].withAlpha(30),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seva Rewards',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: _tierColors,
                    ).createShader(bounds),
                    child: Text(
                      '$_currentTier Member',
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.primary.withAlpha(50)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, color: AppTheme.primary, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '$points pts',
                      style: GoogleFonts.inter(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          if (_currentTier != 'Gold') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_pointsToNextTier} points to next tier',
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
                ),
                Text(
                  '${(_progress * 100).toInt()}%',
                  style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor: Colors.white.withAlpha(10),
                valueColor: AlwaysStoppedAnimation<Color>(_tierColors[0]),
              ),
            ),
          ] else
            Text(
              'Maximum tier reached! Enjoy your premium discounts.',
              style: GoogleFonts.inter(color: Colors.white54, fontSize: 14),
            ),
        ],
      ),
    );
  }
}
