# ⚡ Referencia Rápida - Karate Cheat Sheet

## 🚀 Comandos Rápidos

```bash
# Ejecutar todos los tests
mvn clean test

# Ejecutar en entorno específico
mvn clean test -Dkarate.env=staging

# Ejecutar scenario específico
mvn clean test -Dkarate.options="--name 'Crear nuevo'"

# Con tags
mvn clean test -Dkarate.options="--tags @smokeTest"

# Reporte JSON
mvn clean test -Dkarate.options="--format json:target/karate-reports"

# Debug mode
mvn clean test -X
```

---

## 📝 Sintaxis Básica

### URL y Path
```gherkin
* url 'http://localhost:8080'
Given path '/api/productos'
Given path apiBasePath + '/1'
```

### Headers y Parámetros
```gherkin
* header Authorization = 'Bearer token'
* header Content-Type = 'application/json'
And param page = 0
And param size = 10
```

### Métodos HTTP
```gherkin
When method get
When method post
When method put
When method patch
When method delete
When method head
```

### Request y Response
```gherkin
And request { nombre: 'Laptop' }
Then status 200
And match response.id == '#number'
```

---

## ✅ Validaciones Comunes

```gherkin
# Status
Then status 200
Then status 201
Then status 400
Then status 404

# Match exacto
And match response == { id: 1, nombre: 'Laptop' }

# Match estructura
And match response contains { id: '#number' }

# Match array
And match each response[*].precio > 0

# Assert
And assert response.id > 0
And assert response.nombre != null
And assert response.precio > 0 && response.cantidad >= 0
```

---

## 🔤 Validadores de Tipo

| Validador | Descripción | Ejemplo |
|-----------|-------------|---------|
| `#number` | Número | `precio: '#number'` |
| `#string` | Texto | `nombre: '#string'` |
| `#boolean` | True/False | `activo: '#boolean'` |
| `#array` | Array/Lista | `items: '#[]'` |
| `#object` | Objeto JSON | `meta: '#object'` |
| `#null` | Null/Vacío | `deleted: '#null'` |
| `#present` | No null | `id: '#present'` |
| `#ignore` | Ignorar | `timestamp: '#ignore'` |

---

## 💾 Variables

```gherkin
# Definir
* def producto = { nombre: 'Laptop' }
* def id = response.id
* def timestamp = karate.timestamp()

# Usar en strings
And request { nombre: '#(producto.nombre)' }

# Condicionales
* def status = response.ok ? 'EXITO' : 'ERROR'

# Funciones
* def suma = function(a, b) { return a + b }
```

---

## 🔄 Funciones Karate

```gherkin
# Arrays
* def nombres = karate.map(response, x => x.nombre)
* def caros = karate.filter(response, x => x.precio > 1000)
* def ordenados = karate.sort(precios)

# String
* def mayuscula = karate.toUpperCase('hola')
* def minuscula = karate.toLowerCase('HOLA')

# JSON
* def json = karate.pretty(data)
* def texto = karate.toString(objeto)

# Archivo
* def datos = read('data/productos.json')
* def escrito = karate.write(data, 'output.json')

# Otros
* karate.log('Log message')
* karate.timestamp()
```

---

## 📊 Estructura Feature

```gherkin
Feature: Descripción de la feature
  
  Background:
    # Se ejecuta antes de cada scenario
    * url 'http://localhost:8080'
    * def apiPath = '/api/productos'
  
  Scenario: Primer scenario
    # Given - Contexto
    # When - Acción
    # Then - Resultado
  
  Scenario: Segundo scenario
    # ...
```

---

## 🎯 Flujo Request-Response

```gherkin
# 1. SETUP
* def producto = { nombre: 'Laptop' }

# 2. REQUEST
Given path '/api/productos'
And request producto
When method post

# 3. VALIDACIÓN
Then status 201
And match response.id == '#number'

# 4. USAR RESPUESTA
* def productoId = response.id
```

---

## 🔢 Status HTTP Comunes

| Código | Significado | Uso |
|--------|------------|-----|
| 200 | OK | GET exitoso |
| 201 | Created | POST exitoso |
| 204 | No Content | DELETE exitoso |
| 400 | Bad Request | Datos inválidos |
| 401 | Unauthorized | Sin autenticación |
| 403 | Forbidden | Sin permiso |
| 404 | Not Found | Recurso no existe |
| 500 | Server Error | Error en servidor |

---

## 🏗️ Estructura Respuesta

```gherkin
# Respuesta simple
Then match response == 'string'

# Respuesta objeto
Then match response == { id: 1, nombre: 'Laptop' }

# Respuesta array
Then match response == '#[]'

# Respuesta anidada
Then match response == 
  """
  {
    id: 1,
    producto: {
      nombre: 'Laptop',
      precio: 999.99
    }
  }
  """
```

