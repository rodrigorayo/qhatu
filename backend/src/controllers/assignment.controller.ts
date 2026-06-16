import { Response } from 'express';
import { prisma } from '../index';
import bcrypt from 'bcryptjs';
import { AuthRequest } from '../middlewares/auth.middleware';

export const createEvaluatorAndAssign = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const feriaId = req.user?.feriaId;
    if (!feriaId) return res.status(403).json({ error: 'No tienes una feria asignada' });

    const { username, password, standId, roleInStand } = req.body;

    // Verificar que el stand pertenece a la feria
    const stand = await prisma.stand.findUnique({ where: { id: standId } });
    if (!stand || stand.feriaId !== feriaId) {
      return res.status(400).json({ error: 'Stand inválido para esta feria' });
    }

    // Buscar si el usuario ya existe, sino crearlo
    let evaluador = await prisma.user.findUnique({ where: { username } });

    if (!evaluador) {
      const salt = await bcrypt.genSalt(10);
      const passwordHash = await bcrypt.hash(password, salt);

      evaluador = await prisma.user.create({
        data: {
          username,
          passwordHash,
          role: 'EVALUADOR',
          feriaId
        }
      });
    } else {
      // Si existe, verificar que pertenezca a esta feria
      if (evaluador.feriaId !== feriaId) {
        return res.status(400).json({ error: 'Este usuario pertenece a otra feria' });
      }
    }

    // Crear la asignación
    const assignment = await prisma.assignment.create({
      data: {
        userId: evaluador.id,
        standId,
        roleInStand: roleInStand || 'JURADO'
      }
    });

    res.status(201).json({ message: 'Evaluador asignado con éxito', assignment });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al asignar evaluador' });
  }
};
