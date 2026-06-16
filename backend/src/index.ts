import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { PrismaClient } from '@prisma/client';

dotenv.config();

const app = express();
export const prisma = new PrismaClient();

app.use(cors());
app.use(express.json());

import authRoutes from './routes/auth.routes';
import feriaRoutes from './routes/feria.routes';
import managementRoutes from './routes/feria_management.routes';
import evaluationRoutes from './routes/evaluation.routes';

// Rutas básicas
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'API funcionando correctamente' });
});

app.use('/api/auth', authRoutes);
app.use('/api/ferias', feriaRoutes);
app.use('/api/management', managementRoutes);
app.use('/api/evaluation', evaluationRoutes);

const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});
