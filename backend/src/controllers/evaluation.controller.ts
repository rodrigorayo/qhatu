import { Response } from 'express';
import { prisma } from '../index';
import { AuthRequest } from '../middlewares/auth.middleware';

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
        }
      }
    });

    res.json(assignments);
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

