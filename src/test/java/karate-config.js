function fn() {
  var host = 'http://134.209.211.10';

  return {
    authUrl: host + ':4001',
    walletUrl: host + ':4002',
    transactionUrl: host + ':4003',
    adminUrl: host + ':4004'
  };
}