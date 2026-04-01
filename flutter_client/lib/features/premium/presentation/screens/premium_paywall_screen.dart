import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/theme/app_colors.dart';
import 'package:homesync_client/core/widgets/homesync_logo.dart';
import 'package:homesync_client/core/providers/premium_provider.dart';
import 'package:homesync_client/core/services/premium_service.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PremiumPaywallScreen extends ConsumerWidget {
  const PremiumPaywallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(premiumProductsProvider);
    final isPremium = ref.watch(premiumProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // ── Background Gradient ───────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1E1B4B), // Midnite blue
                  Color(0xFF312E81), // Indigo
                  Color(0xFF1E1B4B),
                ],
              ),
            ),
          ),

          // ── Floating design elements ──────────────────────────────────────
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ).animate(onPlay: (c) => c.repeat()).scale(
                  duration: 4.seconds,
                  begin: const Offset(1, 1),
                  end: const Offset(1.2, 1.2),
                  curve: Curves.easeInOut,
                ),
          ),

          // ── Content ───────────────────────────────────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  
                  // Logo
                  const HomeSyncLogo(size: 90)
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.elasticOut)
                      .shimmer(delay: 1.seconds),

                  const SizedBox(height: 24),

                  // Title
                  const Text(
                    'Lleva tu hogar al\nsiguiente nivel',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),

                  const SizedBox(height: 12),

                  const Text(
                    'Desbloquea todas las funciones pro\ny simplifica tu vida en equipo.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.4,
                    ),
                  ).animate().fadeIn(delay: 400.ms),

                  const SizedBox(height: 40),

                  // ── Premium Benefits ──────────────────────────────────────
                  const _BenefitCard(
                    icon: Icons.auto_graph_rounded,
                    title: 'Estadísticas Avanzadas',
                    desc: 'Analiza tus gastos y tareas por categoría con gráficos detallados.',
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.2),

                  const _BenefitCard(
                    icon: Icons.home_work_rounded,
                    title: 'Hogares Ilimitados',
                    desc: 'Crea múltiples hogares para tu pareja, familia, amigos o proyectos.',
                  ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.2),

                  const _BenefitCard(
                    icon: Icons.palette_rounded,
                    title: 'Personalización Total',
                    desc: 'Acceso a temas premium, colores únicos y widgets personalizados.',
                  ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.2),

                  const SizedBox(height: 48),

                  // ── Products / Call to action ──────────────────────────────
                  if (isPremium)
                    _AlreadyPremiumCard()
                  else
                    productsAsync.when(
                      data: (products) => _ProductList(products: products),
                      loading: () => const CircularProgressIndicator(color: Colors.white),
                      error: (err, _) => _StoreError(error: err.toString()),
                    ),

                  const SizedBox(height: 32),
                  
                  // Footer links
                  TextButton(
                    onPressed: () => ref.read(premiumServiceProvider).restorePurchases(),
                    child: const Text(
                      'Restaurar compras',
                      style: TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const _BenefitCard({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white60,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductList extends ConsumerWidget {
  final List<ProductDetails> products;

  const _ProductList({required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (products.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            const Text(
              'Prueba Gratis disponible',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              onPressed: () async {
                await ref.read(premiumProvider.notifier).togglePremiumMock();
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Activar Mock Premium (Demo Mode)'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: products.map((product) => _ProductCard(product: product)).toList(),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final ProductDetails product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isYearly = product.id.contains('yearly');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isYearly 
          ? AppColors.primary.withValues(alpha: 0.15) 
          : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isYearly ? AppColors.primary : Colors.white24,
          width: 2,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        title: Text(
          product.title.split('(').first.trim(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
          product.description,
          style: const TextStyle(color: Colors.white60),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              product.price,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20),
            ),
            if (isYearly)
              const Text('Ahorra 20%', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        onTap: () => ref.read(premiumServiceProvider).buyProduct(product),
      ),
    );
  }
}

class _AlreadyPremiumCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.stars_rounded, color: AppColors.accentGold, size: 64),
          const SizedBox(height: 16),
          const Text(
            '¡Ya eres Premium!',
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Gracias por apoyar el desarrollo de HomeSync.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }
}

class _StoreError extends ConsumerWidget {
  final String error;
  const _StoreError({required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const Icon(Icons.cloud_off_rounded, color: Colors.white54, size: 48),
        const SizedBox(height: 16),
        const Text(
          'Error al conectar con la tienda',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        Text(error, style: const TextStyle(color: Colors.white30, fontSize: 10)),
        const SizedBox(height: 24),
        // Switch to allow dev toggle if store fails
        ElevatedButton(
          onPressed: () => ref.read(premiumProvider.notifier).togglePremiumMock(),
          child: const Text('Modo Desarrollador: Activar Premium'),
        ),
      ],
    );
  }
}
