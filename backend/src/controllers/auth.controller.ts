import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { prisma } from '../index';

const JWT_SECRET = process.env.JWT_SECRET || 'super_secret_jwt_key_qhatu_2026';

export const login = async (req: Request, res: Response): Promise<any> => {
  try {
    const { username, password } = req.body;

    const user = await prisma.user.findUnique({
      where: { username }
    });

    if (!user) {
      return res.status(401).json({ error: 'Credenciales inválidas' });
    }

    const isMatch = await bcrypt.compare(password, user.passwordHash);

    if (!isMatch) {
      return res.status(401).json({ error: 'Credenciales inválidas' });
    }

    const token = jwt.sign(
      { id: user.id, role: user.role, username: user.username, feriaId: user.feriaId },
      JWT_SECRET,
      { expiresIn: '7d' } // El token dura 7 días
    );

    res.json({
      message: 'Login exitoso',
      token,
      user: {
        id: user.id,
        username: user.username,
        role: user.role,
        feriaId: user.feriaId
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
};

export const createCredentials = async (req: Request, res: Response): Promise<any> => {
  try {
    // Aquí asumimos que esto está protegido por un middleware de Admin
    const { username, password, role, feriaId } = req.body;

    // Verificar si ya existe
    const existingUser = await prisma.user.findUnique({
      where: { username }
    });

    if (existingUser) {
      return res.status(400).json({ error: 'El nombre de usuario ya está en uso' });
    }

    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    const newUser = await prisma.user.create({
      data: {
        username,
        passwordHash,
        role: role || 'EVALUADOR',
        feriaId: feriaId || null
      }
    });

    res.status(201).json({
      message: 'Usuario creado exitosamente',
      user: {
        id: newUser.id,
        username: newUser.username,
        role: newUser.role,
        feriaId: newUser.feriaId
      }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al crear el usuario' });
  }
};

export const initSuperAdmin = async (req: Request, res: Response): Promise<any> => {
  try {
    const userCount = await prisma.user.count();
    if (userCount > 0) {
      return res.status(403).json({ error: 'El Super Admin ya ha sido inicializado.' });
    }

    const { username, password } = req.body;
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    const superAdmin = await prisma.user.create({
      data: {
        username,
        passwordHash,
        role: 'SUPER_ADMIN'
      }
    });

    res.status(201).json({
      message: 'Super Admin creado exitosamente',
      user: { id: superAdmin.id, username: superAdmin.username, role: superAdmin.role }
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error al crear el super admin' });
  }
};
