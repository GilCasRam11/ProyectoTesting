// karate-config.js
// Archivo de configuración global para Karate

function fn() {
  // Configuración por entorno
  var env = karate.env;
  karate.log('Ejecutando en entorno: ' + env);

  var config = {
    baseUrl: 'http://localhost:8080'
  };

  if (env === 'dev') {
    config.baseUrl = 'http://localhost:8080';
  } else if (env === 'staging') {
    config.baseUrl = 'http://staging-api.example.com';
  } else if (env === 'prod') {
    config.baseUrl = 'https://api.example.com';
  }

  // Variables globales
  karate.configure('connectTimeout', 5000);
  karate.configure('readTimeout', 5000);

  // Headers globales
  karate.configure('logPrettyRequest', true);
  karate.configure('logPrettyResponse', true);

  return config;
}
