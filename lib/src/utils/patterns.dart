class Patterns {
  static final RegExp evm = RegExp(r'^0x[a-f0-9]{40}$', caseSensitive: false);
  static final RegExp atom = RegExp(
    r'^(cosmos|osmo|axelar|juno|stars)1[a-zA-Z0-9]{38}$',
  );
  static final RegExp sol = RegExp(r'^[1-9A-HJ-NP-Za-km-z]{32,44}$');
  static final adaMainnet = RegExp(r'^addr1[a-z0-9]{98}$');
  static final adaTestnet = RegExp(r'^addr_test1[a-z0-9]{98}$');
  static final adaStake = RegExp(r'^stake1[a-z0-9]{53}$');
  static final adaStakeTestnet = RegExp(r'^stake_test1[a-z0-9]{53}$');
  static final RegExp algo = RegExp(r'^[A-Z2-7]{58}$');
  static final RegExp xlm = RegExp(r'^G[A-Z2-7]{55}$');
  static final RegExp ican = RegExp(
    r'^(cb|ce|ab)[0-9]{2}[a-f0-9]{40}$',
    caseSensitive: false,
  );
  static final RegExp dot = RegExp(r'^[1-9A-HJ-NP-Za-km-z]{47,48}$');
  static final RegExp tron = RegExp(r'^T[1-9A-HJ-NP-Za-km-z]{33}$');

  static final btcLegacy = RegExp(r'^[1][a-km-zA-HJ-NP-Z1-9]{25,34}$');
  static final btcSegwit = RegExp(r'^[3][a-km-zA-HJ-NP-Z1-9]{25,34}$');
  static final btcNativeSegwit = RegExp(r'^(bc1|tb1)[a-zA-HJ-NP-Z0-9]{25,89}$');

  static final ltcLegacy = RegExp(r'^L[1-9A-HJ-NP-Za-km-z]{26,34}$');
  static final ltcSegwit = RegExp(r'^M[1-9A-HJ-NP-Za-km-z]{26,34}$');
  static final ltcNativeSegwit = RegExp(
    r'^(ltc1|tltc1)[a-zA-HJ-NP-Z0-9]{25,89}$',
  );

  static final RegExp xrp = RegExp(r'^r[1-9A-HJ-NP-Za-km-z]{24,34}$');

  static final bchCashAddr = RegExp(
    r'^(bitcoincash:)?[qpzry9x8gf2tvdw0s3jn54khce6mua7l]{42}$',
  );
  static final bchAddress = RegExp(
    r'^[qp][qpzry9x8gf2tvdw0s3jn54khce6mua7l]{41}$',
  );
}
