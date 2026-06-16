import { Response } from 'express';
import { prisma } from '../index';
import { AuthRequest } from '../middlewares/auth.middleware';

export const createCriterion = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const feriaId = req.user?.feriaId;
    const { areaId, name, minScore, maxScore, weight } = req.body;

    // Verificar que el área pertenece a la feria del administrador
    const area = await prisma.area.findUnique({ where: { id: areaId } });
    if (!area || area.feriaId !== feriaId) {
      return res.status(403).json({ error: 'Acceso denegado a esta área' });
    }

    const newCriterion = await prisma.criterion.create({
      data: {
        name,
        minScore: parseFloat(minScore.toString()),
        maxScore: parseFloat(maxScore.toString()),
        weight: weight ? parseFloat(weight.toString()) : 10.0,
        areaId
      }
    });

    res.status(201).json(newCriterion);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al crear criterio' });
  }
};

export const deleteCriterion = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const feriaId = req.user?.feriaId;
    const id = req.params.id as string;

    // Verificar propiedad a través del área
    const criterion = await prisma.criterion.findUnique({ 
      where: { id },
      include: { area: true }
    });

    if (!criterion || criterion.area.feriaId !== feriaId) {
      return res.status(404).json({ error: 'Criterio no encontrado o acceso denegado' });
    }

    await prisma.criterion.delete({ where: { id } });
    res.json({ message: 'Criterio eliminado exitosamente' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al eliminar criterio' });
  }
};
