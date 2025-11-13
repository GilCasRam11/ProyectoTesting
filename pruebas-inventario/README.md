# Pruebas Inventario - API Testing con Karate

## Descripción

Proyecto de pruebas de API para un sistema de inventario utilizando el framework **Karate** en Maven. Karate es un framework basado en Gherkin que permite escribir pruebas de API de forma simple y legible.

## Requisitos

- **Java 11** o superior
- **Maven 3.6+**
- Una API REST ejecutándose (por defecto en `http://localhost:8080/api`)

## Estructura del Proyecto

```
pruebas-inventario/
├── src/
│   └── test/
│       ├── java/
│       │   └── com/inventario/
│       │       └── TestRunner.java          # Clase ejecutora de pruebas
│       └── resources/
│           ├── features/
│           │   └── inventario.feature       # Definiciones de pruebas
│           └── logback-test.xml             # Configuración de logs
├── pom.xml                                   # Configuración de Maven
└── README.md                                 # Este archivo
```

## Instalación

1. Clonar o navegar al proyecto:
```bash
cd pruebas-inventario
```

2. Descargar dependencias:
```bash
mvn clean install
```

## Ejecución de Pruebas

### Ejecutar todas las pruebas
```bash
mvn test
```

### Ejecutar una prueba específica
```bash
mvn test -Dtest=TestRunner
```

### Ejecutar con output detallado
```bash
mvn test -X
```

## Estructura de Archivos Feature

Los archivos `.feature` utilizan la sintaxis **Gherkin** y se encuentran en:
- `src/test/resources/features/`

### Ejemplo de Scenario en Karate

```gherkin
Feature: Pruebas de API de Inventario

  Background:
    * url 'http://localhost:8080/api'

  Scenario: Obtener lista de productos
    Given path '/productos'
    When method get
    Then status 200
```

## Conceptos Clave de Karate

- **url**: Define la URL base de la API
- **path**: Define el endpoint
- **method**: Especifica el método HTTP (get, post, put, delete, etc.)
- **request**: Define el body de la solicitud
- **status**: Valida el código de respuesta HTTP
- **match**: Realiza aserciones sobre la respuesta

## Configuración de la Base URL

Para cambiar la URL de la API, edita el archivo `inventario.feature` en la sección `Background`:

```gherkin
Background:
  * url 'http://tu-api:puerto/ruta'
```

## Dependencias Principales

- **Karate JUnit4**: Framework de pruebas de API
- **JUnit 4**: Framework de testing
- **RestAssured**: Librería HTTP
- **Logback**: Framework de logging

## Tips y Mejores Prácticas

1. **Organización**: Crea archivos `.feature` separados por funcionalidad
2. **Datos de prueba**: Usa `karate-config.js` para gestionar datos globales
3. **Variables**: Define variables reutilizables en los features
4. **Datos compartidos**: Usa `Background` para setup común
5. **Validación**: Siempre valida status codes y estructura de response

## Próximos Pasos

1. Configura la URL correcta de tu API en `inventario.feature`
2. Adapta los scenarios a los endpoints reales
3. Añade más archivos `.feature` para cubrir toda tu API
4. Integra el proyecto en tu pipeline de CI/CD

## Recursos

- [Documentación oficial de Karate](https://github.com/karatelabs/karate)
- [Gherkin Syntax](https://cucumber.io/docs/gherkin/)
- [REST Assured Documentation](https://rest-assured.io/)

## Licencia

Proyecto de ejemplo para pruebas de API con Karate.
