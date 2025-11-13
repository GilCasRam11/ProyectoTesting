# 🚀 Pruebas de API de Inventario - Guía de Ejecución

## 📋 Resumen

Este proyecto contiene pruebas automatizadas de API REST para un sistema de gestión de inventario utilizando:
- **Framework**: Karate 1.3.1
- **Java**: 21 LTS
- **Build Tool**: Maven 3.9.11
- **Testing**: JUnit 4

---

## 🛠️ Requisitos Previos

### Instalación Manual

```bash
# Verificar Java 21
java -version

# Verificar Maven
mvn --version

# Verificar disponibilidad de API
curl http://localhost:8080/api/productos
```

### Usando Homebrew (macOS)

```bash
# Instalar Java 21 LTS
brew install openjdk@21

# Instalar Maven
brew install maven

# Link opcional para usar java directamente
sudo ln -sfn /opt/homebrew/opt/openjdk@21/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-21.jdk
```

---

## 📁 Estructura del Proyecto

```
pruebas-inventario/
├── pom.xml                          # Configuración Maven
├── src/
│   ├── test/
│   │   ├── java/
│   │   │   └── com/inventario/
│   │   │       └── TestRunner.java  # Ejecutor de pruebas
│   │   ├── resources/
│   │   │   ├── features/
│   │   │   │   └── inventario.feature    # Pruebas Karate
│   │   │   ├── data/
│   │   │   │   └── productos.json       # Datos de prueba
│   │   │   └── logback-test.xml         # Configuración de logs
│   │   └── java/
│   │       └── karate-config.js         # Configuración global
│   └── target/                      # Compilados (generado)
└── README.md
```

---

## 🧪 Ejecución de Pruebas

### 1. Ejecutar Todas las Pruebas

```bash
cd pruebas-inventario

# Ejecución básica (entorno dev)
mvn clean test

# Con salida detallada
mvn clean test -X

# Saltando tests
mvn clean install -DskipTests
```

### 2. Ejecutar en Entorno Específico

```bash
# Entorno de desarrollo (default)
mvn clean test -Dkarate.env=dev

# Entorno de staging
mvn clean test -Dkarate.env=staging

# Entorno de producción
mvn clean test -Dkarate.env=prod
```

### 3. Ejecutar Scenarios Específicos

```bash
# Por nombre de scenario
mvn clean test -Dkarate.options="--name 'Crear nuevo producto'"

# Por tags (@tag)
mvn clean test -Dkarate.options="--tags @smokeTest"

# Múltiples criterios
mvn clean test -Dkarate.options="--name 'Crear' --tags @regression"
```

### 4. Generar Reportes

```bash
# Reporte JSON
mvn clean test -Dkarate.options="--format json:target/karate-reports"

# Reporte HTML (requiere configuración adicional)
mvn clean test -Dkarate.options="--format html:target/karate-reports"

# Combinar con salida en consola
mvn clean test -Dkarate.options="--format json:target/karate-reports" | tee test-output.log
```

---

## 🔍 Descripción de Scenarios

### 1️⃣ Obtener Lista de Productos
```gherkin
Scenario: Obtener lista de productos - GET /api/productos
- Validación: Status 200
- Estructura: Array de productos
- Campos: id, nombre, precio, cantidad
```

**Ejecutar:**
```bash
mvn clean test -Dkarate.options="--name 'Obtener lista de productos'"
```

---

### 2️⃣ Crear Nuevo Producto
```gherkin
Scenario: Crear nuevo producto - POST /api/productos
- Validación: Status 201
- Request: { nombre, precio, cantidad, descripcion }
- Response: Producto creado con ID asignado
```

**Ejecutar:**
```bash
mvn clean test -Dkarate.options="--name 'Crear nuevo producto'"
```

---

### 3️⃣ Obtener Producto por ID
```gherkin
Scenario: Obtener producto por ID - GET /api/productos/{id}
- Validación: Status 200
- ID: 1
- Response: Estructura completa del producto
```

**Ejecutar:**
```bash
mvn clean test -Dkarate.options="--name 'Obtener producto por ID'"
```

---

### 4️⃣ Producto Inexistente
```gherkin
Scenario: Obtener producto inexistente - GET /api/productos/{id} - 404
- Validación: Status 404
- Response: Mensaje de error estructurado
```

**Ejecutar:**
```bash
mvn clean test -Dkarate.options="--name 'Obtener producto inexistente'"
```

---

### 5️⃣ Actualizar Producto (PUT)
```gherkin
Scenario: Actualizar producto - PUT /api/productos/{id}
- Validación: Status 200
- Actualiza: nombre, precio, cantidad
- Verifica: Cambios reflejados en respuesta
```

**Ejecutar:**
```bash
mvn clean test -Dkarate.options="--name 'Actualizar producto'"
```

---

### 6️⃣ Actualización Parcial (PATCH)
```gherkin
Scenario: Actualización parcial - PATCH /api/productos/{id}
- Validación: Status 200
- Actualiza: Solo campos específicos (ej: precio)
- Preserva: Otros campos sin cambios
```

