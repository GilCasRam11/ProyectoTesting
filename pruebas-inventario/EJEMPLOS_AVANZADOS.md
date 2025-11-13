# 🎓 Ejemplos Avanzados de Karate

## 📚 Tabla de Contenidos
1. [Validaciones Complejas](#validaciones-complejas)
2. [Manejo de Errores](#manejo-de-errores)
3. [Datos Dinámicos](#datos-dinámicos)
4. [Hooks y Setup](#hooks-y-setup)
5. [Best Practices](#best-practices)

---

## 🔍 Validaciones Complejas

### Validar Estructura Anidada

```gherkin
Scenario: Validar estructura compleja anidada
  Given path '/api/productos/1'
  When method get
  Then status 200
  
  # Validar estructura profunda
  And match response ==
    """
    {
      id: '#number',
      nombre: '#string',
      metadata: {
        createdAt: '#string',
        updatedAt: '#string',
        createdBy: {
          id: '#number',
          email: '#string'
        }
      },
      tags: '#[]',
      especificaciones: {
        memoria: '#string',
        procesador: '#string',
        pantalla: '#object'
      }
    }
    """
```

### Validar Valores Condicionales

```gherkin
Scenario: Validar valores según condiciones
  Given path '/api/productos'
  When method get
  Then status 200
  
  # Si es Premium, debe tener precio > 1000
  * def premium = karate.filter(response, x => x.tipo == 'premium')
  * def precioValido = karate.map(premium, x => x.precio > 1000)
  And assert karate.every(precioValido, x => x)
  
  # Si cantidad es 0, estado debe ser "agotado"
  * def agotados = karate.filter(response, x => x.cantidad == 0)
  * def estadoValido = karate.map(agotados, x => x.estado == 'agotado')
  And assert karate.every(estadoValido, x => x)
```

### Validar Rangos y Patrones

```gherkin
Scenario: Validar rangos y patrones
  Given path '/api/productos'
  When method get
  Then status 200
  
  # Verificar rangos de precios
  * def preciosValidos = karate.map(response, x => 
      x.precio >= 0 && x.precio <= 100000)
  And assert karate.every(preciosValidos, x => x)
  
  # Verificar patrón de emails
  * def emailPattern = '.*@.*\\..*'
  * def emailsValidos = karate.map(response, x => 
      karate.match(x.email, emailPattern))
  And assert karate.every(emailsValidos, x => x == true)
  
  # Verificar fechas ISO 8601
  * def fechaPattern = '\\d{4}-\\d{2}-\\d{2}T\\d{2}:\\d{2}:\\d{2}.*'
  * def fechasValidas = karate.map(response, x => 
      karate.match(x.createdAt, fechaPattern))
  And assert karate.every(fechasValidas, x => x == true)
```

### Validar Integridad Referencial

```gherkin
Scenario: Validar integridad entre recursos
  # Obtener lista de productos
  Given path '/api/productos'
  When method get
  Then status 200
  * def productos = response
  
  # Obtener lista de órdenes
  Given path '/api/ordenes'
  When method get
  Then status 200
  * def ordenes = response
  
  # Validar que todos los IDs de productos en órdenes existen en la lista de productos
  * def productosIds = karate.map(productos, x => x.id)
  * def ordenesProductosIds = karate.map(ordenes, x => x.productoId)
  
  * def productosExisten = karate.map(ordenesProductosIds, id =>
      karate.filter(productosIds, x => x == id).length > 0)
  
  And assert karate.every(productosExisten, x => x)
```

---

## ⚠️ Manejo de Errores

### Try-Catch (Captura de Excepciones)

```gherkin
Scenario: Manejar respuestas de error
  Given path '/api/productos/999999'
  When method get
  Then status 404
  
  # Validar estructura del error
  And match response contains
    """
    {
      error: '#string',
      mensaje: '#string',
      timestamp: '#string',
      path: '#string'
    }
    """
  
  # Guardar error para logging
  * def errorDetails = response
  * print 'Error recibido:', errorDetails
```

### Validar Múltiples Códigos de Error

```gherkin
Scenario: Validar diferentes códigos de error
  Given path '/api/productos'
  
  # Test 1: Request inválido (400)
  And request { nombre: '', precio: -50 }
  When method post
  Then assert responseStatus == 400 || responseStatus == 422
  
  # Test 2: No autorizado (401)
  Given path '/api/productos/admin'
  And header Authorization = 'Bearer invalid-token'
  When method get
  Then status 401
  
  # Test 3: Prohibido (403)
  Given path '/api/productos/1'
  And header Authorization = 'Bearer token-sin-permisos'
  When method delete
  Then status 403
  
  # Test 4: No encontrado (404)
  Given path '/api/productos/999999'
  When method get
  Then status 404
  
  # Test 5: Error del servidor (500)
  Given path '/api/productos/error-test'
  When method get
  Then status 500
```

### Reintentos y Resiliencia

```gherkin
Scenario: Implementar reintentos
  * def retry = function(fn, maxAttempts) {
      var attempt = 0
      while (attempt < maxAttempts) {
        try {
          return fn()
        } catch(e) {
          attempt++
          if (attempt >= maxAttempts) throw e
          java.lang.Thread.sleep(1000)
        }
      }
    }
  
  # Usar función de reintento
  * def response = retry(() => {
      karate.call('http://localhost:8080/api/productos')
    }, 3)
```

---

## 🔄 Datos Dinámicos

### Generar Datos Aleatorios

```gherkin
Scenario: Crear producto con datos aleatorios
  # Funciones de generación
  * def randomId = function() { return Math.floor(Math.random() * 10000) }
  * def randomPrice = function() { return Math.random() * 10000 }
  * def randomName = function() {
      var names = ['Laptop', 'Monitor', 'Teclado', 'Mouse', 'Webcam']
      return names[Math.floor(Math.random() * names.length)]
    }
  
  # Construir request dinámico
  * def producto =
    """
    {
      nombre: #(randomName()),
      precio: #(randomPrice()),
      cantidad: #(randomId()),
      sku: 'SKU-' + #(randomId())
    }
    """
  
  Given path '/api/productos'
  And request producto
  When method post
  Then status 201
```

### Usar Datos de Archivo CSV

```gherkin
# productos.csv
# nombre,precio,cantidad
# Laptop,1299.99,10
# Monitor,299.99,25
# Teclado,129.99,50

Scenario Outline: Crear múltiples productos desde CSV
  Given path '/api/productos'
  And request { nombre: '<nombre>', precio: <precio>, cantidad: <cantidad> }
  When method post
  Then status 201
  And assert response.nombre == '<nombre>'
  
  Examples:
    | nombre   | precio | cantidad |
    | Laptop   | 1299.99 | 10      |
    | Monitor  | 299.99  | 25      |
    | Teclado  | 129.99  | 50      |
```

### Transformar Datos

```gherkin
Scenario: Transformar y mapear datos de respuesta
  Given path '/api/productos'
  When method get
  Then status 200
  
  # Extraer solo nombres
  * def nombres = karate.map(response, x => x.nombre)
  * print 'Nombres:', nombres
  
  # Extraer y transformar precios
  * def preciosConImpuesto = karate.map(response, x => ({
      nombre: x.nombre,
      precioOriginal: x.precio,
      precioConImpuesto: x.precio * 1.21
    }))
  * print 'Precios con impuesto:', preciosConImpuesto
  
  # Filtrar y agrupar
  * def productosCaros = karate.filter(response, x => x.precio > 1000)
  * def gruposCategoria = karate.group(productosCaros, 'categoria')
```

---

## 🎣 Hooks y Setup

### Setup y Teardown

```gherkin
Feature: Productos con setup/teardown

  Background:
    # SETUP - Se ejecuta antes de cada scenario
    * def setupPrueba = function() {
        karate.log('=== INICIANDO PRUEBA ===')
        return {
          timestamp: karate.timestamp(),
          usuario: 'testuser',
          ambiente: 'testing'
        }
      }
    
    * def setup = setupPrueba()
    * print 'Setup completado:', setup
  
  Scenario: Prueba con setup
    Given path '/api/productos'
    When method get
    Then status 200
    
    # Logs del scenario
    * print 'Resultado:', response
    * karate.log('Total de productos:', response.length)

  # Nota: Para teardown, usar karate.call() después del scenario
```

### Compartir Estado Entre Scenarios

```gherkin
Feature: Flujo multi-scenario con estado compartido

  Scenario: Step 1 - Crear recurso
    * def nuevoProducto = { nombre: 'Laptop', precio: 999.99 }
    Given path '/api/productos'
    And request nuevoProducto
    When method post
    Then status 201
    
    # Guardar en archivo para próximo scenario
    * def productoCreado = response
    * def escrito = karate.write(productoCreado, 'target/producto-temp.json')

  Scenario: Step 2 - Usar recurso creado
    # Leer desde archivo anterior
    * def productoAnterior = karate.read('target/producto-temp.json')
    * def idProducto = productoAnterior.id
    
    Given path '/api/productos/' + idProducto
    When method get
    Then status 200
    And assert response.nombre == 'Laptop'
```

---

## 🏆 Best Practices

### ✅ Usar Funciones Reutilizables

```gherkin
Feature: Con funciones helper

  Scenario: Helper functions
    # Definir funciones helper
    * def crearProducto = function(nombre, precio, cantidad) {
        return {
          nombre: nombre,
          precio: precio,
          cantidad: cantidad
        }
      }
    
    * def validarProducto = function(producto) {
        return producto.id != null && 
               producto.nombre != '' && 
               producto.precio > 0
      }
    
    # Usar helper functions
    * def laptop = crearProducto('Laptop', 999.99, 5)
    
    Given path '/api/productos'
    And request laptop
    When method post
    Then status 201
    And assert validarProducto(response)
```

### ✅ Logging y Debugging

```gherkin
Scenario: Logging y debugging
  # Log básico
  * print 'Iniciando test'
  
  # Karate log (va a karate.log)
  * karate.log('Log en archivo:', 'información')
  
  # Log condicional
  * if (responseStatus != 200) karate.log('Error:', response)
  
  # Pretty print JSON
  * print JSON.stringify(response, null, 2)
  
  # Log de variables
  * def datos = { nombre: 'Test', valor: 123 }
  * karate.log('Datos:', karate.pretty(datos))
```

### ✅ Documentación Clara

```gherkin
Feature: API de Productos
  Como usuario de la API
  Quiero gestionar productos
  Para mantener un inventario actualizado

  Background:
    # URL base y configuración
    * url 'http://localhost:8080'
    * def apiPath = '/api/productos'
    * header Content-Type = 'application/json'

  @smokeTest @regression
  Scenario: Crear y recuperar producto
    """
    Descripción: Verifica el flujo completo CRUD
    
    Pasos:
    1. Crear un nuevo producto
    2. Validar que se creó correctamente
    3. Recuperar el producto por ID
    4. Validar datos coinciden
    
    Datos esperados:
    - Status 201 al crear
    - Status 200 al recuperar
    - Respuesta contiene todos los campos
    """
    
    # STEP 1: Crear
    Given path apiPath
    And request { nombre: 'Laptop', precio: 999.99, cantidad: 5 }
    When method post
    Then status 201
    * def productoId = response.id
    
    # STEP 2 & 3: Recuperar
    Given path apiPath + '/' + productoId
    When method get
    Then status 200
    
    # STEP 4: Validar
    And assert response.nombre == 'Laptop'
    And assert response.precio == 999.99
```

### ✅ Parametrización para Reutilización

```gherkin
Feature: Usar variables de configuración

  Scenario: Configuración flexible
    # Variables configurables
    * def baseUrl = 'http://localhost:8080'
    * def apiVersion = 'v1'
    * def timeout = 5000
    * def retryCount = 3
    
    * url baseUrl
    * configure connectTimeout = timeout
    * configure readTimeout = timeout
    
    Given path '/api/v' + apiVersion + '/productos'
    When method get
    Then status 200
```

---

## 📊 Análisis y Reportes

### Extraer Métricas

```gherkin
Scenario: Recolectar métricas de prueba
  * def metricas = {
      inicio: karate.timestamp(),
      totalRequests: 0,
      totalErrores: 0,
      tiempos: []
    }
  
  Given path '/api/productos'
  When method get
  Then status 200
  
  * metricas.totalRequests = 1
  * metricas.tiempos.push(responseTime)
  
  * print '=== MÉTRICAS ==='
  * print 'Total requests:', metricas.totalRequests
  * print 'Tiempo respuesta:', metricas.tiempos[0] + ' ms'
  * print 'Timestamp:', metricas.inicio
```

---

**Última actualización**: Noviembre 13, 2025
