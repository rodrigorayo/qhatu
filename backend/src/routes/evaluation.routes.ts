import { Router } from 'express';
import { getMyAssignments, getFeriaRubric, syncScores, getFeriaStands } from '../controllers/evaluation.controller';
import { authenticateToken, requireRole } from '../middlewares/auth.middleware';

const router = Router();

// Todas estas rutas son exclusivas para EVALUADORES (o administradores probando la app)
router.use(authenticateToken);
// router.use(requireRole(['EVALUADOR', 'FERIA_ADMIN']));

// --- Rutas de Evaluación ---
router.get('/assignments', getMyAssignments);
router.get('/rubric', getFeriaRubric);
router.get('/stands', getFeriaStands);
router.post('/sync', syncScores);

export default router;
