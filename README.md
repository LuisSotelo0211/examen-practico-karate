# Examen Práctico de Karate

Proyecto de automatización de pruebas API desarrollado con **Karate
DSL**, **Java 21**, **Maven** y **JUnit 5** para validar el flujo de una
billetera digital.

La automatización cubre el registro de usuarios, validación de
duplicidad, asignación de saldo, transferencia entre usuarios,
validación del saldo y movimiento del receptor, y auditoría
administrativa de la operación.

## Flujo automatizado

El flujo de regresión se ejecuta en el siguiente orden:

``` text
Registro de usuarios
        ↓
Transferencia del Emisor al Receptor
        ↓
Validación de la transferencia en el Receptor
        ↓
Validación administrativa
```

La feature `regresion.feature` funciona como orquestador y permite
ejecutar el flujo completo de manera integrada.

## Escenarios implementados

### 1. Registro de usuarios y asignación de saldo

Se crean dinámicamente dos usuarios:

-   Emisor.
-   Receptor.

Para cada ejecución se genera un número celular aleatorio. El celular
también se utiliza para identificar el nombre y correo del usuario.

Ejemplo:

``` text
Emisor LabAutomation 951931730
emisor951931730@example.com
```

Durante este escenario se valida:

-   Registro correcto del Emisor.
-   Estado `ACTIVE` del usuario.
-   Validación de usuario duplicado.
-   Registro correcto del Receptor.
-   IDs diferentes entre Emisor y Receptor.
-   Login de ambos usuarios.
-   Asignación de saldo al Emisor.
-   Asignación de saldo al Receptor.
-   Consulta y almacenamiento de los saldos iniciales.

La validación de duplicidad vuelve a enviar el mismo request del Emisor
y comprueba:

``` text
HTTP 409 Conflict
code: AUTH_006
message: User already exists
```

### 2. Transferencia del Emisor al Receptor

El Emisor inicia sesión y realiza una transferencia de **450** al
Receptor con la descripción:

``` text
Pago de Servicios
```

Se valida:

-   Login correcto del Emisor.
-   Token de autenticación.
-   Estado `COMPLETED` de la transferencia.
-   `transactionId`.
-   `referenceCode`.
-   Disminución correcta del saldo del Emisor.

El saldo esperado se calcula a partir del saldo guardado durante el
registro:

``` text
saldoEsperado = saldoInicialEmisor - montoTransferencia
```

### 3. Validación de la transferencia en el Receptor

El Receptor inicia sesión y se consulta su saldo después de la
transferencia.

Se valida:

-   Login correcto del Receptor.
-   Incremento del saldo en 450.
-   Consulta de sus transacciones.
-   Existencia de la transferencia mediante `referenceCode`.
-   Tipo de movimiento `INCOME`.
-   Monto de 450.
-   Celular de la contraparte.
-   Descripción `Pago de Servicios`.

Para identificar únicamente la operación creada durante la prueba se
utiliza `karate.filter()` con el `referenceCode`.

### 4. Validación administrativa

El administrador inicia sesión y consulta las transacciones registradas
en el sistema.

Se filtran los movimientos utilizando el mismo `referenceCode` generado
durante la transferencia.

Se espera encontrar dos movimientos:

-   `EXPENSE`: salida de dinero del Emisor.
-   `INCOME`: ingreso de dinero del Receptor.

También se validan el monto, los usuarios involucrados y los celulares
de contraparte.

## Estructura del proyecto

``` text
ExamenKarate
├── src
│   └── test
│       └── java
│           ├── bdd
│           │   └── billetera
│           │       ├── json
│           │       │   ├── admin.json
│           │       │   ├── transferencia.json
│           │       │   └── usuario.json
│           │       ├── administrador.feature
│           │       ├── LabTest.java
│           │       ├── receptor.feature
│           │       ├── registro.feature
│           │       ├── regresion.feature
│           │       └── transferencia.feature
│           ├── karate-config.js
│           └── logback-test.xml
├── .gitignore
└── pom.xml
```

