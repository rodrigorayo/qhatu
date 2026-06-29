import crypto from 'crypto';
import { prisma } from '../index';

// Cargar variables de entorno
const clientEmail = process.env.GOOGLE_SERVICE_ACCOUNT_EMAIL;
const privateKeyRaw = process.env.GOOGLE_PRIVATE_KEY;

// Helper to sanitize private key from env variables (handles quotes, literal or escaped newlines)
const sanitizePrivateKey = (key: string | undefined): string => {
  if (!key) return '';
  let cleaned = key.trim();
  
  // Remove wrapping double or single quotes if present
  if (cleaned.startsWith('"') && cleaned.endsWith('"')) {
    cleaned = cleaned.substring(1, cleaned.length - 1).trim();
  } else if (cleaned.startsWith("'") && cleaned.endsWith("'")) {
    cleaned = cleaned.substring(1, cleaned.length - 1).trim();
  }
  
  // Replace escaped newlines (both \n and \\n) with actual newlines
  cleaned = cleaned.replace(/\\n/g, '\n');
  cleaned = cleaned.replace(/\\r/g, '\r');
  
  return cleaned;
};

const privateKey = sanitizePrivateKey(privateKeyRaw);

const isGoogleConfigured = (): boolean => {
  return !!(clientEmail && privateKey);
};

// Generar un JWT firmado con RS256 para Google API
function generateGoogleJWT(): string {
  if (!clientEmail || !privateKey) {
    throw new Error('Google Credentials not configured');
  }

  const header = {
    alg: 'RS256',
    typ: 'JWT'
  };

  const now = Math.floor(Date.now() / 1000);
  const payload = {
    iss: clientEmail,
    scope: 'https://www.googleapis.com/auth/spreadsheets https://www.googleapis.com/auth/drive',
    aud: 'https://oauth2.googleapis.com/token',
    exp: now + 3600,
    iat: now
  };

  const base64UrlEncode = (obj: any) => {
    return Buffer.from(JSON.stringify(obj))
      .toString('base64')
      .replace(/=/g, '')
      .replace(/\+/g, '-')
      .replace(/\//g, '_');
  };

  const part1 = base64UrlEncode(header);
  const part2 = base64UrlEncode(payload);
  const tokenInput = `${part1}.${part2}`;

  const signer = crypto.createSign('RSA-SHA256');
  signer.update(tokenInput);
  const signature = signer.sign(privateKey, 'base64')
    .replace(/=/g, '')
    .replace(/\+/g, '-')
    .replace(/\//g, '_');

  return `${tokenInput}.${signature}`;
}

// Obtener un token de acceso OAuth2 de Google
async function getAccessToken(): Promise<string> {
  const jwtToken = generateGoogleJWT();
  const response = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/x-www-form-urlencoded'
    },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion: jwtToken
    }).toString()
  });

  if (!response.ok) {
    const errText = await response.text();
    throw new Error(`Failed to get Google access token: ${errText}`);
  }

  const data = (await response.json()) as { access_token: string };
  return data.access_token;
}

export interface SpreadsheetCreationResult {
  spreadsheetId: string;
  spreadsheetUrl: string;
}

