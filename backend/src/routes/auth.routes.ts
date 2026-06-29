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

export default router;
