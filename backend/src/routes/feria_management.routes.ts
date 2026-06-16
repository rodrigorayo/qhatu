import { Router } from 'express';
import { getAreas, createArea, deleteArea } from '../controllers/area.controller';
import { createCriterion, deleteCriterion } from '../controllers/criterion.controller';
import { getStands, createStand, deleteStand, addMemberToStand, addMembersBatch, updateMember, deleteMember } from '../controllers/stand.controller';
import { createEvaluatorAndAssign, getEvaluators, deleteAssignment } from '../controllers/assignment.controller';
import { getResults } from '../controllers/evaluation.controller';
import { importSheets, exportResultsCSV } from '../controllers/sheets.controller';
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
router.get('/evaluators', getEvaluators);
router.post('/assignments', createEvaluatorAndAssign);
router.delete('/assignments/:id', deleteAssignment);

// --- Rutas de Resultados y Google Sheets/CSV ---
router.get('/results', getResults);
router.post('/import-sheets', importSheets);
router.get('/export-csv', exportResultsCSV);

export default router;
