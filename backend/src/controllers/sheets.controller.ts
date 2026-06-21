import { Response } from 'express';
import { prisma } from '../index';
import { AuthRequest } from '../middlewares/auth.middleware';
import { syncResultsToSheets, createSpreadsheet } from '../services/google.service';

const parseCSV = (csvText: string): string[][] => {
  const lines = csvText.split(/\r?\n/);
  return lines.map(line => {
    const result = [];
    let current = '';
    let inQuotes = false;
    for (let i = 0; i < line.length; i++) {
      const char = line[i];
      if (char === '"') {
        inQuotes = !inQuotes;
      } else if (char === ',' && !inQuotes) {
        result.push(current.trim().replace(/^"|"$/g, '').replace(/""/g, '"'));
        current = '';
      } else {
        current += char;
      }
    }
    result.push(current.trim().replace(/^"|"$/g, '').replace(/""/g, '"'));
    return result;
  }).filter(row => row.length > 0 && row.some(cell => cell !== ''));
};

const isHeaderRow = (row: string[]): boolean => {
  if (!row || row.length === 0) return false;
  const firstCell = row[0].toLowerCase();
  return firstCell.includes('numero') || firstCell.includes('número') || firstCell.includes('number') || firstCell.includes('area') || firstCell.includes('área');
};

export const importSheets = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const feriaId = req.user?.feriaId;
    if (!feriaId) return res.status(403).json({ error: 'No tienes una feria asignada' });

    const { spreadsheetUrl, overwrite } = req.body;
    if (!spreadsheetUrl) return res.status(400).json({ error: 'URL de Google Sheets requerida' });

    const match = spreadsheetUrl.match(/\/d\/([a-zA-Z0-9-_]+)/);
    if (!match) return res.status(400).json({ error: 'URL de Google Sheets inválida' });
    const spreadsheetId = match[1];

    const standsCsvUrl = `https://docs.google.com/spreadsheets/d/${spreadsheetId}/gviz/tq?tqx=out:csv&sheet=Stands`;
    const criteriaCsvUrl = `https://docs.google.com/spreadsheets/d/${spreadsheetId}/gviz/tq?tqx=out:csv&sheet=Criterios`;

    let standsRes, criteriaRes;
    try {
      standsRes = await fetch(standsCsvUrl);
      criteriaRes = await fetch(criteriaCsvUrl);
    } catch (err) {
      return res.status(400).json({ error: 'Error al conectar con Google Sheets. Verifica que el enlace sea correcto y público (Cualquiera con el enlace puede ver).' });
    }

    if (standsRes.status !== 200 || criteriaRes.status !== 200) {
      return res.status(400).json({ error: 'No se encontraron las pestañas "Stands" y "Criterios" o el documento no es público.' });
    }

    const standsCsvText = await standsRes.text();
    const criteriaCsvText = await criteriaRes.text();

    const standsRows = parseCSV(standsCsvText);
    const criteriaRows = parseCSV(criteriaCsvText);

    if (standsRows.length === 0 || criteriaRows.length === 0) {
      return res.status(400).json({ error: 'Las hojas "Stands" y "Criterios" no deben estar vacías.' });
    }

    // Omitir cabeceras si existen
    const finalStandsRows = isHeaderRow(standsRows[0]) ? standsRows.slice(1) : standsRows;
    const finalCriteriaRows = isHeaderRow(criteriaRows[0]) ? criteriaRows.slice(1) : criteriaRows;

    if (overwrite) {
      // Limpiar base de datos para esta feria antes de importar
      await prisma.$transaction([
        prisma.evaluationStand.deleteMany({ where: { stand: { feriaId } } }),
        prisma.evaluationMember.deleteMany({ where: { member: { stand: { feriaId } } } }),
        prisma.assignment.deleteMany({ where: { stand: { feriaId } } }),
        prisma.member.deleteMany({ where: { stand: { feriaId } } }),
        prisma.stand.deleteMany({ where: { feriaId } }),
        prisma.criterion.deleteMany({ where: { area: { feriaId } } }),
        prisma.area.deleteMany({ where: { feriaId } }),
      ]);
    }

    // 1. Importar rúbrica (Criterios)
    const areaCache: Record<string, string> = {}; // areaName -> areaId
    for (const row of finalCriteriaRows) {
      if (row.length < 2) continue;
      const areaName = row[0].trim();
      const criterionName = row[1].trim();
      if (!areaName || !criterionName) continue;

      let minScore = 0;
      let maxScore = 100;
      let weight = 10.0;
      if (row[2]) {
        const parsedMin = parseFloat(row[2]);
        if (!isNaN(parsedMin)) minScore = parsedMin;
      }
      if (row[3]) {
        const parsedMax = parseFloat(row[3]);
        if (!isNaN(parsedMax)) maxScore = parsedMax;
      }
      if (row[4]) {
        const parsedWeight = parseFloat(row[4]);
        if (!isNaN(parsedWeight)) weight = parsedWeight;
      }

      let areaId = areaCache[areaName];
      if (!areaId) {
        // Buscar o crear área
        let area = await prisma.area.findFirst({
          where: { name: areaName, feriaId }
        });
        if (!area) {
          area = await prisma.area.create({
            data: { name: areaName, feriaId }
          });
        }
        areaId = area.id;
        areaCache[areaName] = areaId;
      }

      // Crear criterio
      await prisma.criterion.create({
        data: {
          name: criterionName,
          minScore,
          maxScore,
          weight,
          areaId
        }
      });
    }

    // 2. Importar stands e integrantes
    for (const row of finalStandsRows) {
      if (row.length < 2) continue;
      const number = row[0].trim();
      const name = row[1].trim();
      if (!number || !name) continue;

      const curso = row[2] ? row[2].trim() : '';
      const membersStr = row[3] ? row[3].trim() : '';

      const stand = await prisma.stand.create({
        data: {
          number,
          name,
          feriaId,
          metadata: curso ? { curso } : undefined
        }
      });

      if (membersStr) {
        const memberNames = membersStr.split(',').map(m => m.trim()).filter(m => m.length > 0);
        for (const fullName of memberNames) {
          await prisma.member.create({
            data: {
              fullName,
              standId: stand.id
            }
          });
        }
      }
    }

    res.status(200).json({ message: 'Datos importados con éxito.' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error interno al importar los datos' });
  }
};

