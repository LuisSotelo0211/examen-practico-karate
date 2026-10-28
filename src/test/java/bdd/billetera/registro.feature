Feature: Registro de usuarios y asignacion de saldo

  Background:
    * configure headers = { 'x-channel': 'POSTMAN' }
    * def generarCelular = function(){ return '9' + Math.floor(10000000 + Math.random() * 90000000); }
    * def pin = '123456'

  @Registro
  Scenario: Crear emisor y receptor y validar sus saldos

    # 1. REGISTRAR EMISOR

    * def celular = generarCelular()
    * def nombre = 'Emisor LabAutomation ' + celular
    * def correo = 'emisor' + celular + '@example.com'
    * def requestEmisor = read('classpath:bdd/billetera/json/usuario.json')

    Given url authUrl
    And path '/auth/v1/register'
    And request requestEmisor
    When method post
    Then status 201
    And match response.user.id == '#string'
    And match response.user.status == 'ACTIVE'

    * def idEmisor = response.user.id
    * def celularEmisor = celular

    # VALIDAR DUPLICIDAD DEL EMISOR

    Given url authUrl
    And path '/auth/v1/register'
    And request requestEmisor
    When method post
    Then status 409
    And match response.code == 'AUTH_006'
    And match response.message == 'User already exists'

    # 2. REGISTRAR RECEPTOR

    * def celular = generarCelular()
    * assert celular != celularEmisor
    * def nombre = 'Receptor LabAutomation ' + celular
    * def correo = 'receptor' + celular + '@example.com'
    * def requestReceptor = read('classpath:bdd/billetera/json/usuario.json')

    Given url authUrl
    And path '/auth/v1/register'
    And request requestReceptor
    When method post
    Then status 201
    And match response.user.id == '#string'
    And match response.user.status == 'ACTIVE'

    * def idReceptor = response.user.id
    * def celularReceptor = celular
    * assert idEmisor != idReceptor

    # 3. LOGIN DEL EMISOR

    Given url authUrl
    And path '/auth/v1/login'
    And request { phone: '#(celularEmisor)', pin: '#(pin)' }
    When method post
    Then status 200
    And match response.token == '#string'
    And match response.user.id == idEmisor

    * def tokenEmisor = response.token

    # 4. LOGIN DEL RECEPTOR

    Given url authUrl
    And path '/auth/v1/login'
    And request { phone: '#(celularReceptor)', pin: '#(pin)' }
    When method post
    Then status 200
    And match response.token == '#string'
    And match response.user.id == idReceptor

    * def tokenReceptor = response.token

    # 5. CONSULTAR SALDO DEL EMISOR ANTES DE RECARGAR

    Given url walletUrl
    And path '/wallet/v1/balance'
    And header Authorization = 'Bearer ' + tokenEmisor
    When method get
    Then status 200
    And match response.balance == '#number'

    * def saldoPrevioEmisor = response.balance
    * def saldoEsperadoEmisor = saldoPrevioEmisor + 1000

    # 6. RECARGAR 1000 AL EMISOR

    Given url walletUrl
    And path '/wallet/v1/deposit'
    And header Authorization = 'Bearer ' + tokenEmisor
    And request { amount: 1000 }
    When method post
    Then status 200
    And match response.success == true
    And match response.newBalance == saldoEsperadoEmisor

    # 7. VALIDAR Y GUARDAR EL SALDO DEL EMISOR

    Given url walletUrl
    And path '/wallet/v1/balance'
    And header Authorization = 'Bearer ' + tokenEmisor
    When method get
    Then status 200
    And match response.balance == saldoEsperadoEmisor

    * def saldoInicialEmisor = response.balance
    * assert saldoInicialEmisor >= 450

    # 8. CONSULTAR SALDO DEL RECEPTOR ANTES DE RECARGAR

    Given url walletUrl
    And path '/wallet/v1/balance'
    And header Authorization = 'Bearer ' + tokenReceptor
    When method get
    Then status 200
    And match response.balance == '#number'

    * def saldoPrevioReceptor = response.balance
    * def saldoEsperadoReceptor = saldoPrevioReceptor + 100

    # 9. RECARGAR 100 AL RECEPTOR

    Given url walletUrl
    And path '/wallet/v1/deposit'
    And header Authorization = 'Bearer ' + tokenReceptor
    And request { amount: 100 }
    When method post
    Then status 200
    And match response.success == true
    And match response.newBalance == saldoEsperadoReceptor

    # 10. VALIDAR Y GUARDAR EL SALDO DEL RECEPTOR

    Given url walletUrl
    And path '/wallet/v1/balance'
    And header Authorization = 'Bearer ' + tokenReceptor
    When method get
    Then status 200
    And match response.balance == saldoEsperadoReceptor

    * def saldoInicialReceptor = response.balance

    # 11. GUARDAR LOS USUARIOS PARA LOS DEMAS ESCENARIOS

    * def emisor = { id: '#(idEmisor)', celular: '#(celularEmisor)', pin: '#(pin)', saldoInicial: '#(saldoInicialEmisor)' }
    * def receptor = { id: '#(idReceptor)', celular: '#(celularReceptor)', pin: '#(pin)', saldoInicial: '#(saldoInicialReceptor)' }

    * print 'Celular del receptor:', celularReceptor
    * print 'Saldo inicial del emisor:', saldoInicialEmisor
    * print 'Saldo inicial del receptor:', saldoInicialReceptor