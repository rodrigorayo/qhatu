import { Response } from 'express';
import { prisma } from '../index';
import { AuthRequest } from '../middlewares/auth.middleware';
import { syncResultsToSheets } from '../services/google.service';

// Obtener los stands asignados al evaluador
export const getMyAssignments = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ error: 'No autorizado' });

    const assignments = await prisma.assignment.findMany({
      where: { userId },
      include: {
        stand: {
          include: { members: true }
        },
        areas: {
          include: { criteria: true }
        }
      }
    });

    const result = [];
    for (const assignment of assignments) {
      // Obtener criterios asignados para contar el total esperado
      const assignedAreas = assignment.areas as any[];
      const targetCriteriaIds = assignedAreas.length > 0
        ? assignedAreas.flatMap((a: any) => a.criteria.map((c: any) => c.id))
        : (await prisma.area.findMany({
            where: { feriaId: req.user?.feriaId || undefined },
            include: { criteria: true }
          }) as any[]).flatMap((a: any) => a.criteria.map((c: any) => c.id));

      let isEvaluated = false;
      if (assignment.roleInStand === 'JURADO') {
        const count = await prisma.evaluationStand.count({
          where: {
            standId: assignment.standId,
            juradoId: userId,
            criterionId: { in: targetCriteriaIds }
          }
        });
        isEvaluated = count >= targetCriteriaIds.length && targetCriteriaIds.length > 0;
      } else {
        // DELEGADO
        const members = assignment.stand.members;
        if (members.length > 0) {
          let allMembersEvaluated = true;
          for (const member of members) {
            const count = await prisma.evaluationMember.count({
              where: {
                memberId: member.id,
                delegadoId: userId,
                criterionId: { in: targetCriteriaIds }
              }
            });
            if (count < targetCriteriaIds.length) {
              allMembersEvaluated = false;
              break;
            }
          }
          isEvaluated = allMembersEvaluated && targetCriteriaIds.length > 0;
        }
      }

      result.push({
        ...assignment,
        isEvaluated
      });
    }

    res.json(result);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al obtener asignaciones' });
  }
};


// Obtener la rúbrica (áreas y criterios) de la feria asignada
export const getFeriaRubric = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const feriaId = req.user?.feriaId;
    if (!feriaId) return res.status(403).json({ error: 'No tienes una feria asignada' });

    const areas = await prisma.area.findMany({
      where: { feriaId },
      include: { criteria: true },
      orderBy: { createdAt: 'asc' }
    });

    res.json(areas);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al obtener la rúbrica' });
  }
};

// Sincronizar (guardar) puntajes enviados desde la app offline
export const syncScores = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const userId = req.user?.id;
    if (!userId) return res.status(401).json({ error: 'No autorizado' });
    const feriaId = req.user?.feriaId;

    const { standScores, memberScores } = req.body;

    const standOperations = (standScores || []).map((score: any) => 
      prisma.evaluationStand.upsert({
        where: {
          standId_juradoId_criterionId: {
            standId: score.standId,
            juradoId: userId,
            criterionId: score.criterionId,
          }
        },
        update: { rawScore: score.rawScore, comments: score.comments },
        create: {
          standId: score.standId,
          juradoId: userId,
          criterionId: score.criterionId,
          rawScore: score.rawScore,
          comments: score.comments
        }
      })
    );

    const memberOperations = (memberScores || []).map((score: any) => 
      prisma.evaluationMember.upsert({
        where: {
          memberId_delegadoId_criterionId: {
            memberId: score.memberId,
            delegadoId: userId,
            criterionId: score.criterionId,
          }
        },
        update: { rawScore: score.rawScore, comments: score.comments },
        create: {
          memberId: score.memberId,
          delegadoId: userId,
          criterionId: score.criterionId,
          rawScore: score.rawScore,
          comments: score.comments
        }
      })
    );

    await prisma.$transaction([...standOperations, ...memberOperations]);

    // Disparar sincronización hacia Google Sheets en segundo plano
    if (feriaId) {
      prisma.feria.findUnique({
        where: { id: feriaId }
      }).then(feria => {
        if (feria && feria.metadata && typeof feria.metadata === 'object') {
          const spreadsheetId = (feria.metadata as any).spreadsheetId;
          if (spreadsheetId) {
            syncResultsToSheets(spreadsheetId, feriaId).catch(err => {
              console.error('Error al sincronizar resultados a Google Sheets en segundo plano:', err);
            });
          }
        }
      }).catch(err => {
        console.error('Error al buscar la feria para sincronización a Sheets:', err);
      });
    }

    res.status(200).json({ message: 'Sincronización exitosa' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al sincronizar puntajes' });
  }
};

// Obtener todos los stands de la feria del evaluador
export const getFeriaStands = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const feriaId = req.user?.feriaId;
    if (!feriaId) return res.status(403).json({ error: 'No tienes una feria asignada' });

    const stands = await prisma.stand.findMany({
      where: { feriaId },
      include: { members: true },
      orderBy: { number: 'asc' }
    });

    res.json(stands);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al obtener stands de la feria' });
  }
};