export const exportResultsCSV = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const feriaId = req.user?.feriaId;
    if (!feriaId) return res.status(403).json({ error: 'No tienes una feria asignada' });

    // 1. Obtener datos de resultados
    const feria = await prisma.feria.findUnique({
      where: { id: feriaId }
    });
    if (!feria) return res.status(404).json({ error: 'Feria no encontrada' });

    const areas = await prisma.area.findMany({
      where: { feriaId },
      include: { criteria: true }
    });

    const stands = await prisma.stand.findMany({
      where: { feriaId },
      include: {
        members: true,
        assignments: {
          include: {
            user: true,
            areas: true
          }
        }
      },
      orderBy: { number: 'asc' }
    });

    const standEvals = await prisma.evaluationStand.findMany({
      where: { stand: { feriaId } },
      include: { criterion: true, jurado: true }
    });

    const memberEvals = await prisma.evaluationMember.findMany({
      where: { member: { stand: { feriaId } } },
      include: { criterion: true, delegado: true }
    });

    // 2. Generar contenido CSV
    const csvRows = [];
    // Cabecera
    csvRows.push(['Numero Stand', 'Nombre Stand', 'Curso', 'Integrantes', 'Promedio Jurado', 'Promedio Delegado'].join(','));

    for (const stand of stands) {
      const standAssignments = stand.assignments;
      const standEvaluations = standEvals.filter(e => e.standId === stand.id);
      
      const juradosDetails = standAssignments
        .filter(a => a.roleInStand === 'JURADO')
        .map(assignment => {
          const evaluator = assignment.user;
          const assignedAreas = assignment.areas;
          const targetCriteriaIds = assignedAreas.length > 0
            ? areas.filter(a => assignedAreas.some(aa => aa.id === a.id)).flatMap(a => a.criteria.map(c => c.id))
            : areas.flatMap(a => a.criteria.map(c => c.id));

          const myEvals = standEvaluations.filter(e => e.juradoId === evaluator.id);
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
      const avgJuradoScore = completedJurados.length > 0
        ? completedJurados.reduce((sum, score) => sum + score, 0) / completedJurados.length
        : 0.0;

      // Integrantes
      const membersNames = stand.members.map(m => m.fullName).join('; ');
      
      // Curso
      let curso = '';
      if (stand.metadata && typeof stand.metadata === 'object') {
        curso = (stand.metadata as any).curso || '';
      }

      // Delegado avg
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
      const avgDelegadoScore = completedDelegados.length > 0
        ? completedDelegados.reduce((sum, score) => sum + score, 0) / completedDelegados.length
        : 0.0;

      // Escapar celdas para evitar problemas de CSV
      const escapedNumber = `"${stand.number.replace(/"/g, '""')}"`;
      const escapedName = `"${stand.name.replace(/"/g, '""')}"`;
      const escapedCurso = `"${curso.replace(/"/g, '""')}"`;
      const escapedMembers = `"${membersNames.replace(/"/g, '""')}"`;

      csvRows.push([
        escapedNumber,
        escapedName,
        escapedCurso,
        escapedMembers,
        avgJuradoScore.toFixed(2),
        avgDelegadoScore.toFixed(2)
      ].join(','));
    }

    const csvContent = '\uFEFF' + csvRows.join('\n'); // BOM para Excel en español

    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader('Content-Disposition', 'attachment; filename="resultados_feria.csv"');
    res.status(200).send(csvContent);

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al exportar CSV' });
  }
};

