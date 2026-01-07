import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/wallets_table.dart';

part 'wallet_dao.g.dart';

@DriftAccessor(tables: [Wallets])
class WalletDao extends DatabaseAccessor<AppDatabase> with _$WalletDaoMixin {
  WalletDao(super.db);

  Future<List<Wallet>> getAllWallets() => select(wallets).get();

  Future<List<Wallet>> getActiveWallets() {
    return (select(wallets)..where((w) => w.isDeleted.equals(false))).get();
  }

  Future<Wallet?> getWalletById(String id) {
    return (select(wallets)..where((w) => w.id.equals(id))).getSingleOrNull();
  }

  Stream<List<Wallet>> watchAllWallets() => select(wallets).watch();

  Stream<List<Wallet>> watchActiveWallets() {
    return (select(wallets)..where((w) => w.isDeleted.equals(false))).watch();
  }

  Future<int> insertWallet(WalletsCompanion wallet) {
    return into(wallets).insert(wallet);
  }

  Future<bool> updateWallet(WalletsCompanion wallet) {
    return update(wallets).replace(
      wallet.copyWith(updatedAt: Value(DateTime.now())),
    );
  }

  Future<int> softDeleteWallet(String id) {
    return (update(wallets)..where((w) => w.id.equals(id))).write(
      WalletsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<int> restoreWallet(String id) {
    return (update(wallets)..where((w) => w.id.equals(id))).write(
      WalletsCompanion(
        isDeleted: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<bool> walletExists(String id) async {
    final wallet = await getWalletById(id);
    return wallet != null && !wallet.isDeleted;
  }
}