---

## 🎯 Assertions Útiles

```gherkin
# Igualdad
And assert response.id == 1

# Comparación
And assert response.precio > 100
And assert response.cantidad <= 50

# String
And assert response.nombre contains 'Laptop'
And assert response.email matches '.*@.*'

# Array
And assert response.length == 10
And assert response[0].id == 1

# Lógica
And assert response.activo == true && response.stock > 0
And assert response.tipo == 'premium' || response.tipo == 'standard'

# Negación
And assert response.error == null
And assert response.deleted != true
```

---

## 🔍 Debugging

```gherkin
# Print (salida en consola)
* print response
* print 'ID producto:', response.id
* print JSON.stringify(response, null, 2)

# Log (archivo karate.log)
* karate.log('Mensaje de log')
* karate.log('Response:', karate.pretty(response))

# Condicional
* if (responseStatus != 200) karate.log('Error:', response)

# Pretty print
* print karate.pretty(data)
```

---

## 📋 Template Scenario Outline

```gherkin
Scenario Outline: Crear productos
  Given path '/api/productos'
  And request { nombre: '<nombre>', precio: <precio> }
  When method post
  Then status 201
  And assert response.nombre == '<nombre>'
  
  Examples:
    | nombre  | precio |
    | Laptop  | 999.99 |
    | Monitor | 299.99 |
```

---

## 🏷️ Tags

```gherkin
@smokeTest
Scenario: Test rápido

@regression
Scenario: Test regresión

@skip
Scenario: Saltar test

# Ejecutar
mvn test -Dkarate.options="--tags @smokeTest"
mvn test -Dkarate.options="--tags @smokeTest,@regression"
```

---

## 🔐 Autenticación

```gherkin
# Bearer Token
* def token = 'abc123xyz'
* header Authorization = 'Bearer ' + token

# Basic Auth
* header Authorization = 'Basic base64encoded'

# Custom Headers
* header X-API-Key = 'key123'
* header X-Request-ID = karate.timestamp()
```

---

## 📦 Manejo de Errores

```gherkin
# Validar error
Then status 400
And match response.error == '#string'

# Try-Catch (Karate 1.3+)
* def resultado = call('request')
* if (resultado.responseStatus != 200)
    karate.log('Error:', resultado.response)

# Retry (Custom)
* configure retry = { count: 3, interval: 1000 }
```

---

## 🎓 Ejemplos Rápidos

### Crear Producto
```gherkin
* def producto = { nombre: 'Laptop', precio: 999.99, cantidad: 5 }
Given path '/api/productos'
And request producto
When method post
Then status 201
And match response.id == '#number'
```

### Listar con Filtro
```gherkin
Given path '/api/productos'
And param nombre = 'Laptop'
And param page = 0
And param size = 10
When method get
Then status 200
And match response == '#[]'
```

### Actualizar
```gherkin
Given path '/api/productos/1'
And request { nombre: 'Laptop Actualizada', precio: 1099.99 }
When method put
Then status 200
And match response.nombre == 'Laptop Actualizada'
```

### Eliminar y Verificar
```gherkin
Given path '/api/productos/1'
When method delete
Then status 204

Given path '/api/productos/1'
When method get
Then status 404
```

---

## 🛠️ Configuración

### karate-config.js
```javascript
function fn() {
  var config = {
    baseUrl: 'http://localhost:8080'
  };
  
  if (karate.env === 'staging') {
    config.baseUrl = 'http://staging.example.com';
  }
  
  karate.configure('connectTimeout', 5000);
  karate.configure('readTimeout', 5000);
  
  return config;
}
```

### pom.xml
```xml
<properties>
  <maven.compiler.source>21</maven.compiler.source>
  <maven.compiler.target>21</maven.compiler.target>
  <karate.version>1.3.1</karate.version>
</properties>
```

---

## 📚 Archivos Importantes

| Archivo | Propósito |
|---------|-----------|
| `inventario.feature` | Pruebas principales |
| `karate-config.js` | Configuración global |
| `TestRunner.java` | Ejecutor de tests |
| `data/productos.json` | Datos de prueba |
| `target/karate.log` | Logs de ejecución |

---

## 🔗 Enlaces Útiles

- [Karate Docs](https://karatelabs.github.io/karate/)
- [Karate Cheat Sheet](https://karatelabs.github.io/karate/syntax-reference.html)
- [Gherkin Reference](https://cucumber.io/docs/gherkin/reference/)
- [Maven Docs](https://maven.apache.org/)
- [Java 21 Features](https://www.oracle.com/java/technologies/java21.html)

---

**Creado**: Noviembre 13, 2025  
**Karate**: 1.3.1  
**Java**: 21 LTS  
**Maven**: 3.9.11

---

💡 **Tip**: Guarda este archivo como favorito para consultas rápidas
