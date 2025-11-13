# Guía Completa: Pruebas de API con Karate Framework

## 📋 Tabla de Contenidos
1. [Configuración Base](#configuración-base)
2. [Métodos HTTP](#métodos-http)
3. [Request Payloads](#request-payloads)
4. [Aserciones](#aserciones)
5. [Variables y Datos](#variables-y-datos)
6. [Ejemplos Prácticos](#ejemplos-prácticos)

---

## 🔧 Configuración Base

### URL Base
```gherkin
* url 'http://localhost:8080'
```
Define el dominio base para todas las peticiones. Todos los `path` se construirán a partir de esta URL.

**Alternativas por entorno:**
```gherkin
# Desarrollo
* url 'http://localhost:8080'

# Testing
* url 'http://staging-api.example.com'

# Producción
* url 'https://api.example.com'
```

### Headers Comunes
```gherkin
* header Content-Type = 'application/json'
* header Accept = 'application/json'
* header Authorization = 'Bearer ' + token
```

### Definición de Variables Globales
```gherkin
* def apiBasePath = '/api/productos'
* def productoId = 1
* def headers = { 'Content-Type': 'application/json' }
```

---

## 📡 Métodos HTTP

### GET - Obtener Recursos
```gherkin
# Obtener lista
Given path '/api/productos'
When method get
Then status 200

# Obtener por ID
Given path '/api/productos/1'
When method get
Then status 200

# Con parámetros query
Given path '/api/productos'
And param page = 0
And param size = 10
When method get
Then status 200
```

### POST - Crear Recursos
```gherkin
* def nuevoProducto = { nombre: 'Laptop', precio: 999.99 }

Given path '/api/productos'
And request nuevoProducto
When method post
Then status 201
```

### PUT - Actualizar Completo
```gherkin
* def actualizacion = { 
    nombre: 'Laptop Actualizada', 
    precio: 1099.99,
    cantidad: 8
  }

Given path '/api/productos/1'
And request actualizacion
When method put
Then status 200
```

### PATCH - Actualizar Parcial
```gherkin
* def actualizacionParcial = { precio: 1199.99 }

Given path '/api/productos/1'
And request actualizacionParcial
When method patch
Then status 200
```

### DELETE - Eliminar Recursos
```gherkin
Given path '/api/productos/1'
When method delete
Then status 204
```

---

## 📦 Request Payloads

### Formato JSON Inline
```gherkin
And request { nombre: 'Producto', precio: 100 }
```

### Formato JSON Multilinea (Recomendado)
```gherkin
* def producto = 
  """
  {
    nombre: 'Laptop Dell XPS 13',
    precio: 1299.99,
    cantidad: 10,
    descripcion: 'Laptop de alta gama'
  }
  """

Given path '/api/productos'
And request producto
```

### Request con Variables Dinámicas
```gherkin
* def nombre = 'Laptop'
* def precio = 999.99
* def producto = { nombre: '#(nombre)', precio: '#(precio)' }

And request producto
```

### Request con Arrays
```gherkin
* def productos =
  """
  [
    { nombre: 'Producto 1', precio: 100 },
    { nombre: 'Producto 2', precio: 200 }
  ]
  """

And request productos
```

---

## ✅ Aserciones

### Validar Status HTTP
```gherkin
Then status 200          # OK
Then status 201          # Created
Then status 204          # No Content
Then status 400          # Bad Request
Then status 404          # Not Found
Then status 500          # Server Error
```

### Validar Estructura (Match)
```gherkin
# Validar estructura exacta
And match response ==
  """
  {
    id: '#number',
    nombre: '#string',
    precio: '#number'
  }
  """

# Validar que contiene campos específicos
And match response contains
  """
  {
    nombre: 'Laptop',
    precio: 999.99
  }
  """

# Validar cada elemento de un array
And match each response[*] contains
  """
  {
    id: '#number',
    nombre: '#string'
  }
  """
```

### Validadores de Tipo
```gherkin
# String
And assert response.nombre == '#string'

# Number
And assert response.precio == '#number'

# Boolean
And assert response.activo == '#boolean'

# Array
And assert response.items == '#[]'

# Object
And assert response.metadata == '#object'

# Null
And assert response.descripcion == '#null'

# Any value (no null)
And assert response.id == '#present'
```

### Validaciones Lógicas
```gherkin
# Igualdad
And assert response.nombre == 'Laptop'
And assert response.precio == 999.99

# Desigualdad
And assert response.precio != 0

# Mayor/Menor
And assert response.precio > 500
And assert response.cantidad < 100
And assert response.stock >= 5
And assert response.rating <= 5

# Contains (strings)
And assert response.nombre contains 'Laptop'

# Expresiones lógicas
And assert response.precio > 0 && response.cantidad >= 0
And assert response.estado == 'activo' || response.estado == 'pendiente'
```

### Validaciones de Arrays
```gherkin
# Verificar longitud
And assert response.length == 5
And assert response.length > 0

# Validar todos los elementos
And match each response[*].precio > 0

# Buscar elementos específicos
And assert karate.filter(response, 'x => x.precio > 500').length > 0
```

---

## 💾 Variables y Datos

### Definición de Variables
```gherkin
# Variables simples
* def producto = { nombre: 'Laptop', precio: 999.99 }

# Variables de respuesta anterior
* def productoId = response.id

# Variables condicionales
* def status = response.estado == 'activo' ? 'ACTIVO' : 'INACTIVO'
```

### Uso de Variables en Request
```gherkin
* def nombre = 'Laptop'
* def precio = 999.99

And request { nombre: '#(nombre)', precio: '#(precio)' }
```

### Iteración sobre Datos
```gherkin
# Extraer array de valores
* def precios = get response[*].precio

# Usar karate.map
* def nombres = karate.map(response, x => x.nombre)

# Usar karate.filter
* def productosCaros = karate.filter(response, x => x.precio > 1000)
```

### Datos Reutilizables (CSV, JSON)
```gherkin
# Cargar desde archivo
* def productosData = read('data/productos.json')

# Usar en loop
Scenario Outline: Crear múltiples productos
  Given path '/api/productos'
  And request <producto>
  When method post
  Then status 201

  Examples:
    | producto |
    | { nombre: 'Producto 1', precio: 100 } |
    | { nombre: 'Producto 2', precio: 200 } |
```

---

## 📝 Ejemplos Prácticos

### Ejemplo 1: Flujo Completo CRUD
```gherkin
Feature: CRUD de Productos

  Background:
    * url 'http://localhost:8080'
    * def apiPath = '/api/productos'

  Scenario: Flujo completo de un producto
    # CREATE
    * def nuevoProducto = { nombre: 'Laptop', precio: 999.99, cantidad: 5 }
    Given path apiPath
    And request nuevoProducto
    When method post
    Then status 201
    * def productoId = response.id

    # READ
    Given path apiPath + '/' + productoId
    When method get
    Then status 200
    And match response.nombre == 'Laptop'

    # UPDATE
    * def actualizacion = { nombre: 'Laptop Actualizada', precio: 1199.99 }
    Given path apiPath + '/' + productoId
    And request actualizacion
    When method put
    Then status 200

    # DELETE
    Given path apiPath + '/' + productoId
    When method delete
    Then status 204
```

### Ejemplo 2: Manejo de Errores
```gherkin
Scenario: Validar errores de entrada
  * def productoInvalido = { nombre: '', precio: -50 }
  
  Given path '/api/productos'
  And request productoInvalido
  When method post
  Then status 400
  And match response.error == '#string'
  And assert response.error contains 'nombre'

Scenario: Recurso no encontrado
  Given path '/api/productos/999999'
  When method get
  Then status 404
  And match response.mensaje contains 'No encontrado'
```

### Ejemplo 3: Validación Avanzada
```gherkin
Scenario: Validación de estructura compleja
  Given path '/api/productos'
  When method get
  Then status 200
  
  # Validar estructura de lista
  And match response == '#[]'
  
  # Validar cada producto
  And match each response contains {
    id: '#number',
    nombre: '#string',
    precio: '#number',
    cantidad: '#number',
    activo: '#boolean',
    categor: '#string'
  }
  
  # Validar valores
  And assert each response.precio > 0
  And assert each response.cantidad >= 0
  
  # Validar sin errores
  And assert response.length > 0
```

### Ejemplo 4: Paramétrizados
```gherkin
Scenario Outline: Crear productos con diferentes datos
  Given path '/api/productos'
  And request { nombre: '<nombre>', precio: <precio>, cantidad: <cantidad> }
  When method post
  Then status 201
  And assert response.nombre == '<nombre>'

  Examples:
    | nombre           | precio | cantidad |
    | Laptop           | 999.99 | 5        |
    | Monitor          | 299.99 | 10       |
    | Teclado          | 79.99  | 20       |
    | Mouse            | 29.99  | 50       |
```

---

## 🎯 Best Practices

### ✅ DO (Haz esto)
```gherkin
# ✅ Usar variables para mejor mantenibilidad
* def apiPath = '/api/productos'
* def productoBase = { nombre: 'Producto', precio: 100 }

# ✅ Validar estructura y valores
And match response contains { id: '#number' }
And assert response.id > 0

# ✅ Comentarios claros
# Este scenario valida la creación de productos

# ✅ Datos en archivos separados
* def testData = read('data/productos.json')

# ✅ Nombres descriptivos
Scenario: Crear producto y validar stock
```

### ❌ DON'T (Evita esto)
```gherkin
# ❌ URLs hardcodeadas
Given path 'http://localhost:8080/api/productos'

# ❌ Validaciones débiles
And match response == '#string'

# ❌ Variables genéricas
* def x = response.id
* def y = { nombre: 'P' }

# ❌ Datos en scenarios
And request { nombre: 'Producto Test 1', precio: 100 }

# ❌ Nombres ambiguos
Scenario: Test
```

---

## 🔗 Referencias Útiles

- [Documentación oficial de Karate](https://karatelabs.github.io/karate/)
- [Match expressions](https://karatelabs.github.io/karate/#match)
- [Functions](https://karatelabs.github.io/karate/#functions)
- [Syntax reference](https://karatelabs.github.io/karate/#syntax)

---

**Última actualización**: Noviembre 13, 2025  
**Versión de Karate**: 1.3.1  
**Java**: 21 LTS
