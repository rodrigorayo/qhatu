import { Response } from 'express';
import { prisma } from '../index';
import { AuthRequest } from '../middlewares/auth.middleware';

export const getAreas = async (req: AuthRequest, res: Response): Promise<any> => {
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
    res.status(500).json({ error: 'Error al obtener áreas' });
  }
};

export const createArea = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const feriaId = req.user?.feriaId;
    if (!feriaId) return res.status(403).json({ error: 'No tienes una feria asignada' });

    const { name, weightPercentage } = req.body;

    const newArea = await prisma.area.create({
      data: {
        name,
        weightPercentage: weightPercentage || null,
        feriaId
      },
      include: { criteria: true }
    });

    res.status(201).json(newArea);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al crear área' });
  }
};

export const deleteArea = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const feriaId = req.user?.feriaId;
    const id = req.params.id as string;

    // Verificar propiedad
    const area = await prisma.area.findUnique({ where: { id } });
    if (!area || area.feriaId !== feriaId) {
      return res.status(404).json({ error: 'Área no encontrada o acceso denegado' });
    }

    await prisma.area.delete({ where: { id } });
    res.json({ message: 'Área eliminada exitosamente' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al eliminar área' });
  }
};
