Feature: Registro de usuarios y asignacion de saldo

  Background:
    * configure headers = { 'x-channel': 'POSTMAN' }
    * def generarCelular = function(){ return '9' + Math.floor(10000000 + Math.random() * 90000000); }
    * def pin = '123456'

  Scenario: Ejecutar el flujo de billetera

    # ESCENARIO 1: REGISTRO

    * def registro = call read('classpath:bdd/billetera/registro.feature')

    * def emisor = registro.emisor
    * def receptor = registro.receptor
    * def datos = { emisor: '#(emisor)', receptor: '#(receptor)' }

    # ESCENARIO 2: TRANSFERENCIA

    * def transferencia = call read('classpath:bdd/billetera/transferencia.feature') datos

    * def idTransaccion = transferencia.idTransaccion
    * def codigoTransaccion = transferencia.codigoTransaccion

    * set datos.idTransaccion = idTransaccion
    * set datos.codigoTransaccion = codigoTransaccion

    # ESCENARIO 3: VALIDACION DEL RECEPTOR

    * def resultadoReceptor = call read('classpath:bdd/billetera/receptor.feature') datos

    # FLUJO ADMINISTRADOR

    * def resultadoAdmin = call read('classpath:bdd/billetera/administrador.feature') datos