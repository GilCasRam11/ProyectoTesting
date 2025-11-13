#!/bin/bash
# QUICK_START.sh - Script de inicio rápido para pruebas Karate

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     KARATE TEST SUITE - QUICK START                       ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo ""

# Función para mostrar menú
mostrar_menu() {
    echo "¿Qué deseas hacer?"
    echo ""
    echo "1) Ejecutar todos los tests (mvn clean test)"
    echo "2) Ejecutar un scenario específico"
    echo "3) Ejecutar en entorno staging"
    echo "4) Ver documentación (INDEX.md)"
    echo "5) Ver referencia rápida (CHEAT_SHEET.md)"
    echo "6) Compilar sin tests"
    echo "7) Ver logs en tiempo real"
    echo "8) Salir"
    echo ""
    read -p "Selecciona una opción (1-8): " opcion
}

# Función para ejecutar tests
ejecutar_tests() {
    echo ""
    echo "Ejecutando: mvn clean test"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    mvn clean test
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ ¡TESTS EXITOSOS!"
    else
        echo ""
        echo "❌ Hubo errores. Revisa los logs."
    fi
}

# Menú principal
while true; do
    mostrar_menu
    
    case $opcion in
        1)
            ejecutar_tests
            ;;
        2)
            echo ""
            read -p "¿Nombre del scenario? (ej: 'Crear nuevo'): " scenario
            echo "Ejecutando: mvn clean test -Dkarate.options=\"--name '$scenario'\""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            mvn clean test -Dkarate.options="--name '$scenario'"
            ;;
        3)
            echo ""
            echo "Ejecutando en entorno: staging"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            mvn clean test -Dkarate.env=staging
            ;;
        4)
            echo ""
            if command -v cat &> /dev/null; then
                cat INDEX.md | less
            else
                echo "Abre: INDEX.md"
            fi
            ;;
        5)
            echo ""
            if command -v cat &> /dev/null; then
                cat CHEAT_SHEET.md | less
            else
                echo "Abre: CHEAT_SHEET.md"
            fi
            ;;
        6)
            echo ""
            echo "Compilando sin tests..."
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            mvn clean compile -DskipTests
            ;;
        7)
            echo ""
            echo "Mostrando logs en tiempo real..."
            echo "Presiona CTRL+C para salir"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            tail -f target/karate.log
            ;;
        8)
            echo "¡Hasta luego!"
            exit 0
            ;;
        *)
            echo "Opción no válida"
            ;;
    esac
    
    echo ""
    read -p "Presiona Enter para continuar..."
    clear
done
