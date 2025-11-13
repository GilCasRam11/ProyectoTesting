package com.inventario;

import org.junit.runner.RunWith;

import com.intuit.karate.junit4.Karate;

/**
 * TestRunner - Ejecutor principal de pruebas Karate
 * 
 * Esta clase ejecuta todos los archivos .feature en la carpeta:
 * src/test/resources/features/
 * 
 * Cómo ejecutar:
 * 
 * 1. Todas las pruebas (dev):
 *    mvn test
 * 
 * 2. En entorno específico:
 *    mvn test -Dkarate.env=staging
 *    mvn test -Dkarate.env=prod
 * 
 * 3. Una feature específica:
 *    mvn test -Dkarate.options="--tags @smokeTest"
 * 
 * 4. Con reporte detallado:
 *    mvn test -Dkarate.options="--format json:target/karate-reports"
 * 
 * Configuración:
 * - El archivo karate-config.js controla la URL base y variables globales
 * - Los timeouts están configurados a 5 segundos (editable en config.js)
 * - Logs de request/response están habilitados
 */
@RunWith(Karate.class)
public class TestRunner {
    // Esta clase ejecuta automáticamente todos los archivos .feature
    // ubicados en: src/test/resources/features/
}