// Crear un Spreadsheet con pestañas por defecto y compartirlo
export const createSpreadsheet = async (title: string, ownerEmail?: string): Promise<SpreadsheetCreationResult | null> => {
  if (!isGoogleConfigured()) {
    console.warn('Google Sheets API no configurado en el archivo .env. Saltando la creación del documento.');
    return null;
  }

  try {
    const token = await getAccessToken();

    // 1. Crear el Google Sheet con las pestañas "Stands" y "Criterios"
    const createRes = await fetch('https://sheets.googleapis.com/v4/spreadsheets', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        properties: { title: `Feria - ${title}` },
        sheets: [
          { properties: { title: 'Stands' } },
          { properties: { title: 'Criterios' } }
        ]
      })
    });

    if (!createRes.ok) {
      const errText = await createRes.text();
      throw new Error(`Error al crear spreadsheet: ${errText}`);
    }

    const sheetData = (await createRes.json()) as { spreadsheetId: string; spreadsheetUrl: string };
    const { spreadsheetId, spreadsheetUrl } = sheetData;

    // 2. Rellenar las cabeceras de plantilla en ambas pestañas
    const updateRes = await fetch(`https://sheets.googleapis.com/v4/spreadsheets/${spreadsheetId}/values:batchUpdate`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        valueInputOption: 'USER_ENTERED',
        data: [
          {
            range: 'Stands!A1:D1',
            values: [['Número', 'Nombre', 'Curso', 'Integrantes (separados por coma)']]
          },
          {
            range: 'Criterios!A1:F1',
            values: [['Área', 'Criterio', 'Nota Mínima', 'Nota Máxima', 'Peso Real', 'Evaluador (JURADO/DELEGADO/AMBOS)']]
          }
        ]
      })
    });

    if (!updateRes.ok) {
      console.error('Error al insertar cabeceras de plantilla:', await updateRes.text());
    }

    // 3. Compartir el documento públicamente (Cualquiera con el enlace puede editar)
    const permissionRes = await fetch(`https://www.googleapis.com/drive/v3/files/${spreadsheetId}/permissions`, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        role: 'writer',
        type: 'anyone'
      })
    });

    if (!permissionRes.ok) {
      console.error('Error al compartir spreadsheet públicamente:', await permissionRes.text());
    }

    // 4. Si se provee un correo Gmail específico del administrador, compartir también con él
    if (ownerEmail && ownerEmail.includes('@')) {
      const emailPermissionRes = await fetch(`https://www.googleapis.com/drive/v3/files/${spreadsheetId}/permissions?sendNotificationEmail=true`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          role: 'writer',
          type: 'user',
          emailAddress: ownerEmail.trim()
        })
      });
      if (!emailPermissionRes.ok) {
        console.error(`Error al compartir con correo ${ownerEmail}:`, await emailPermissionRes.text());
      }
    }

    return { spreadsheetId, spreadsheetUrl };
  } catch (error) {
    console.error('Error en createSpreadsheet:', error);
    return null;
  }
};