**Ejecutar:**
```bash
mvn clean test -Dkarate.options="--name 'Actualización parcial'"
```

---

### 7️⃣ Validación de Entrada
```gherkin
Scenario: Crear producto con datos inválidos - POST /api/productos
- Validación: Status 400
- Casos:
  - nombre vacío
  - precio negativo
  - cantidad negativa
- Response: Mensaje de error descriptivo
```

**Ejecutar:**
```bash
mvn clean test -Dkarate.options="--name 'Crear producto con datos inválidos'"
```

---

### 8️⃣ Eliminar Producto
```gherkin
Scenario: Eliminar producto - DELETE /api/productos/{id}
- Validación: Status 204
- Verificación: GET posterior retorna 404
```

**Ejecutar:**
```bash
mvn clean test -Dkarate.options="--name 'Eliminar producto'"
```

---

### 9️⃣ Paginación
```gherkin
Scenario: Listar productos con paginación
- Query params: page=0, size=10
- Validación: Status 200
- Response: { content, totalElements, totalPages, currentPage, pageSize }
```

**Ejecutar:**
```bash
mvn clean test -Dkarate.options="--name 'paginación'"
```

---

### 🔟 Búsqueda por Nombre
```gherkin
Scenario: Buscar productos por nombre
- Query param: nombre=Laptop
- Validación: Todos los resultados contienen "Laptop"
```

**Ejecutar:**
```bash
mvn clean test -Dkarate.options="--name 'Buscar productos'"
```

---

### 1️⃣1️⃣ Ordenamiento
```gherkin
Scenario: Listar productos ordenados por precio descendente
- Query params: sortBy=precio, order=desc
- Validación: Precios en orden descendente
```

**Ejecutar:**
```bash
mvn clean test -Dkarate.options="--name 'Ordenamiento'"
```

---

## 📊 Interpretación de Resultados

### ✅ Test Exitoso
```
[INFO] Tests run: 11, Failures: 0, Errors: 0, Skipped: 0
[INFO] BUILD SUCCESS
```

### ❌ Test Fallido
```
[ERROR] FAILURE - actual value: 'error' but expected 'success'
[ERROR] Status code was 400 but expected 201
[ERROR] BUILD FAILURE
```

### 📝 Ver Logs Detallados
```bash
# Logs en target/karate.log
cat target/karate.log | grep -i "error"

# Salida de Maven
mvn clean test -q  # Quiet mode (menos output)
mvn clean test -X  # Debug mode (más output)
```

---

## 🔧 Troubleshooting

### ❌ Error: Connection refused
```
java.net.ConnectException: Connection refused
```

**Solución:**
```bash
# Verificar que el servidor de API está corriendo
curl http://localhost:8080/api/productos

# Iniciar servidor (si aplica)
# npm start (para Node.js)
# java -jar app.jar (para Java)
```

---

### ❌ Error: Java version
```
Unsupported major.minor version 65.0
```

**Solución:**
```bash
# Verificar Java version
java -version

# Debe ser Java 21
# Configurar JAVA_HOME si es necesario
export JAVA_HOME=$(/usr/libexec/java_home -v 21)
```

---

### ❌ Error: Maven not found
```
mvn: command not found
```

**Solución:**
```bash
# Instalar Maven
brew install maven

# O usar wrapper
./mvnw clean test
```

---

### ❌ Error: Dependency not found
```
Could not find artifact com.intuit.karate:karate-junit4:jar:1.3.1
```

**Solución:**
```bash
# Limpiar caché de Maven
mvn clean
rm -rf ~/.m2/repository

# Reintentar
mvn clean test -U  # -U = Force update
```

---

## 📈 Mejora Continua

### Agregar Nuevas Pruebas
1. Editar `src/test/resources/features/inventario.feature`
2. Agregar nuevo `Scenario` o `Scenario Outline`
3. Ejecutar: `mvn clean test`

### Agregar Datos de Prueba
1. Editar `src/test/resources/data/productos.json`
2. Referenciar en feature: `* def datos = read('data/productos.json')`

### Cambiar Configuración
1. Editar `src/test/java/karate-config.js`
2. Cambiar `baseUrl`, timeouts, headers, etc.

---

## 🔗 Enlaces Útiles

- [Documentación oficial de Karate](https://karatelabs.github.io/karate/)
- [Guía de referencia Gherkin](https://cucumber.io/docs/gherkin/reference/)
- [Maven Documentation](https://maven.apache.org/guides/)
- [Java 21 LTS Features](https://www.oracle.com/java/technologies/java21.html)

---

## 📞 Contacto y Soporte

Para problemas o preguntas:
1. Revisar los logs en `target/karate.log`
2. Ejecutar con flag `-X` para debug
3. Verificar endpoint en `karate-config.js`
4. Consultar la documentación oficial de Karate

---

**Última actualización**: Noviembre 13, 2025  
**Versión Java**: 21 LTS  
**Versión Karate**: 1.3.1  
**Build Tool**: Maven 3.9.11
