Feature: Validacion de saldo del receptor

  Background:
    * configure headers = { 'x-channel': 'POSTMAN' }

  @Receptor
  Scenario: Validar el incremento del saldo del receptor

    # 1. LOGIN DEL RECEPTOR

    Given url authUrl
    And path '/auth/v1/login'
    And request { phone: '#(receptor.celular)', pin: '#(receptor.pin)' }
    When method post
    Then status 200
    And match response.token == '#string'
    And match response.user.id == receptor.id

    * def tokenReceptor = response.token

    # 2. CONSULTAR SALDO ACTUAL

    Given url walletUrl
    And path '/wallet/v1/balance'
    And header Authorization = 'Bearer ' + tokenReceptor
    When method get
    Then status 200
    And match response.balance == '#number'

    # 3. VALIDAR EL INCREMENTO DE 450

    * def saldoEsperado = receptor.saldoInicial + 450
    And match response.balance == saldoEsperado

    * def saldoFinalReceptor = response.balance

    * print 'Saldo inicial del receptor:', receptor.saldoInicial
    * print 'Saldo final del receptor:', saldoFinalReceptor

    # 4. CONSULTAR LAS TRANSACCIONES DEL RECEPTOR

    Given url walletUrl
    And path '/wallet/v1/transactions'
    And header Authorization = 'Bearer ' + tokenReceptor
    When method get
    Then status 200
    And match response == '#array'

    # 5. BUSCAR Y VALIDAR LA TRANSFERENCIA DEL ESCENARIO 2

    * def movimientos = karate.filter(response, function(x){ return x.referenceCode == codigoTransaccion; })
    * match movimientos == '#[1]'

    * def movimiento = movimientos[0]

    And match movimiento.referenceCode == codigoTransaccion
    And match movimiento.type == 'INCOME'
    And match movimiento.amount == 450
    And match movimiento.counterpartyPhone == emisor.celular
    And match movimiento.description contains 'Pago de Servicios'

    * print 'Codigo esperado:', codigoTransaccion
    * print 'Codigo recibido:', movimiento.referenceCode
    * print 'Monto recibido:', movimiento.amount