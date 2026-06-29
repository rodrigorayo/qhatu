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

router.get('/debug-assignments', async (req, res) => {
  try {
    const { prisma } = require('../index');
    const ferias = await prisma.feria.findMany({
      include: {
        _count: {
          select: {
            stands: true,
            areas: true
          }
        },
        users: {
          select: {
            id: true,
            username: true,
            role: true
          }
        }
      }
    });

    const results = [];
    for (const f of ferias) {
      const assignmentsCount = await prisma.assignment.count({
        where: { stand: { feriaId: f.id } }
      });
      const evaluators = await prisma.user.findMany({
        where: { role: 'EVALUADOR', feriaId: f.id },
        select: { username: true }
      });
      results.push({
        id: f.id,
        name: f.name,
        standsCount: f._count.stands,
        areasCount: f._count.areas,
        assignmentsCount,
        evaluators: evaluators.map((e: any) => e.username),
        admins: f.users.filter((u: any) => u.role === 'FERIA_ADMIN').map((u: any) => u.username)
      });
    }
    res.json(results);
  } catch (err: any) {
    res.status(500).json({ error: err.message });
  }
});

export default router;
