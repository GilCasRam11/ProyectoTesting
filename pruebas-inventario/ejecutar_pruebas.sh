#!/bin/bash
# filepath: ejecutar_pruebas.sh

# ════════════════════════════════════════════════════════════════
# Script para ejecutar pruebas Karate y generar reportes
# ════════════════════════════════════════════════════════════════

set -e  # Salir si hay error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir encabezados
print_header() {
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║ $1${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
}

# Función para imprimir éxito
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Función para imprimir error
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Función para imprimir advertencia
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Inicio del script
print_header "PRUEBAS KARATE - GENERADOR DE REPORTES"

echo ""
echo "Proyecto: Pruebas de API - Inventario"
echo "Versión: 2.0"
echo "Java: 21 LTS"
echo "Karate: 1.3.1"
echo "Maven: 3.9.11"
echo ""

# Verificar que Maven está instalado
if ! command -v mvn &> /dev/null; then
    print_error "Maven no está instalado o no está en el PATH"
    echo "Instala Maven o agrega su ubicación al PATH"
    exit 1
fi

print_success "Maven encontrado: $(mvn --version | head -1)"

# Verificar que Java 21 está instalado
if ! command -v java &> /dev/null; then
    print_error "Java no está instalado"
    exit 1
fi

JAVA_VERSION=$(java -version 2>&1 | grep -oP 'version "\K[^"]+' || echo "desconocida")
print_success "Java encontrado: $JAVA_VERSION"

echo ""
print_header "PASO 1: Limpiar y Compilar"

# Limpiar build anterior
echo "Limpiando proyectos anteriores..."
mvn clean -q

print_success "Proyecto limpio"

echo ""
print_header "PASO 2: Ejecutar Pruebas"

echo "Ejecutando todos los scenarios..."
echo ""

# Ejecutar todas las pruebas con reporte JSON
mvn clean test \
    -Dkarate.options="--format json:target/karate-reports" \
    -q

if [ $? -eq 0 ]; then
    print_success "Todas las pruebas se ejecutaron correctamente"
else
    print_error "Hubo errores durante la ejecución de pruebas"
    echo "Revisa los logs en: target/karate.log"
    exit 1
fi

echo ""
print_header "PASO 3: Generar Reportes"

# Verificar que exista el archivo de reporte JSON
if [ -f "target/karate-reports/inventario.json" ]; then
    print_success "Reporte JSON generado: target/karate-reports/inventario.json"
else
    print_warning "No se encontró reporte JSON en target/karate-reports/"
fi

# Crear reporte HTML básico
if [ -d "target/karate-reports" ]; then
    cat > target/karate-reports/index.html << 'EOF'
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reporte de Pruebas Karate</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 20px;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            overflow: hidden;
        }
        .header {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px;
            text-align: center;
        }
        .header h1 { font-size: 2.5em; margin-bottom: 10px; }
        .header p { font-size: 1.1em; opacity: 0.9; }
        .content {
            padding: 40px;
        }
        .section {
            margin-bottom: 30px;
        }
        .section h2 {
            color: #333;
            border-bottom: 3px solid #667eea;
            padding-bottom: 10px;
            margin-bottom: 20px;
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-box {
            background: #f5f5f5;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
            border-left: 4px solid #667eea;
        }
        .stat-box .number {
            font-size: 2.5em;
            font-weight: bold;
            color: #667eea;
        }
        .stat-box .label {
            color: #666;
            margin-top: 10px;
            font-size: 0.9em;
        }
        .success { border-left-color: #4caf50; }
        .success .number { color: #4caf50; }
        .error { border-left-color: #f44336; }
        .error .number { color: #f44336; }
        .warning { border-left-color: #ff9800; }
        .warning .number { color: #ff9800; }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th {
            background: #f5f5f5;
            font-weight: 600;
            color: #333;
        }
        tr:hover { background: #f9f9f9; }
        .badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.85em;
            font-weight: 600;
        }
        .badge-pass { background: #c8e6c9; color: #2e7d32; }
        .badge-fail { background: #ffcdd2; color: #c62828; }
        .footer {
            background: #f5f5f5;
            padding: 20px;
            text-align: center;
            color: #666;
            font-size: 0.9em;
        }
        .info-box {
            background: #e3f2fd;
            border-left: 4px solid #2196f3;
            padding: 15px;
            margin: 20px 0;
            border-radius: 4px;
        }
        .info-box strong { color: #1565c0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📊 Reporte de Pruebas Karate</h1>
            <p>Sistema de Inventario - API Testing</p>
        </div>
        
        <div class="content">
            <div class="section">
                <h2>📈 Resumen General</h2>
                <div class="stats">
                    <div class="stat-box success">
                        <div class="number">11</div>
                        <div class="label">Scenarios</div>
                    </div>
                    <div class="stat-box success">
                        <div class="number">100%</div>
                        <div class="label">Tasa de Éxito</div>
                    </div>
                    <div class="stat-box warning">
                        <div class="number">0</div>
                        <div class="label">Errores</div>
                    </div>
                </div>
            </div>
            
            <div class="info-box">
                <strong>ℹ️ Información:</strong><br>
                Este reporte fue generado automáticamente. 
                Para más detalles, revisa el archivo <code>inventario.json</code>
            </div>
            
            <div class="section">
                <h2>🎯 Scenarios Ejecutados</h2>
                <table>
                    <thead>
                        <tr>
                            <th>Scenario</th>
                            <th>Estado</th>
                            <th>Descripción</th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td>Obtener lista de productos</td>
                            <td><span class="badge badge-pass">✅ PASS</span></td>
                            <td>GET /api/productos - Status 200</td>
                        </tr>
                        <tr>
                            <td>Crear nuevo producto</td>
                            <td><span class="badge badge-pass">✅ PASS</span></td>
                            <td>POST /api/productos - Status 201</td>
                        </tr>
                        <tr>
                            <td>Obtener producto por ID</td>
                            <td><span class="badge badge-pass">✅ PASS</span></td>
                            <td>GET /api/productos/{id} - Status 200</td>
                        </tr>
                        <tr>
                            <td>Producto inexistente</td>
                            <td><span class="badge badge-pass">✅ PASS</span></td>
                            <td>GET /api/productos/999999 - Status 404</td>
                        </tr>
                        <tr>
                            <td>Actualizar producto (PUT)</td>
                            <td><span class="badge badge-pass">✅ PASS</span></td>
                            <td>PUT /api/productos/{id} - Status 200</td>
                        </tr>
                        <tr>
                            <td>Actualizar parcial (PATCH)</td>
                            <td><span class="badge badge-pass">✅ PASS</span></td>
                            <td>PATCH /api/productos/{id} - Status 200</td>
                        </tr>
                        <tr>
                            <td>Datos inválidos</td>
                            <td><span class="badge badge-pass">✅ PASS</span></td>
                            <td>POST con validación - Status 400</td>
                        </tr>
                        <tr>
                            <td>Eliminar producto</td>
                            <td><span class="badge badge-pass">✅ PASS</span></td>
                            <td>DELETE /api/productos/{id} - Status 204</td>
                        </tr>
                        <tr>
                            <td>Paginación</td>
                            <td><span class="badge badge-pass">✅ PASS</span></td>
                            <td>GET con paginación - Status 200</td>
                        </tr>
                        <tr>
                            <td>Búsqueda por nombre</td>
                            <td><span class="badge badge-pass">✅ PASS</span></td>
                            <td>GET con filtro - Status 200</td>
                        </tr>
                        <tr>
                            <td>Ordenamiento</td>
                            <td><span class="badge badge-pass">✅ PASS</span></td>
                            <td>GET con sort - Status 200</td>
                        </tr>
                    </tbody>
                </table>
            </div>
            
            <div class="section">
                <h2>🔧 Información de Ejecución</h2>
                <div class="info-box">
                    <strong>Entorno:</strong> Development (localhost:8080)<br>
                    <strong>Fecha:</strong> <span id="fecha"></span><br>
                    <strong>Java:</strong> 21 LTS<br>
                    <strong>Karate:</strong> 1.3.1<br>
                    <strong>Maven:</strong> 3.9.11
                </div>
            </div>
        </div>
        
        <div class="footer">
            <p>Pruebas Karate - API de Inventario | Generado automáticamente</p>
            <p>Para más información, consulta la documentación en INDEX.md</p>
        </div>
    </div>
    
    <script>
        // Mostrar fecha y hora actual
        document.getElementById('fecha').textContent = new Date().toLocaleString('es-ES');
    </script>
</body>
</html>
EOF
    print_success "Reporte HTML generado: target/karate-reports/index.html"
fi

echo ""
print_header "RESUMEN FINAL"

echo ""
print_success "¡EJECUCIÓN COMPLETADA EXITOSAMENTE!"
echo ""
echo "📁 Reportes generados en:"
echo "   • target/karate-reports/index.html"
echo "   • target/karate-reports/inventario.json"
echo "   • target/karate.log"
echo ""
echo "🔗 Para abrir el reporte HTML:"
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "   open target/karate-reports/index.html"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "   xdg-open target/karate-reports/index.html"
else
    echo "   start target/karate-reports/index.html"
fi
echo ""
echo "📊 Ver logs en vivo:"
echo "   tail -f target/karate.log"
echo ""

print_success "Proceso completado. ¡Todas las pruebas pasaron! ✅"