// Sincronizar los resultados en pestañas individuales por cada Stand
export const syncResultsToSheets = async (spreadsheetId: string, feriaId: string): Promise<boolean> => {
  if (!isGoogleConfigured()) {
    console.warn('Google Sheets API no configurado en .env. Sincronización cancelada.');
    return false;
  }

  try {
    const token = await getAccessToken();

    // 1. Obtener la información completa de la feria y stands
    const feria = await prisma.feria.findUnique({ where: { id: feriaId } });
    if (!feria) return false;

    const areas = await prisma.area.findMany({
      where: { feriaId },
      include: { criteria: true }
    });

    const stands = await prisma.stand.findMany({
      where: { feriaId },
      include: {
        members: true,
        assignments: { include: { user: true, areas: true } }
      },
      orderBy: { number: 'asc' }
    });

    const standEvals = await prisma.evaluationStand.findMany({
      where: { stand: { feriaId } },
      include: { criterion: true, jurado: true }
    });

    const memberEvals = await prisma.evaluationMember.findMany({
      where: { member: { stand: { feriaId } } },
      include: { criterion: true, delegado: true, member: true }
    });

    // 2. Obtener las pestañas actuales del Spreadsheet para saber cuáles existen
    const metaRes = await fetch(`https://sheets.googleapis.com/v4/spreadsheets/${spreadsheetId}?includeGridData=false`, {
      method: 'GET',
      headers: { 'Authorization': `Bearer ${token}` }
    });

    if (!metaRes.ok) {
      const err = await metaRes.text();
      throw new Error(`Error obteniendo metadatos del sheet: ${err}`);
    }

    const metaData = (await metaRes.json()) as { sheets: Array<{ properties: { title: string; sheetId: number } }> };
    const existingTitles = metaData.sheets.map(s => s.properties.title);

    // 3. Crear las pestañas faltantes para cada Stand
    const requestsToAddSheets = [];
    const rangesToClear = [];

    for (const stand of stands) {
      const title = `Stand ${stand.number}`;
      if (!existingTitles.includes(title)) {
        requestsToAddSheets.push({
          addSheet: {
            properties: { title }
          }
        });
      } else {
        rangesToClear.push(`${title}!A1:Z100`);
      }
    }

    if (requestsToAddSheets.length > 0) {
      const batchRes = await fetch(`https://sheets.googleapis.com/v4/spreadsheets/${spreadsheetId}:batchUpdate`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ requests: requestsToAddSheets })
      });
      if (!batchRes.ok) {
        console.error('Error al agregar pestañas de stands:', await batchRes.text());
      }
    }

    // 4. Limpiar las celdas de las pestañas que ya existían antes de reescribir
    if (rangesToClear.length > 0) {
      const clearRes = await fetch(`https://sheets.googleapis.com/v4/spreadsheets/${spreadsheetId}/values:batchClear`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({ ranges: rangesToClear })
      });
      if (!clearRes.ok) {
        console.error('Error al limpiar pestañas de stands:', await clearRes.text());
      }
    }

    // 5. Preparar la escritura masiva de datos para cada stand
    const dataToWrite = [];

    for (const stand of stands) {
      const sheetTitle = `Stand ${stand.number}`;
      const standAssignments = stand.assignments;
      const membersNames = stand.members.map(m => m.fullName).join(', ');

      let curso = '';
      if (stand.metadata && typeof stand.metadata === 'object') {
        curso = (stand.metadata as any).curso || '';
      }

      // Filtrar evaluaciones hechas para este stand
      const thisStandEvals = standEvals.filter(e => e.standId === stand.id);

      // Calcular detalles de Jurado
      const juradosDetails = standAssignments
        .filter(a => a.roleInStand === 'JURADO')
        .map(assignment => {
          const evaluator = assignment.user;
          const assignedAreas = assignment.areas;
          const targetCriteriaIds = assignedAreas.length > 0
            ? areas.filter(a => assignedAreas.some(aa => aa.id === a.id)).flatMap(a => a.criteria.map(c => c.id))
            : areas.flatMap(a => a.criteria.map(c => c.id));

          const myEvals = thisStandEvals.filter(e => e.juradoId === evaluator.id);
          const completedCount = myEvals.length;

          let totalScore = 0;
          if (completedCount > 0) {
            if (feria.calculationType === 'WEIGHTED') {
              let weightedSum = 0;
              let totalWeightPct = 0;

              for (const area of areas) {
                const areaCriteria = area.criteria.filter(c => targetCriteriaIds.includes(c.id));
                if (areaCriteria.length === 0) continue;

                const areaEvals = myEvals.filter(e => areaCriteria.some(c => c.id === e.criterionId));
                
                const areaEarned = areaEvals.reduce((sum, e) => {
                  const crit = areaCriteria.find(c => c.id === e.criterionId);
                  if (crit) {
                    const min = crit.minScore;
                    const max = crit.maxScore;
                    const weight = (crit as any).weight ?? 10.0;
                    if (max <= min) return sum;
                    const val = (e.rawScore - min) / (max - min);
                    return sum + Math.max(0, Math.min(1, val)) * weight;
                  }
                  return sum;
                }, 0);

                const areaMaxWeight = areaCriteria.reduce((sum, c) => sum + ((c as any).weight ?? 10.0), 0);
                const areaPercentage = areaMaxWeight > 0 ? (areaEarned / areaMaxWeight) * 100 : 0;
                const areaWeightPct = area.weightPercentage ?? 0;

                weightedSum += (areaPercentage * areaWeightPct) / 100;
                totalWeightPct += areaWeightPct;
              }
              totalScore = totalWeightPct > 0 ? (weightedSum / totalWeightPct) * 100 : 0;
            } else {
              totalScore = myEvals.reduce((sum, e) => {
                const crit = areas.flatMap(a => a.criteria).find(c => c.id === e.criterionId);
                if (crit) {
                  const min = crit.minScore;
                  const max = crit.maxScore;
                  const weight = (crit as any).weight ?? 10.0;
                  if (max <= min) return sum;
                  const val = (e.rawScore - min) / (max - min);
                  return sum + Math.max(0, Math.min(1, val)) * weight;
                }
                return sum;
              }, 0);
            }
          }
          return totalScore;
        });

      const completedJurados = juradosDetails.filter(score => score > 0);
      const avgJuradosScore = completedJurados.length > 0
        ? completedJurados.reduce((sum, score) => sum + score, 0) / completedJurados.length
        : 0.0;

      // Calcular detalles de Delegado
      const delegadosDetails = standAssignments
        .filter(a => a.roleInStand === 'DELEGADO')
        .flatMap(assignment => {
          const evaluator = assignment.user;
          const assignedAreas = assignment.areas;
          const targetCriteriaIds = assignedAreas.length > 0
            ? areas.filter(a => assignedAreas.some(aa => aa.id === a.id)).flatMap(a => a.criteria.map(c => c.id))
            : areas.flatMap(a => a.criteria.map(c => c.id));

          return stand.members.map(member => {
            const memberEvaluations = memberEvals.filter(e => e.memberId === member.id && e.delegadoId === evaluator.id);
            const completedCount = memberEvaluations.length;

            let totalScore = 0;
            if (completedCount > 0) {
              if (feria.calculationType === 'WEIGHTED') {
                let weightedSum = 0;
                let totalWeightPct = 0;

                for (const area of areas) {
                  const areaCriteria = area.criteria.filter(c => targetCriteriaIds.includes(c.id));
                  if (areaCriteria.length === 0) continue;

                  const areaEvals = memberEvaluations.filter(e => areaCriteria.some(c => c.id === e.criterionId));
                  
                  const areaEarned = areaEvals.reduce((sum, e) => {
                    const crit = areaCriteria.find(c => c.id === e.criterionId);
                    if (crit) {
                      const min = crit.minScore;
                      const max = crit.maxScore;
                      const weight = (crit as any).weight ?? 10.0;
                      if (max <= min) return sum;
                      const val = (e.rawScore - min) / (max - min);
                      return sum + Math.max(0, Math.min(1, val)) * weight;
                    }
                    return sum;
                  }, 0);

                  const areaMaxWeight = areaCriteria.reduce((sum, c) => sum + ((c as any).weight ?? 10.0), 0);
                  const areaPercentage = areaMaxWeight > 0 ? (areaEarned / areaMaxWeight) * 100 : 0;
                  const areaWeightPct = area.weightPercentage ?? 0;

                  weightedSum += (areaPercentage * areaWeightPct) / 100;
                  totalWeightPct += areaWeightPct;
                }
                totalScore = totalWeightPct > 0 ? (weightedSum / totalWeightPct) * 100 : 0;
              } else {
                totalScore = memberEvaluations.reduce((sum, e) => {
                  const crit = areas.flatMap(a => a.criteria).find(c => c.id === e.criterionId);
                  if (crit) {
                    const min = crit.minScore;
                    const max = crit.maxScore;
                    const weight = (crit as any).weight ?? 10.0;
                    if (max <= min) return sum;
                    const val = (e.rawScore - min) / (max - min);
                    return sum + Math.max(0, Math.min(1, val)) * weight;
                  }
                  return sum;
                }, 0);
              }
            }
            return totalScore;
          });
        });

      const completedDelegados = delegadosDetails.filter(score => score > 0);
      const avgDelegadosScore = completedDelegados.length > 0
        ? completedDelegados.reduce((sum, score) => sum + score, 0) / completedDelegados.length
        : 0.0;

      // Armar las filas de la hoja del Stand
      const rows = [];

      // 1. Datos Generales
      rows.push([`Stand ${stand.number}: ${stand.name}`]);
      rows.push(['Curso:', curso || 'N/A']);
      rows.push(['Integrantes:', membersNames || 'Sin integrantes']);
      rows.push([]);

      // 2. Evaluadores Asignados
      rows.push(['EVALUADORES ASIGNADOS']);
      rows.push(['Usuario', 'Rol', 'Áreas de Evaluación']);
      for (const assignment of standAssignments) {
        const u = assignment.user;
        const arText = assignment.areas.map((ar: any) => ar.name).join(', ') || 'Todas las Áreas';
        rows.push([u.username, assignment.roleInStand, arText]);
      }
      rows.push([]);

      // 3. Notas de Jurados Detalladas
      rows.push(['DETALLE DE EVALUACIÓN - JURADOS']);
      rows.push(['Jurado', 'Área', 'Criterio', 'Nota Máxima Real', 'Nota Obtenida', 'Comentario']);
      const filteredStandEvals = standEvals.filter(e => e.standId === stand.id);
      for (const ev of filteredStandEvals) {
        const area = areas.find(a => a.id === ev.criterion.areaId);
        const min = ev.criterion.minScore;
        const max = ev.criterion.maxScore;
        const weight = ev.criterion.weight;
        const normalizedScore = max > min ? ((ev.rawScore - min) / (max - min)) * weight : 0;
        rows.push([
          ev.jurado.username,
          area ? area.name : 'N/A',
          ev.criterion.name,
          weight,
          normalizedScore.toFixed(2),
          ev.comments || ''
        ]);
      }
      if (filteredStandEvals.length === 0) {
        rows.push(['Sin evaluaciones de jurados registradas aún.']);
      }
      rows.push([]);

      // 4. Notas de Delegados Detalladas
      rows.push(['DETALLE DE EVALUACIÓN - DELEGADOS POR INTEGRANTE']);
      rows.push(['Delegado', 'Integrante', 'Área', 'Criterio', 'Nota Máxima Real', 'Nota Obtenida', 'Comentario']);
      const filteredMemberEvals = memberEvals.filter(e => e.member.standId === stand.id);
      for (const ev of filteredMemberEvals) {
        const area = areas.find(a => a.id === ev.criterion.areaId);
        const min = ev.criterion.minScore;
        const max = ev.criterion.maxScore;
        const weight = ev.criterion.weight;
        const normalizedScore = max > min ? ((ev.rawScore - min) / (max - min)) * weight : 0;
        rows.push([
          ev.delegado.username,
          ev.member.fullName,
          area ? area.name : 'N/A',
          ev.criterion.name,
          weight,
          normalizedScore.toFixed(2),
          ev.comments || ''
        ]);
      }
      if (filteredMemberEvals.length === 0) {
        rows.push(['Sin evaluaciones de delegados registradas aún.']);
      }
      rows.push([]);

      // 5. Resumen de Promedios Finales
      rows.push(['RESUMEN DE PROMEDIOS FINALES']);
      rows.push(['Promedio General Jurados:', `${avgJuradosScore.toFixed(2)} pts`]);
      rows.push(['Promedio General Delegados:', `${avgDelegadosScore.toFixed(2)} pts`]);

      dataToWrite.push({
        range: `${sheetTitle}!A1`,
        values: rows
      });
    }

    // 6. Escribir masivamente todas las celdas de todos los stands
    if (dataToWrite.length > 0) {
      const writeRes = await fetch(`https://sheets.googleapis.com/v4/spreadsheets/${spreadsheetId}/values:batchUpdate`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${token}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          valueInputOption: 'USER_ENTERED',
          data: dataToWrite
        })
      });
      if (!writeRes.ok) {
        const errText = await writeRes.text();
        throw new Error(`Error escribiendo valores de stands: ${errText}`);
      }
    }

    return true;
  } catch (error) {
    console.error('Error en syncResultsToSheets:', error);
    return false;
  }
};
