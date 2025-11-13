Feature: Pruebas de API de Inventario

  # ========================================
  # CONFIGURACIÓN BASE
  # ========================================
  Background:
    # URL base de la API
    * url 'http://localhost:8080'
    
    # Headers comunes para todas las peticiones
    * header Content-Type = 'application/json'
    * header Accept = 'application/json'
    
    # Variables compartidas
    * def apiBasePath = '/api/productos'
    * def productoCreado = null
    * def productoId = 1

  # ========================================
  # SCENARIO 1: Obtener lista de productos
  # ========================================
  Scenario: Obtener lista de productos - GET /api/productos
    Given path apiBasePath
    When method get
    Then status 200
    
    # Validar que la respuesta es un array
    And match response == '#[]'
    
    # Validar estructura de cada producto en la lista
    And match each response contains 
      """
      {
        id: '#number',
        nombre: '#string',
        precio: '#number',
        cantidad: '#number'
      }
      """
    
    # Validar que existen productos
    And assert response.length > 0

  # ========================================
  # SCENARIO 1B: Validar esquema de producto
  # ========================================
  Scenario: Validar esquema de respuesta de producto
    Given path apiBasePath + '/1'
    When method get
    Then status 200
    
    # Validar esquema completo: id es número, nombre es string, cantidad es número entero
    And match response ==
      """
      {
        id: '#number',
        nombre: '#string',
        cantidad: '#? parseInt(#) == #',
        descripcion: '#string',
        precio: '#number'
      }
      """
    
    # Validaciones adicionales de tipo de dato
    And assert response.id % 1 === 0
    And assert typeof response.nombre === 'string'
    And assert response.cantidad % 1 === 0
    And assert response.cantidad >= 0

  # ========================================
  # SCENARIO 2: Crear nuevo producto
  # ========================================
  Scenario: Crear nuevo producto - POST /api/productos
    # Preparar el payload del request
    * def nuevoProducto =
      """
      {
        nombre: 'Laptop Dell XPS 13',
        precio: 1299.99,
        cantidad: 10,
        descripcion: 'Laptop de alta gama para profesionales'
      }
      """
    
    Given path apiBasePath
    And request nuevoProducto
    When method post
    Then status 201
    
    # Validar estructura exacta de la respuesta
    And match response ==
      """
      {
        id: '#number',
        nombre: 'Laptop Dell XPS 13',
        precio: 1299.99,
        cantidad: 10,
        descripcion: '#string'
      }
      """
    
    # Guardar el ID del producto creado para uso posterior
    And def productoId = response.id
    
    # Validaciones adicionales
    And assert response.id > 0
    And assert response.nombre != null
    And assert response.precio > 0
    And assert response.cantidad >= 0
    
    # Guardar respuesta para próximos scenarios
    * def productoCreado = response

  # ========================================
  # SCENARIO 3: Obtener producto por ID
  # ========================================
  Scenario: Obtener producto por ID - GET /api/productos/{id}
    Given path apiBasePath + '/1'
    When method get
    Then status 200
    
    # Validar estructura exacta del producto
    And match response ==
      """
      {
        id: '#number',
        nombre: '#string',
        precio: '#number',
        cantidad: '#number',
        descripcion: '#string'
      }
      """
    
    # Validar valores específicos
    And assert response.id == 1
    And assert response.precio > 0
    And assert response.cantidad >= 0

  # ========================================
  # SCENARIO 4: Obtener producto inexistente
  # ========================================
  Scenario: Obtener producto inexistente - GET /api/productos/{id} - 404
    Given path apiBasePath + '/99999'
    When method get
    Then status 404
    
    # Validar estructura exacta del error
    And match response ==
      """
      {
        error: '#string',
        mensaje: '#string'
      }
      """

  # ========================================
  # SCENARIO 5: Actualizar producto
  # ========================================
  Scenario: Actualizar producto - PUT /api/productos/{id}
    # Preparar datos de actualización
    * def actualizacionProducto =
      """
      {
        nombre: 'Laptop Dell XPS 15',
        precio: 1499.99,
        cantidad: 8
      }
      """
    
    Given path apiBasePath + '/1'
    And request actualizacionProducto
    When method put
    Then status 200
    
    # Validar estructura exacta después de la actualización
    And match response ==
      """
      {
        id: 1,
        nombre: 'Laptop Dell XPS 15',
        precio: 1499.99,
        cantidad: 8,
        descripcion: '#string'
      }
      """
    
    # Validaciones de coherencia
    And assert response.nombre == 'Laptop Dell XPS 15'
    And assert response.precio == 1499.99
    And assert response.cantidad == 8

  # ========================================
  # SCENARIO 6: Actualización parcial
  # ========================================
  Scenario: Actualización parcial de producto - PATCH /api/productos/{id}
    # Solo actualizar el precio
    * def actualizacionParcial =
      """
      {
        precio: 1199.99
      }
      """
    
    Given path apiBasePath + '/1'
    And request actualizacionParcial
    When method patch
    Then status 200
    
    # Validar estructura exacta con el precio actualizado
    And match response ==
      """
      {
        id: 1,
        nombre: '#string',
        precio: 1199.99,
        cantidad: '#number',
        descripcion: '#string'
      }
      """
    
    # Validar que solo el precio cambió
    And assert response.precio == 1199.99

  # ========================================
  # SCENARIO 7: Validación de entrada - Request inválido
  # ========================================
  Scenario: Crear producto con datos inválidos - POST /api/productos
    * def productoInvalido =
      """
      {
        nombre: '',
        precio: -50,
        cantidad: -5
      }
      """
    
    Given path apiBasePath
    And request productoInvalido
    When method post
    Then status 400
    
    # Validar estructura exacta del error de validación
    And match response ==
      """
      {
        error: '#string'
      }
      """

  # ========================================
  # SCENARIO 8: Eliminar producto
  # ========================================
  Scenario: Eliminar producto - DELETE /api/productos/{id}
    Given path apiBasePath + '/1'
    When method delete
    Then status 204
    
    # Verificar que se eliminó
    Given path apiBasePath + '/1'
    When method get
    Then status 404
    
    # Validar estructura de error de no encontrado
    And match response ==
      """
      {
        error: '#string',
        mensaje: '#string'
      }
      """

  # ========================================
  # SCENARIO 9: Listar con paginación
  # ========================================
  Scenario: Listar productos con paginación - GET /api/productos?page=0&size=10
    Given path apiBasePath
    And param page = 0
    And param size = 10
    When method get
    Then status 200
    
    # Validar estructura exacta de respuesta paginada
    And match response ==
      """
      {
        content: '#[]',
        totalElements: '#number',
        totalPages: '#number',
        currentPage: '#number',
        pageSize: '#number'
      }
      """
    
    # Validar que cada elemento en content tiene estructura correcta
    And match each response.content ==
      """
      {
        id: '#number',
        nombre: '#string',
        precio: '#number',
        cantidad: '#number',
        descripcion: '#string'
      }
      """

  # ========================================
  # SCENARIO 10: Buscar productos por nombre
  # ========================================
  Scenario: Buscar productos por nombre - GET /api/productos?nombre=Laptop
    Given path apiBasePath
    And param nombre = 'Laptop'
    When method get
    Then status 200
    
    # Validar que la respuesta es un array
    And match response == '#[]'
    
    # Validar estructura exacta de cada resultado
    And match each response ==
      """
      {
        id: '#number',
        nombre: '#string? _ contains "Laptop"',
        precio: '#number',
        cantidad: '#number',
        descripcion: '#string'
      }
      """

  # ========================================
  # SCENARIO 11: Orddenamiento de resultados
  # ========================================
  Scenario: Listar productos ordenados por precio descendente
    Given path apiBasePath
    And param sortBy = 'precio'
    And param order = 'desc'
    When method get
    Then status 200
    
    # Validar que es un array
    And match response == '#[]'
    
    # Validar estructura exacta de cada producto
    And match each response ==
      """
      {
        id: '#number',
        nombre: '#string',
        precio: '#number',
        cantidad: '#number',
        descripcion: '#string'
      }
      """
    
    # Verificar que están ordenados correctamente (precios descendentes)
    * def precios = get response[*].precio
    * def preciosOrdenados = karate.sort(precios, true)
    And assert precios == preciosOrdenados
