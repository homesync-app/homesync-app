import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:homesync_client/core/offline/sync_service.dart';
import 'package:homesync_client/core/providers/connectivity_provider.dart';

class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);
    final syncState = ref.watch(syncProvider);

    if (connectivity.isOnline &&
        !syncState.isSyncing &&
        syncState.pendingCount == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getBackgroundColor(connectivity, syncState),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _getIcon(connectivity, syncState),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getMessage(connectivity, syncState),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (syncState.isSyncing)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else if (!connectivity.isOnline)
              const Icon(
                Icons.wifi_off,
                color: Colors.white,
                size: 16,
              )
            else if (syncState.pendingCount > 0)
              Text(
                '${syncState.pendingCount} pendientes',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor(
    ConnectivityState connectivity,
    SyncState syncState,
  ) {
    if (!connectivity.isOnline) {
      return Colors.red.shade600;
    } else if (syncState.isSyncing) {
      return Colors.orange.shade600;
    } else if (syncState.pendingCount > 0) {
      return Colors.blue.shade600;
    }
    return Colors.grey.shade600;
  }

  Widget _getIcon(ConnectivityState connectivity, SyncState syncState) {
    if (!connectivity.isOnline) {
      return const Icon(Icons.cloud_off, color: Colors.white, size: 18);
    } else if (syncState.isSyncing) {
      return const Icon(Icons.sync, color: Colors.white, size: 18);
    } else if (syncState.pendingCount > 0) {
      return const Icon(Icons.queue, color: Colors.white, size: 18);
    }
    return const Icon(Icons.info_outline, color: Colors.white, size: 18);
  }

  String _getMessage(ConnectivityState connectivity, SyncState syncState) {
    if (!connectivity.isOnline) {
      return 'Sin conexión - Los cambios se guardarán cuando estés online';
    } else if (syncState.isSyncing) {
      return 'Sincronizando cambios...';
    } else if (syncState.pendingCount > 0) {
      return '${syncState.pendingCount} cambio${syncState.pendingCount > 1 ? 's' : ''} pendiente${syncState.pendingCount > 1 ? 's' : ''} de sincronizar';
    }
    return 'Sincronizado';
  }
}

class SyncFAB extends ConsumerWidget {
  const SyncFAB({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);
    final syncState = ref.watch(syncProvider);

    if (connectivity.isOnline &&
        syncState.pendingCount > 0 &&
        !syncState.isSyncing) {
      return FloatingActionButton.extended(
        onPressed: () {
          ref.read(syncProvider.notifier).sync();
        },
        backgroundColor: Theme.of(context).colorScheme.primary,
        icon: const Icon(Icons.sync),
        label: Text('Sincronizar (${syncState.pendingCount})'),
      );
    }

    return const SizedBox.shrink();
  }
}

class OfflineAwareBuilder extends ConsumerWidget {
  final Widget Function(BuildContext context, bool isOnline) builder;
  final Widget? offlineFallback;

  const OfflineAwareBuilder({
    super.key,
    required this.builder,
    this.offlineFallback,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    if (!isOnline && offlineFallback != null) {
      return offlineFallback!;
    }

    return builder(context, isOnline);
  }
}
