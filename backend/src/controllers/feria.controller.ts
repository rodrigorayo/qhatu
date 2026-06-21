import { Request, Response } from 'express';
import { prisma } from '../index';
import bcrypt from 'bcryptjs';
import { AuthRequest } from '../middlewares/auth.middleware';
import { createSpreadsheet } from '../services/google.service';

export const getFerias = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const userRole = req.user?.role;
    const userFeriaId = req.user?.feriaId;

    let ferias;

    if (userRole === 'SUPER_ADMIN') {
      // El super admin ve todas las ferias
      ferias = await prisma.feria.findMany({
        orderBy: { createdAt: 'desc' },
      });
    } else if (userRole === 'FERIA_ADMIN' && userFeriaId) {
      // El admin de feria solo ve su propia feria
      ferias = await prisma.feria.findMany({
        where: { id: userFeriaId }
      });
    } else {
      return res.status(403).json({ error: 'No autorizado' });
    }

    res.json(ferias);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al obtener ferias' });
  }
};

export const createFeriaWithAdmin = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const { name, description, calculationType, adminUsername, adminPassword, gmail } = req.body;

    // Verificar si el usuario admin de feria ya existe
    const existingUser = await prisma.user.findUnique({
      where: { username: adminUsername }
    });

    if (existingUser) {
      return res.status(400).json({ error: 'El nombre de usuario para el administrador de esta feria ya está en uso' });
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(adminPassword, salt);

    // Usar una transacción para asegurar que ambos se creen, o ninguno.
    const result = await prisma.$transaction(async (tx) => {
      // 1. Crear la Feria
      const nuevaFeria = await tx.feria.create({
        data: {
          name,
          description,
          calculationType: calculationType || 'SUMATIVE',
          status: 'DRAFT',
        }
      });

      // 2. Crear el Usuario FERIA_ADMIN asociado a esta Feria
      const nuevoAdmin = await tx.user.create({
        data: {
          username: adminUsername,
          passwordHash,
          role: 'FERIA_ADMIN',
          feriaId: nuevaFeria.id
        }
      });

      return { feria: nuevaFeria, admin: { id: nuevoAdmin.id, username: nuevoAdmin.username } };
    });

    // Intentar crear el Google Sheet para la feria de forma automática (fuera de la transacción de DB)
    try {
      const sheetsResult = await createSpreadsheet(name, gmail);
      if (sheetsResult) {
        const { spreadsheetId, spreadsheetUrl } = sheetsResult;
        
        // Actualizar la feria con la metadata de Google Sheets
        await prisma.feria.update({
          where: { id: result.feria.id },
          data: {
            metadata: {
              spreadsheetId,
              spreadsheetUrl
            }
          }
        });
        
        // Adjuntar en la respuesta para que la UI de Flutter lo conozca inmediatamente
        (result.feria as any).metadata = { spreadsheetId, spreadsheetUrl };
      }
    } catch (sheetError) {
      console.error('Error al crear Google Sheet para la feria:', sheetError);
    }

    res.status(201).json({
      message: 'Feria y Administrador creados exitosamente',
      data: result
    });

  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al crear la feria y su administrador' });
  }
};

export const getMyFeria = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const userFeriaId = req.user?.feriaId;
    if (!userFeriaId) return res.status(403).json({ error: 'No tienes una feria asignada' });

    const feria = await prisma.feria.findUnique({
      where: { id: userFeriaId }
    });

    if (!feria) return res.status(404).json({ error: 'Feria no encontrada' });

    res.json(feria);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al obtener la feria' });
  }
};

export const updateMyFeria = async (req: AuthRequest, res: Response): Promise<any> => {
  try {
    const userFeriaId = req.user?.feriaId;
    if (!userFeriaId) return res.status(403).json({ error: 'No tienes una feria asignada' });

    const { name, description, startDate, endDate, calculationType, metadata } = req.body;

    const updatedFeria = await prisma.feria.update({
      where: { id: userFeriaId },
      data: {
        name,
        description,
        startDate: startDate ? new Date(startDate) : null,
        endDate: endDate ? new Date(endDate) : null,
        calculationType: calculationType ? calculationType : undefined,
        metadata: metadata ? metadata : undefined,
      }
    });

    res.json(updatedFeria);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al actualizar la feria' });
  }
};