export const syncConfigFromGoogleSheets = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const feriaId = req.user?.feriaId;
    if (!feriaId) return res.status(403).json({ error: 'No tienes una feria asignada' });

    const feria = await prisma.feria.findUnique({ where: { id: feriaId } });
    if (!feria) return res.status(404).json({ error: 'Feria no encontrada' });

    if (!feria.metadata || typeof feria.metadata !== 'object') {
      return res.status(400).json({ error: 'Esta feria no tiene un Google Sheet asociado' });
    }

    const spreadsheetId = (feria.metadata as any).spreadsheetId;
    if (!spreadsheetId) {
      return res.status(400).json({ error: 'Esta feria no tiene un Google Sheet asociado' });
    }

    const spreadsheetUrl = `https://docs.google.com/spreadsheets/d/${spreadsheetId}`;
    
    req.body = { ...req.body, spreadsheetUrl, overwrite: true };
    return importSheets(req, res);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al sincronizar configuración de la feria' });
  }
};

export const syncResultsToGoogleSheets = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const feriaId = req.user?.feriaId;
    if (!feriaId) return res.status(403).json({ error: 'No tienes una feria asignada' });

    const feria = await prisma.feria.findUnique({ where: { id: feriaId } });
    if (!feria) return res.status(404).json({ error: 'Feria no encontrada' });

    if (!feria.metadata || typeof feria.metadata !== 'object') {
      return res.status(400).json({ error: 'Esta feria no tiene un Google Sheet asociado' });
    }

    const spreadsheetId = (feria.metadata as any).spreadsheetId;
    if (!spreadsheetId) {
      return res.status(400).json({ error: 'Esta feria no tiene un Google Sheet asociado' });
    }

    const success = await syncResultsToSheets(spreadsheetId, feriaId);
    if (!success) {
      return res.status(500).json({ error: 'Error al sincronizar resultados a Google Sheets' });
    }

    res.status(200).json({ message: 'Resultados sincronizados exitosamente a Google Sheets' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al sincronizar resultados de la feria' });
  }
};

export const createFeriaSpreadsheet = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const feriaId = req.user?.feriaId;
    if (!feriaId) return res.status(403).json({ error: 'No tienes una feria asignada' });

    const feria = await prisma.feria.findUnique({ where: { id: feriaId } });
    if (!feria) return res.status(404).json({ error: 'Feria no encontrada' });

    let currentMetadata = (feria.metadata && typeof feria.metadata === 'object') ? { ...feria.metadata as object } : {};
    if ((currentMetadata as any).spreadsheetId) {
      return res.status(400).json({ error: 'Esta feria ya tiene un Google Sheet asociado' });
    }

    const { gmail } = req.body;
    const sheetsResult = await createSpreadsheet(feria.name, gmail);
    if (!sheetsResult) {
      return res.status(500).json({ error: 'No se pudo crear el Google Sheet. Verifica las credenciales de Google en el servidor.' });
    }

    const { spreadsheetId, spreadsheetUrl } = sheetsResult;
    const updatedFeria = await prisma.feria.update({
      where: { id: feriaId },
      data: {
        metadata: {
          ...currentMetadata,
          spreadsheetId,
          spreadsheetUrl
        }
      }
    });

    res.status(201).json({
      message: 'Google Sheet creado y asociado con éxito',
      spreadsheetUrl,
      spreadsheetId,
      feria: updatedFeria
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al crear el Google Sheet para la feria' });
  }
};
