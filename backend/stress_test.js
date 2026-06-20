const http = require('http');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Configuración de la prueba
const TARGET_URL = process.argv[2] || 'http://localhost:3000';
const CONCURRENT_USERS = parseInt(process.argv[3]) || 50;
const REQUESTS_PER_USER = parseInt(process.argv[4]) || 5;

console.log(`====================================================`);
console.log(`  QHATU FERIAS - SIMULADOR DE PRUEBAS DE ESTRÉS`);
console.log(`====================================================`);
console.log(`URL Objetivo:     ${TARGET_URL}`);
console.log(`Usuarios Simultáneos: ${CONCURRENT_USERS}`);
console.log(`Peticiones/Usuario:   ${REQUESTS_PER_USER}`);
console.log(`Total Peticiones:     ${CONCURRENT_USERS * REQUESTS_PER_USER}`);
console.log(`====================================================\n`);

// Helper para hacer peticiones HTTP nativas
function makeRequest(url, method, headers = {}, body = null) {
  return new Promise((resolve) => {
    const startTime = process.hrtime();
    const parsedUrl = new URL(url);
    
    const options = {
      hostname: parsedUrl.hostname,
      port: parsedUrl.port || (parsedUrl.protocol === 'https:' ? 443 : 80),
      path: parsedUrl.pathname + parsedUrl.search,
      method: method,
      headers: {
        'Content-Type': 'application/json',
        ...headers
      }
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => { data += chunk; });
      res.on('end', () => {
        const diff = process.hrtime(startTime);
        const durationMs = (diff[0] * 1000) + (diff[1] / 1000000);
        resolve({
          statusCode: res.statusCode,
          durationMs,
          success: res.statusCode >= 200 && res.statusCode < 300,
          data: data
        });
      });
    });

    req.on('error', (err) => {
      const diff = process.hrtime(startTime);
      const durationMs = (diff[0] * 1000) + (diff[1] / 1000000);
      resolve({
        statusCode: 500,
        durationMs,
        success: false,
        error: err.message
      });
    });

    if (body) {
      req.write(JSON.stringify(body));
    }
    req.end();
  });
}

