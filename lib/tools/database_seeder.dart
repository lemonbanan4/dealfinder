class DatabaseSeeder {
  //   const DatabaseSeeder(this._repo);
  //   final FirestoreDealRepository _repo;

  //   Future<void> reseed() async {
  //     try {
  //       await _repo.clearDeals();
  //       await _repo.seedDeals(_mockDeals);
  //       debugPrint('[DatabaseSeeder] Reseeded \${_mockDeals.length} deals.');
  //     } catch (e) {
  //       debugPrint('[DatabaseSeeder] Reseed failed: \$e');
  //     }
  //   }

  //   Future<void> seedOnce() async {
  //     try {
  //       if (await _repo.hasDeals()) return;
  //       await _repo.seedDeals(_mockDeals);
  //       debugPrint('[DatabaseSeeder] Seeded \${_mockDeals.length} deals.');
  //     } catch (e) {
  //       debugPrint('[DatabaseSeeder] Seed skipped: \$e');
  //     }
  //   }
}
