import { Router } from 'express';
import { login, createCredentials, initSuperAdmin } from '../controllers/auth.controller';

const router = Router();

// Ruta de inicialización (Solo funciona 1 vez)
router.post('/init-super-admin', initSuperAdmin);

// Ruta pública
router.post('/login', login);

// Ruta protegida (idealmente, deberíamos agregar un middleware aquí que verifique si el req.user.role === 'SUPER_ADMIN' o 'FERIA_ADMIN')
// Por ahora, la definimos para poder probarla
router.post('/create-user', createCredentials);

router.get('/debug-users', async (req, res) => {
  try {
    const { prisma } = require('../index');
    const users = await prisma.user.findMany({ select: { id: true, username: true, role: true, feriaId: true } });
    const ferias = await prisma.feria.findMany({ select: { id: true, name: true } });
    res.json({ users, ferias });
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
