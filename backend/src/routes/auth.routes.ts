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

router.post('/temp-rename-user', async (req, res) => {
  try {
    const bcrypt = require('bcryptjs');
    const { prisma } = require('../index');
    
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash('englishfair17', salt);

    const user = await prisma.user.findUnique({ where: { username: 'english-fair' } });
    if (user) {
      const updatedUser = await prisma.user.update({
        where: { username: 'english-fair' },
        data: {
          passwordHash: passwordHash,
          role: 'FERIA_ADMIN'
        }
      });
      res.json({ message: 'User password reset successfully', username: updatedUser.username, role: updatedUser.role, feriaId: updatedUser.feriaId });
    } else {
      const updatedUser = await prisma.user.update({
        where: { username: 'ingles' },
        data: {
          username: 'english-fair',
          passwordHash: passwordHash,
          role: 'FERIA_ADMIN'
        }
      });
      res.json({ message: 'User renamed and updated successfully', username: updatedUser.username, role: updatedUser.role, feriaId: updatedUser.feriaId });
    }
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
