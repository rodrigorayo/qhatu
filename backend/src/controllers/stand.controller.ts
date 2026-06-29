import { Response } from 'express';
import { prisma } from '../index';
import { AuthRequest } from '../middlewares/auth.middleware';

export const getStands = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const feriaId = req.user?.feriaId;
    if (!feriaId) return res.status(403).json({ error: 'No tienes una feria asignada' });

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
      orderBy: { createdAt: 'asc' }
    });

    res.json(stands);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al obtener stands' });
  }
};

export const createStand = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const feriaId = req.user?.feriaId;
    if (!feriaId) return res.status(403).json({ error: 'No tienes una feria asignada' });

    const { name, number, metadata, members } = req.body;

    const newStand = await prisma.stand.create({
      data: {
        name,
        number,
        metadata: metadata || {},
        feriaId,
        members: {
          create: members?.map((m: any) => ({
            fullName: m.fullName,
            metadata: m.metadata || {}
          })) || []
        }
      },
      include: { members: true }
    });

    res.status(201).json(newStand);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al crear stand' });
  }
};

export const deleteStand = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const feriaId = req.user?.feriaId;
    const id = req.params.id as string;

    const stand = await prisma.stand.findUnique({ where: { id } });
    if (!stand || stand.feriaId !== feriaId) {
      return res.status(404).json({ error: 'Stand no encontrado o acceso denegado' });
    }

    await prisma.stand.delete({ where: { id } });
    res.json({ message: 'Stand eliminado exitosamente' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al eliminar stand' });
  }
};

export const addMemberToStand = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const feriaId = req.user?.feriaId;
    const standId = req.params.id as string;
    const { fullName, metadata } = req.body;

    if (!fullName) return res.status(400).json({ error: 'El nombre completo es requerido' });

    // Verificar que el stand pertenezca a la feria del usuario
    const stand = await prisma.stand.findUnique({ where: { id: standId } });
    if (!stand || stand.feriaId !== feriaId) {
      return res.status(404).json({ error: 'Stand no encontrado o acceso denegado' });
    }

    const newMember = await prisma.member.create({
      data: {
        standId,
        fullName,
        metadata: metadata || {}
      }
    });

    res.status(201).json(newMember);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al añadir miembro al stand' });
  }
};

export const addMembersBatch = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const feriaId = req.user?.feriaId;
    const standId = req.params.id as string;
    const { names } = req.body; // names must be an array of strings

    if (!names || !Array.isArray(names) || names.length === 0) {
      return res.status(400).json({ error: 'Se requiere una lista de nombres' });
    }

    const stand = await prisma.stand.findUnique({ where: { id: standId } });
    if (!stand || stand.feriaId !== feriaId) {
      return res.status(404).json({ error: 'Stand no encontrado o acceso denegado' });
    }

    const dataToInsert = names.map((name: string) => ({
      standId,
      fullName: name.trim(),
      metadata: {}
    })).filter(n => n.fullName.length > 0);

    if (dataToInsert.length === 0) {
      return res.status(400).json({ error: 'Nombres inválidos' });
    }

    const result = await prisma.member.createMany({
      data: dataToInsert
    });

    res.status(201).json({ message: 'Miembros añadidos exitosamente', count: result.count });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al añadir miembros de forma masiva' });
  }
};

export const updateMember = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const feriaId = req.user?.feriaId;
    const memberId = req.params.id as string;
    const { fullName, metadata } = req.body;

    const member = await prisma.member.findUnique({
      where: { id: memberId },
      include: { stand: true }
    });

    if (!member || member.stand.feriaId !== feriaId) {
      return res.status(404).json({ error: 'Miembro no encontrado o acceso denegado' });
    }

    const updatedMember = await prisma.member.update({
      where: { id: memberId },
      data: { fullName, metadata: metadata ?? member.metadata }
    });

    res.json(updatedMember);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al actualizar miembro' });
  }
};

export const deleteMember = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const feriaId = req.user?.feriaId;
    const memberId = req.params.id as string;

    const member = await prisma.member.findUnique({
      where: { id: memberId },
      include: { stand: true }
    });

    if (!member || member.stand.feriaId !== feriaId) {
      return res.status(404).json({ error: 'Miembro no encontrado o acceso denegado' });
    }

    await prisma.member.delete({ where: { id: memberId } });
    res.json({ message: 'Miembro eliminado' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al eliminar miembro' });
  }
};

export const updateStand = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const feriaId = req.user?.feriaId;
    const standId = req.params.id as string;
    const { number, name, metadata } = req.body;

    const stand = await prisma.stand.findUnique({
      where: { id: standId }
    });

    if (!stand || stand.feriaId !== feriaId) {
      return res.status(404).json({ error: 'Stand no encontrado o acceso denegado' });
    }

    const updatedStand = await prisma.stand.update({
      where: { id: standId },
      data: {
        number: number ?? stand.number,
        name: name ?? stand.name,
        metadata: metadata !== undefined ? metadata : stand.metadata
      }
    });

    res.json(updatedStand);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al actualizar stand' });
  }
};

