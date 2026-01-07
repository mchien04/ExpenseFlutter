import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/wallet_entity.dart';
import '../../injection_container.dart';

final walletsProvider = StreamProvider.autoDispose<List<WalletEntity>>((ref) {
  final useCase = ref.watch(getWalletsUseCaseProvider);
  return useCase.watch().map((result) => result.fold(
        (failure) => <WalletEntity>[],
        (wallets) => wallets,
      ));
});

final walletBalanceProvider =
    FutureProvider.autoDispose.family<double, String>((ref, walletId) async {
  final useCase = ref.watch(getWalletsUseCaseProvider);
  final result = await useCase.getBalance(walletId);
  return result.fold(
    (failure) => 0.0,
    (balance) => balance,
  );
});

class WalletWithBalance {
  final WalletEntity wallet;
  final double balance;

  WalletWithBalance({required this.wallet, required this.balance});
}

final walletsWithBalanceProvider =
    FutureProvider.autoDispose<List<WalletWithBalance>>((ref) async {
  final walletsAsync = ref.watch(walletsProvider);
  
  return walletsAsync.when(
    data: (wallets) async {
      final List<WalletWithBalance> result = [];
      for (final wallet in wallets) {
        final balanceResult =
            await ref.read(getWalletsUseCaseProvider).getBalance(wallet.id);
        final balance = balanceResult.fold((f) => 0.0, (b) => b);
        result.add(WalletWithBalance(wallet: wallet, balance: balance));
      }
      return result;
    },
    loading: () => <WalletWithBalance>[],
    error: (_, __) => <WalletWithBalance>[],
  );
});

class WalletNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  WalletNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<bool> createWallet({
    required String name,
    double initialBalance = 0.0,
    bool allowNegativeBalance = true,
    String currencyCode = 'VND',
  }) async {
    state = const AsyncValue.loading();
    final result = await _ref.read(createWalletUseCaseProvider).call(
          name: name,
          initialBalance: initialBalance,
          allowNegativeBalance: allowNegativeBalance,
          currencyCode: currencyCode,
        );
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }

  Future<bool> updateWallet(WalletEntity wallet) async {
    state = const AsyncValue.loading();
    final result = await _ref.read(updateWalletUseCaseProvider).call(wallet);
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }

  Future<bool> deleteWallet(String id) async {
    state = const AsyncValue.loading();
    final result = await _ref.read(deleteWalletUseCaseProvider).call(id);
    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }
}

final walletNotifierProvider =
    StateNotifierProvider<WalletNotifier, AsyncValue<void>>((ref) {
  return WalletNotifier(ref);
});
