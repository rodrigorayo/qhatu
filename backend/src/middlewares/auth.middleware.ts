import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

const JWT_SECRET = process.env.JWT_SECRET || 'super_secret_jwt_key_qhatu_2026';

export interface AuthRequest extends Request {
  user?: {
    id: string;
    username: string;
    role: string;
    feriaId: string | null;
  };
}

export const authenticateToken = (req: AuthRequest, res: Response, next: NextFunction): void => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    res.status(401).json({ error: 'Acceso denegado. No hay token.' });
    return;
  }

  jwt.verify(token, JWT_SECRET, (err, user: any) => {
    if (err) {
      res.status(403).json({ error: 'Token inválido o expirado.' });
      return;
    }
    req.user = user;
    next();
  });
};

export const requireRole = (roles: string[]) => {
  return (req: AuthRequest, res: Response, next: NextFunction): void => {
    if (!req.user || !roles.includes(req.user.role)) {
      res.status(403).json({ error: 'No tienes permisos suficientes para realizar esta acción.' });
      return;
    }
    next();
  };
};