export const getResults = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const feriaId = req.user?.feriaId;
    if (!feriaId) return res.status(403).json({ error: 'No tienes una feria asignada' });

    // 1. Obtener la feria para saber el tipo de cálculo
    const feria = await prisma.feria.findUnique({
      where: { id: feriaId }
    });
    if (!feria) return res.status(404).json({ error: 'Feria no encontrada' });

    // 2. Obtener todas las áreas y sus criterios
    const areas = await prisma.area.findMany({
      where: { feriaId },
      include: { criteria: true }
    });

    // 3. Obtener todos los stands con sus miembros, asignaciones (con sus áreas y usuarios)
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

    // 4. Obtener todas las evaluaciones
    const standEvals = await prisma.evaluationStand.findMany({
      where: { stand: { feriaId } },
      include: { criterion: true, jurado: true }
    });

    const memberEvals = await prisma.evaluationMember.findMany({
      where: { member: { stand: { feriaId } } },
      include: { criterion: true, delegado: true }
    });

    const results = stands.map(stand => {
      const standAssignments = stand.assignments;
      
      // Filtrar evaluaciones para este stand
      const standEvaluations = standEvals.filter(e => e.standId === stand.id);
      
      // Detalle de Jurados y sus notas
      const juradosDetails = standAssignments
        .filter(a => a.roleInStand === 'JURADO')
        .map(assignment => {
          const evaluator = assignment.user;
          // Criterios que le corresponde evaluar (si no especificó áreas, todos los de la feria que apliquen a JURADO/BOTH)
          const assignedAreas = assignment.areas;
          const roleAreas = areas.filter(a => a.applicableRole === 'BOTH' || a.applicableRole === 'JURADO');
          const targetCriteriaIds = assignedAreas.length > 0
            ? roleAreas.filter(a => assignedAreas.some(aa => aa.id === a.id)).flatMap(a => a.criteria.map(c => c.id))
            : roleAreas.flatMap(a => a.criteria.map(c => c.id));

          // Evaluaciones hechas por este jurado
          const myEvals = standEvaluations.filter(e => e.juradoId === evaluator.id);
          const completedCount = myEvals.length;
          const totalAssignedCount = targetCriteriaIds.length;

          // Calcular puntaje total del jurado
          let totalScore = 0;
          if (completedCount > 0) {
            if (feria.calculationType === 'WEIGHTED') {
              let weightedSum = 0;
              let totalWeightPct = 0;

              for (const area of roleAreas) {
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
              // Sumativa
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

          return {
            evaluatorId: evaluator.id,
            username: evaluator.username,
            role: 'JURADO',
            completedCount,
            totalAssignedCount,
            isCompleted: completedCount >= totalAssignedCount && totalAssignedCount > 0,
            score: totalScore
          };
        });

      // Detalle de Delegados y sus notas por miembro
      const delegadosDetails = standAssignments
        .filter(a => a.roleInStand === 'DELEGADO')
        .flatMap(assignment => {
          const evaluator = assignment.user;
          const assignedAreas = assignment.areas;
          const roleAreas = areas.filter(a => a.applicableRole === 'BOTH' || a.applicableRole === 'DELEGADO');
          const targetCriteriaIds = assignedAreas.length > 0
            ? roleAreas.filter(a => assignedAreas.some(aa => aa.id === a.id)).flatMap(a => a.criteria.map(c => c.id))
            : roleAreas.flatMap(a => a.criteria.map(c => c.id));

          // Para cada miembro del stand, ver el avance
          return stand.members.map(member => {
            const memberEvaluations = memberEvals.filter(e => e.memberId === member.id && e.delegadoId === evaluator.id);
            const completedCount = memberEvaluations.length;
            const totalAssignedCount = targetCriteriaIds.length;

            let totalScore = 0;
            if (completedCount > 0) {
              if (feria.calculationType === 'WEIGHTED') {
                let weightedSum = 0;
                let totalWeightPct = 0;

                for (const area of roleAreas) {
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
                // Sumativa
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

            return {
              evaluatorId: evaluator.id,
              username: evaluator.username,
              role: 'DELEGADO',
              memberId: member.id,
              memberName: member.fullName,
              completedCount,
              totalAssignedCount,
              isCompleted: completedCount >= totalAssignedCount && totalAssignedCount > 0,
              score: totalScore
            };
          });
        });

      // Calcular promedio general del Jurado
      const completedJurados = juradosDetails.filter(j => j.completedCount > 0);
      const avgJuradoScore = completedJurados.length > 0
        ? completedJurados.reduce((sum, j) => sum + j.score, 0) / completedJurados.length
        : 0.0;

      // Calcular promedio general del Delegado
      const completedDelegados = delegadosDetails.filter(d => d.completedCount > 0);
      const avgDelegadoScore = completedDelegados.length > 0
        ? completedDelegados.reduce((sum, d) => sum + d.score, 0) / completedDelegados.length
        : 0.0;

      return {
        id: stand.id,
        name: stand.name,
        number: stand.number,
        membersCount: stand.members.length,
        avgJuradoScore: parseFloat(avgJuradoScore.toFixed(2)),
        avgDelegadoScore: parseFloat(avgDelegadoScore.toFixed(2)),
        jurados: juradosDetails,
        delegados: delegadosDetails
      };
    });

    res.json({
      calculationType: feria.calculationType,
      results
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al calcular resultados' });
  }
};


