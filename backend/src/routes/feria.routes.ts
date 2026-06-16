import { Router } from 'express';
import { getFerias, createFeriaWithAdmin, getMyFeria, updateMyFeria } from '../controllers/feria.controller';
import { authenticateToken, requireRole } from '../middlewares/auth.middleware';

const router = Router();

// Todas las rutas de feria requieren estar autenticado
router.use(authenticateToken);

router.get('/', getFerias);

// Rutas de administración de la propia feria (FERIA_ADMIN)
router.get('/me', requireRole(['FERIA_ADMIN']), getMyFeria);
router.put('/me', requireRole(['FERIA_ADMIN']), updateMyFeria);

// Solo el SUPER_ADMIN puede crear ferias
router.post('/', requireRole(['SUPER_ADMIN']), createFeriaWithAdmin);

export default router;
