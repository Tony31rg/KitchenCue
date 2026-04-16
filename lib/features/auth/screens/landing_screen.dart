import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF090A0F), Color(0xFF151A27), Color(0xFF25160F)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF8C42).withValues(alpha: 0.14),
                ),
              ),
            ),
            Positioned(
              bottom: -70,
              left: -30,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF53B5FF).withValues(alpha: 0.12),
                ),
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 920),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 760;

                        return Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFF10131D).withValues(alpha: 0.78),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: const Color(0xFFFFFFFF)
                                  .withValues(alpha: 0.08),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x59000000),
                                blurRadius: 32,
                                offset: Offset(0, 18),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 58,
                                    height: 58,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFFFA351),
                                          Color(0xFFFFD770),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.ramen_dining_rounded,
                                      color: Color(0xFF17120D),
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'KitchenCue',
                                    style: theme.textTheme.headlineMedium
                                        ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Control your kitchen momentum before chaos starts.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Built for teams that need live stock safety, kitchen load awareness, and full order tracking in one workflow.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFD7DBE8),
                                  fontSize: 15,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 22),
                              Wrap(
                                spacing: 14,
                                runSpacing: 14,
                                children: [
                                  _FeatureCard(
                                    icon: Icons.inventory_2_rounded,
                                    accent: const Color(0xFF5BC1FF),
                                    title: 'Stock Update Guard',
                                    description:
                                        'Automatic stock updates protect your last item from double ordering.',
                                    width: isWide
                                        ? (constraints.maxWidth - 48 - 28) / 3
                                        : double.infinity,
                                  ),
                                  _FeatureCard(
                                    icon: Icons.local_fire_department_rounded,
                                    accent: const Color(0xFFFFA665),
                                    title: 'Kitchen Busy Mode',
                                    description:
                                        'Kitchen can instantly turn on busy mode when order volume gets too high.',
                                    width: isWide
                                        ? (constraints.maxWidth - 48 - 28) / 3
                                        : double.infinity,
                                  ),
                                  _FeatureCard(
                                    icon: Icons.fact_check_rounded,
                                    accent: const Color(0xFF8EE38E),
                                    title: 'Order CRUD + Status',
                                    description:
                                        'Create, view, update, and cancel orders while tracking real-time statuses.',
                                    width: isWide
                                        ? (constraints.maxWidth - 48 - 28) / 3
                                        : double.infinity,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: () =>
                                      context.go(RouteConstants.login),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFB347),
                                    foregroundColor: const Color(0xFF15110D),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 18),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                  ),
                                  child: const Text(
                                    'Start Restaurant Service',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Begin from scratch and set your shift role inside the app.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Color(0xFFB7C2DD),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.description,
    required this.width,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String description;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF171B29),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF2A3145)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: accent.withValues(alpha: 0.16),
              ),
              child: Icon(icon, color: accent),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: Color(0xFFC4CBDD),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
