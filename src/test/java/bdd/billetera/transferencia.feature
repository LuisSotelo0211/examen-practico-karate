Feature: Transferencia del emisor al receptor

  Background:
    * configure headers = { 'x-channel': 'POSTMAN' }

  @Transferencia
  Scenario: Transferir 450 y validar el saldo del emisor

    # 1. LOGIN DEL EMISOR

    Given url authUrl
    And path '/auth/v1/login'
    And request { phone: '#(emisor.celular)', pin: '#(emisor.pin)' }
    When method post
    Then status 200
    And match response.token == '#string'
    And match response.user.id == emisor.id

    * def tokenEmisor = response.token

    # 2. LEER LOS DATOS DE LA TRANSFERENCIA

    * def requestTransferencia = read('classpath:bdd/billetera/json/transferencia.json')

    # 3. TRANSFERIR AL RECEPTOR

    Given url transactionUrl
    And path '/transaction/v1/transfer'
    And header Authorization = 'Bearer ' + tokenEmisor
    And request requestTransferencia
    When method post
    Then status 200
    And match response.status == 'COMPLETED'
    And match response.transactionId == '#string'
    And match response.referenceCode == '#string'

    # 4. GUARDAR EL IDENTIFICADOR Y EL CODIGO DE REFERENCIA

    * def idTransaccion = response.transactionId
    * def codigoTransaccion = response.referenceCode

    # 5. CONSULTAR EL SALDO DEL EMISOR

    Given url walletUrl
    And path '/wallet/v1/balance'
    And header Authorization = 'Bearer ' + tokenEmisor
    When method get
    Then status 200
    And match response.balance == '#number'

    # 6. COMPARAR CON EL SALDO GUARDADO EN EL ESCENARIO 1

    * def saldoEsperado = emisor.saldoInicial - requestTransferencia.amount
    And match response.balance == saldoEsperado

    * def saldoFinalEmisor = response.balance

    * print 'Identificador de transaccion:', idTransaccion
    * print 'Codigo de referencia:', codigoTransaccion
    * print 'Saldo inicial del emisor:', emisor.saldoInicial
    * print 'Saldo final del emisor:', saldoFinalEmisor