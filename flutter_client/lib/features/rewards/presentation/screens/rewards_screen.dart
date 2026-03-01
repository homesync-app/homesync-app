import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/rewards_provider.dart';
import 'package:homesync_client/core/providers/core_providers.dart';
import 'package:homesync_client/core/theme/app_colors.dart';


import '../../domain/models/reward_model.dart';
import 'package:homesync_client/core/utils/app_animations.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  @override
  Widget build(BuildContext context) {
    final rewardsAsync = ref.watch(rewardsProvider);
    final userBalanceAsync = ref.watch(userBalanceProvider);
    final currentUserId = ref.read(currentUserIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(userBalanceAsync),
          SliverToBoxAdapter(
            child: rewardsAsync.when(
              data: (rewards) => _buildBody(rewards.map((r) => RewardModel.fromJson(r)).toList(), currentUserId),
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(AsyncValue<Map<String, dynamic>?> balanceAsync) {
    final coins = balanceAsync.whenOrNull(data: (b) => b?['coins'] as int?) ?? 0;

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.background,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(color: AppColors.background),
          child: Stack(
            children: [
              // Elementos decorativos de fondo abstractos
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.accentGold.withValues(alpha: 0.08),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                left: -80,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.05),
                  ),
                ),
              ),
              
              // Tarjeta principal Premium
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(40),
                        border: Border.all(color: AppColors.accentGold.withValues(alpha: 0.15), width: 1),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accentGold.withValues(alpha: 0.08),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.stars_rounded, color: AppColors.accentGold.withValues(alpha: 0.5), size: 18),
                              const SizedBox(width: 8),
                              const Text(
                                'MI BILLETERA',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.stars_rounded, color: AppColors.accentGold.withValues(alpha: 0.5), size: 18),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$coins',
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 56,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -2,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: Text(
                                  'coins',
                                  style: TextStyle(
                                    color: AppColors.accentGold,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Canjeá por caricias y favores ✨',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(List<RewardModel> rewards, String? currentUserId) {
    final approvedRewards = rewards.where((r) => r.isApproved == true).toList();
    final suggestions = rewards.where((r) => r.isApproved == false).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (suggestions.isNotEmpty) ...[
            _buildSectionHeader('💡 Sugerencias del otro', 
                action: Text('${suggestions.length} pendientes', style: const TextStyle(color: AppColors.primary, fontSize: 12))),
            const SizedBox(height: 16),
            _buildSuggestionsList(suggestions, currentUserId),
            const SizedBox(height: 32),
          ],

          _buildSectionHeader('🛍️ Boutique de la Casa', 
              action: IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                onPressed: _showCreateRewardSheet,
              )),
          const SizedBox(height: 16),
          if (approvedRewards.isEmpty)
            _buildEmptyState()
          else
            _buildRewardsGrid(approvedRewards),
          
          const SizedBox(height: 40),
          _buildActionButtons(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {Widget? action}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        if (action != null) action,
      ],
    );
  }

  Widget _buildSuggestionsList(List<RewardModel> suggestions, String? currentUserId) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: suggestions.length,
        itemBuilder: (context, index) {
          final s = suggestions[index];
          final isMine = s.createdBy == currentUserId;

          return Container(
            width: 300,
            margin: const EdgeInsets.only(right: 16, bottom: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: isMine ? AppColors.divider : const Color(0xFFDDD6FE).withValues(alpha: 0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isMine ? AppColors.primary : const Color(0xFF8B5CF6)).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(s.icon, style: const TextStyle(fontSize: 24)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.title,
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${s.cost} coins',
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (isMine)
                   Center(
                     child: Container(
                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                       decoration: BoxDecoration(
                         color: AppColors.surfaceVariant,
                         borderRadius: BorderRadius.circular(20),
                       ),
                       child: const Text('Pendiente de aprobación', 
                         style: TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
                     ),
                   )
                else
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => ref.read(rewardsProvider.notifier).deleteReward(s.id),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.error, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Rechazar', style: TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => ref.read(rewardsProvider.notifier).approveReward(s.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6), // Royal Purple for approvals
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('¡Añadir!', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRewardsGrid(List<RewardModel> rewards) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.90, // Un poco más alto que ancho para dejar más espacio al texto enorme
      ),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        final r = rewards[index];
        return _buildRewardCard(r);
      },
    );
  }

  Widget _buildRewardCard(RewardModel reward) {
    final userBalance = ref.watch(userBalanceProvider).value?['coins'] ?? 0;
    final cost = reward.cost;
    final canAfford = userBalance >= cost;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: canAfford ? AppColors.accentGold.withValues(alpha: 0.3) : AppColors.divider.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _confirmRedeem(reward, canAfford),
          borderRadius: BorderRadius.circular(28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 65,
                      height: 65,
                      decoration: BoxDecoration(
                        color: (canAfford ? AppColors.primary : AppColors.textMuted).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(reward.icon, style: const TextStyle(fontSize: 34)),
                  ],
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Center(
                    child: Text(
                      reward.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                        height: 1.15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: canAfford ? AppColors.accentGold.withValues(alpha: 0.12) : AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: canAfford ? AppColors.accentGold.withValues(alpha: 0.2) : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.stars_rounded, size: 16, color: canAfford ? AppColors.accentGold : AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        '$cost',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: canAfford ? const Color(0xFFB45309) : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      width: double.infinity,
      child: Column(
        children: [
          const Text('🏚️', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'Boutique vacía',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _showCreateRewardSheet,
            child: const Text('Crear primer premio'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: _showSuggestRewardSheet,
        icon: const Icon(Icons.auto_awesome_rounded, size: 28),
        label: const Text(
          'PROPONER UN DESEO',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        ),
      ),
    );
  }

  void _confirmRedeem(RewardModel reward, bool canAfford) {
    if (!canAfford) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coins insuficientes 😅 ¡A completar tareas!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('¿Canjear este premio?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(reward.icon, style: const TextStyle(fontSize: 60)),
            const SizedBox(height: 16),
            Text(
              reward.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogCtx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx); // Close dialog immediately
              
              ref.read(rewardsProvider.notifier).redeem(reward.id).then((_) {
                 // Invalidate immediately so next build fetches correct amount
                 ref.invalidate(userBalanceProvider);
                 _showSuccessAnim(reward);
              }).catchError((e) {
                 final errStr = e.toString().replaceFirst('Exception: ', '');
                 ScaffoldMessenger.of(context).showSnackBar(
                   SnackBar(content: Text('Error: $errStr'), backgroundColor: AppColors.error),
                 );
                 ref.invalidate(userBalanceProvider);
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Canjear'),
          ),
        ],
      ),
    );
  }

  void _showSuccessAnim(RewardModel reward) {
    SuccessCelebration.show(
      context,
      title: '¡Premio Canjeado! 🎉',
      message: 'Disfrutá de "${reward.title}". El amor está en los pequeños detalles.',
      icon: reward.icon,
    );
  }

  void _showCreateRewardSheet() {
    _showRewardEditor(isSuggestion: false);
  }

  void _showSuggestRewardSheet() {
    _showRewardEditor(isSuggestion: true);
  }

  void _showRewardEditor({required bool isSuggestion}) {
    final titleController = TextEditingController();
    final costController = TextEditingController();
    String selectedIcon = '🎁';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
            top: 24,
            left: 28,
            right: 28,
          ),
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                isSuggestion ? 'Proponer un Deseo' : 'Nuevo Premio de la Casa',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                isSuggestion ? 'Envía una idea para que tu pareja la apruebe' : 'Añade una recompensa directamente a la tienda',
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              const Text('¿QUÉ TENÉS EN MENTE?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1.2)),
              const SizedBox(height: 12),
              TextField(
                controller: titleController,
                style: const TextStyle(fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  hintText: 'Ej: Masaje de 20 min...',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
              const SizedBox(height: 24),
              
              const Text('VALOR DEL CAPRICHO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1.2)),
              const SizedBox(height: 12),
              TextField(
                controller: costController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontWeight: FontWeight.w900, color: Color(0xFFB45309)),
                decoration: InputDecoration(
                  hintText: 'Costo en coins',
                  prefixIcon: const Icon(Icons.stars_rounded, color: AppColors.accentGold),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                  contentPadding: const EdgeInsets.all(20),
                ),
              ),
              const SizedBox(height: 32),
              
              const Text('ELEGÍ UN ÍCONO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary, letterSpacing: 1.2)),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: ['🎁', '🍕', '🎬', '💆', '🍳', '🍦', '🥂', '🎮', '🛀', '🚗'].map((icon) {
                    final isSelected = selectedIcon == icon;
                    return GestureDetector(
                       onTap: () => setModalState(() => selectedIcon = icon),
                       child: Container(
                         margin: const EdgeInsets.only(right: 12),
                         padding: const EdgeInsets.all(16),
                         decoration: BoxDecoration(
                           color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
                           borderRadius: BorderRadius.circular(20),
                           border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent, width: 2),
                           boxShadow: [
                             if (!isSelected)
                               BoxShadow(
                                 color: Colors.black.withValues(alpha: 0.03),
                                 blurRadius: 10,
                                 offset: const Offset(0, 4),
                               ),
                           ],
                         ),
                         child: Text(icon, style: const TextStyle(fontSize: 32)),
                       ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 40),
              
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    final cost = int.tryParse(costController.text) ?? 0;
                    if (titleController.text.isNotEmpty && cost > 0) {
                      ref.read(rewardsProvider.notifier).suggestReward(
                        title: titleController.text,
                        cost: cost,
                        icon: selectedIcon,
                      );
                      Navigator.pop(context);
                      _showSentToast(isSuggestion);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  child: Text(
                    isSuggestion ? 'ENVIAR PROPUESTA' : 'CREAR PREMIO',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSentToast(bool isSuggestion) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isSuggestion ? '🚀 ¡Propuesta enviada!' : '✅ Premio creado con éxito'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
