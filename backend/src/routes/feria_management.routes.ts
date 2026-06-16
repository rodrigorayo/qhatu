import { Router } from 'express';
import { getAreas, createArea, deleteArea } from '../controllers/area.controller';
import { createCriterion, deleteCriterion } from '../controllers/criterion.controller';
import { getStands, createStand, deleteStand, addMemberToStand, addMembersBatch, updateMember, deleteMember } from '../controllers/stand.controller';
import { createEvaluatorAndAssign } from '../controllers/assignment.controller';
import { authenticateToken, requireRole } from '../middlewares/auth.middleware';

const router = Router();

// Todas estas rutas son exclusivas para el FERIA_ADMIN
router.use(authenticateToken);
router.use(requireRole(['FERIA_ADMIN']));

// --- Rutas de Áreas ---
router.get('/areas', getAreas);
router.post('/areas', createArea);
router.delete('/areas/:id', deleteArea);

// --- Rutas de Criterios ---
router.post('/criteria', createCriterion);
router.delete('/criteria/:id', deleteCriterion);

// --- Rutas de Stands y Miembros ---
router.get('/stands', getStands);
router.post('/stands', createStand);
router.delete('/stands/:id', deleteStand);
router.post('/stands/:id/members', addMemberToStand);
router.post('/stands/:id/members/batch', addMembersBatch);
router.put('/members/:id', updateMember);
router.delete('/members/:id', deleteMember);

// --- Rutas de Asignaciones (Jurados) ---
router.post('/assignments', createEvaluatorAndAssign);

export default router;
