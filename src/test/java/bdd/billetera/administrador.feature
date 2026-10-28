Feature: Validacion administrativa de la transferencia

  Background:
    * configure headers = { 'x-channel': 'ADMIN' }
    * def requestAdmin = read('classpath:bdd/billetera/json/admin.json')

  @Administrador
  Scenario: Validar la transferencia en la auditoria

    # 1. LOGIN DEL ADMINISTRADOR

    Given url adminUrl
    And path '/admin/v1/login'
    And request requestAdmin
    When method post
    Then status 200
    And match response.token == '#string'

    * def tokenAdmin = response.token

    # 2. CONSULTAR LAS TRANSACCIONES

    Given url adminUrl
    And path '/admin/v1/transactions'
    And header Authorization = 'Bearer ' + tokenAdmin
    When method get
    Then status 200
    And match response == '#array'

    # 3. BUSCAR SOLO LOS MOVIMIENTOS DE NUESTRA TRANSFERENCIA

    * def movimientos = karate.filter(response, function(x){ return x.referenceCode == codigoTransaccion; })
    * match movimientos == '#[2]'

    # 4. VALIDAR LA SALIDA DEL EMISOR

    * def salida =
      """
      {
        "referenceCode": "#(codigoTransaccion)",
        "userId": "#(emisor.id)",
        "type": "EXPENSE",
        "amount": 450,
        "counterpartyPhone": "#(receptor.celular)"
      }
      """

    And match movimientos contains deep salida

    # 5. VALIDAR LA ENTRADA DEL RECEPTOR

    * def entrada =
      """
      {
        "referenceCode": "#(codigoTransaccion)",
        "userId": "#(receptor.id)",
        "type": "INCOME",
        "amount": 450,
        "counterpartyPhone": "#(emisor.celular)"
      }
      """

    And match movimientos contains deep entrada

    * print 'Transferencia validada:', codigoTransaccion