## Descripción de archivos principales

  -----------------------------------------------------------------------
  Archivo                             Descripción
  ----------------------------------- -----------------------------------
  `registro.feature`                  Registra Emisor y Receptor, valida
                                      duplicidad y prepara los saldos.

  `transferencia.feature`             Realiza la transferencia y valida
                                      la disminución del saldo del
                                      Emisor.

  `receptor.feature`                  Valida el incremento de saldo y la
                                      transacción recibida.

  `administrador.feature`             Valida la operación desde el flujo
                                      administrativo.

  `regresion.feature`                 Orquesta el flujo completo de
                                      regresión.

  `LabTest.java`                      Runner de Karate con JUnit 5.

  `karate-config.js`                  Centraliza las URLs utilizadas por
                                      las pruebas.

  `usuario.json`                      Plantilla de datos para el registro
                                      de usuarios.

  `transferencia.json`                Payload utilizado para realizar la
                                      transferencia.

  `admin.json`                        Datos utilizados para la
                                      autenticación administrativa.

  `logback-test.xml`                  Configuración de logs de la
                                      ejecución.
  -----------------------------------------------------------------------

## Tecnologías utilizadas

-   Java 21
-   Maven
-   Karate DSL
-   JUnit 5
-   IntelliJ IDEA
-   Git
-   GitHub

## Configuración de servicios

Las URLs se centralizan en `karate-config.js`.

``` javascript
function fn() {
  var host = 'http://134.209.211.10';

  return {
    authUrl: host + ':4001',
    walletUrl: host + ':4002',
    transactionUrl: host + ':4003',
    adminUrl: host + ':4004'
  };
}
```

Esto evita repetir las URLs dentro de cada feature y facilita su
reutilización.

## Ejecución

### Requisitos

Antes de ejecutar el proyecto se debe contar con:

-   JDK 21.
-   Maven configurado.
-   Acceso a los servicios utilizados por el examen.

Verificar Java:

``` bash
java -version
```

Verificar Maven:

``` bash
mvn -version
```

### Ejecutar la regresión

Desde IntelliJ se puede ejecutar el método:

``` text
LabTest.ejecutarRegresion()
```

También se puede ejecutar mediante Maven:

``` bash
mvn test
```

El runner utilizado es:

``` java
@Karate.Test
Karate ejecutarRegresion() {
    return Karate.run("regresion").relativeTo(getClass());
}
```

## Reportes

Después de ejecutar las pruebas, Karate genera los reportes dentro de:

``` text
target/karate-reports/
```

El reporte correspondiente al flujo de regresión puede encontrarse como:

``` text
target/karate-reports/bdd.billetera.regresion.html
```

Desde el reporte se pueden revisar:

-   Escenarios ejecutados.
-   Pasos de cada escenario.
-   Requests.
-   Responses.
-   Códigos HTTP.
-   Validaciones.
-   Tiempo de ejecución.
-   Resultado final de la prueba.

> La carpeta `target/` no se versiona en Git porque contiene archivos
> generados durante la ejecución.

## Buenas prácticas aplicadas

-   Separación del flujo por responsabilidades mediante features.
-   Uso de `regresion.feature` como orquestador.
-   Datos dinámicos para evitar dependencia de usuarios previamente
    creados.
-   Reutilización de payloads mediante archivos JSON.
-   Centralización de URLs en `karate-config.js`.
-   Uso de variables para compartir IDs, tokens, saldos y códigos de
    transacción.
-   Validación de respuestas mediante `match` y `assert`.
-   Identificación de transacciones mediante `referenceCode`.
-   Validación de escenarios positivos y de duplicidad.
-   Exclusión de archivos generados y configuraciones locales mediante
    `.gitignore`.

## Resultado esperado

Al ejecutar la regresión completa se debe validar correctamente el
siguiente flujo:

``` text
Crear Emisor y Receptor
        ↓
Validar usuario duplicado
        ↓
Asignar y validar saldos
        ↓
Transferir 450
        ↓
Validar disminución del saldo del Emisor
        ↓
Validar incremento del saldo del Receptor
        ↓
Validar movimiento recibido
        ↓
Validar EXPENSE e INCOME desde Administración
```

## Conclusión

La automatización permite validar de extremo a extremo el flujo
principal solicitado para la billetera digital. Los escenarios se
encuentran separados por responsabilidad y son ejecutados de forma
integrada mediante una feature de regresión.

El uso de datos dinámicos permite repetir la prueba sin depender de
usuarios previamente creados, mientras que el `referenceCode` permite
seguir la misma transferencia a través de las validaciones del Emisor,
Receptor y Administrador.