async function runTest() {
  // Obtener IDs reales desde la base de datos antes de iniciar
  console.log("Cargando IDs de prueba desde base de datos...");
  const stand = await prisma.stand.findFirst({
    where: { feriaId: "99d225b5-2611-49b8-b074-7b450fc32ef0" }
  });
  const criterion = await prisma.criterion.findFirst({
    where: { area: { feriaId: "99d225b5-2611-49b8-b074-7b450fc32ef0" } }
  });
  
  const realStandId = stand ? stand.id : "";
  const realCriterionId = criterion ? criterion.id : "";
  
  if (!realStandId || !realCriterionId) {
    console.log("❌ Error: No se encontraron Stands o Criterios válidos en la base de datos.");
    await prisma.$disconnect();
    return;
  }

  console.log(`-> ID Stand Real:      ${realStandId}`);
  console.log(`-> ID Criterio Real:   ${realCriterionId}\n`);
  
  const globalStartTime = Date.now();
  
  // 1. Simular login inicial masivo
  console.log(`[Paso 1] Simulando inicio de sesión masivo (${CONCURRENT_USERS} usuarios concurrentes)...`);
  const loginPromises = [];
  for (let i = 0; i < CONCURRENT_USERS; i++) {
    loginPromises.push(
      makeRequest(`${TARGET_URL}/api/auth/login`, 'POST', {}, {
        username: 'jurado1',
        password: 'pass123'
      })
    );
  }

  const loginResults = await Promise.all(loginPromises);
  const successLogins = loginResults.filter(r => r.success);
  console.log(`-> Logins exitosos: ${successLogins.length}/${CONCURRENT_USERS}`);
  
  let token = '';
  if (successLogins.length > 0) {
    try {
      const body = JSON.parse(successLogins[0].data);
      token = body.token;
    } catch(e) {}
  }

  if (!token) {
    console.log(`❌ Error: No se pudo iniciar sesión. Abortando prueba.`);
    await prisma.$disconnect();
    return;
  }

  // 2. Simular descargas de Rúbricas y Asignaciones
  console.log(`\n[Paso 2] Simulando descarga de rúbricas y asignaciones (${CONCURRENT_USERS} jurados consultando)...`);
  const headers = { 'Authorization': `Bearer ${token}` };
  const queryPromises = [];
  
  for (let i = 0; i < CONCURRENT_USERS; i++) {
    queryPromises.push(makeRequest(`${TARGET_URL}/api/evaluation/assignments`, 'GET', headers));
    queryPromises.push(makeRequest(`${TARGET_URL}/api/evaluation/stands`, 'GET', headers));
  }

  const queryResults = await Promise.all(queryPromises);
  const successQueries = queryResults.filter(r => r.success);
  console.log(`-> Descargas exitosas: ${successQueries.length}/${queryResults.length}`);

  // 3. Simular envíos masivos de notas
  console.log(`\n[Paso 3] Simulando carga y sincronización de notas en lote (${CONCURRENT_USERS * REQUESTS_PER_USER} transacciones)...`);
  const syncPromises = [];

  for (let i = 0; i < CONCURRENT_USERS; i++) {
    for (let r = 0; r < REQUESTS_PER_USER; r++) {
      const payload = {
        standScores: [
          {
            standId: realStandId,
            criterionId: realCriterionId,
            rawScore: 70 + Math.floor(Math.random() * 30), // Notas aleatorias entre 70 y 100
            comments: `Evaluación de estrés simultánea #${r}`
          }
        ],
        memberScores: []
      };
      
      syncPromises.push(makeRequest(`${TARGET_URL}/api/evaluation/sync`, 'POST', headers, payload));
    }
  }

  const syncResults = await Promise.all(syncPromises);
  const successSyncs = syncResults.filter(r => r.success);
  console.log(`-> Sincronizaciones exitosas: ${successSyncs.length}/${syncPromises.length}`);

  // 4. Procesar Resultados Estadísticos
  const allResults = [...loginResults, ...queryResults, ...syncResults];
  const totalRequests = allResults.length;
  const successfulRequests = allResults.filter(r => r.success);
  const failedRequests = allResults.filter(r => !r.success);
  
  const durations = allResults.map(r => r.durationMs);
  const totalDurationMs = Date.now() - globalStartTime;
  
  const avgDuration = durations.reduce((sum, d) => sum + d, 0) / totalRequests;
  const minDuration = Math.min(...durations);
  const maxDuration = Math.max(...durations);
  const throughput = (totalRequests / (totalDurationMs / 1000)).toFixed(2);

  console.log(`\n====================================================`);
  console.log(`         RESULTADOS DE LA PRUEBA DE ESTRÉS`);
  console.log(`====================================================`);
  console.log(`Peticiones Totales:     ${totalRequests}`);
  console.log(`Peticiones Exitosas:    ${successfulRequests.length} (${((successfulRequests.length/totalRequests)*100).toFixed(1)}%)`);
  console.log(`Peticiones Fallidas:    ${failedRequests.length}`);
  console.log(`Tiempo Total Ejecución: ${(totalDurationMs / 1000).toFixed(2)} segundos`);
  console.log(`Throughput Promedio:    ${throughput} peticiones/seg\n`);
  
  console.log(`Tiempos de Respuesta:`);
  console.log(`  - Promedio:           ${avgDuration.toFixed(1)} ms`);
  console.log(`  - Mínimo:             ${minDuration.toFixed(1)} ms`);
  console.log(`  - Máximo:             ${maxDuration.toFixed(1)} ms`);
  console.log(`====================================================`);
  
  // Analizar códigos de respuesta recibidos
  const statusCodes = {};
  allResults.forEach(r => {
    statusCodes[r.statusCode] = (statusCodes[r.statusCode] || 0) + 1;
  });
  console.log(`Distribución de Códigos HTTP:`);
  Object.keys(statusCodes).forEach(code => {
    console.log(`  - HTTP ${code}: ${statusCodes[code]} peticiones`);
  });
  console.log(`====================================================\n`);
  
  await prisma.$disconnect();
}

runTest();
