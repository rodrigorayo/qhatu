import { FeriaRepository } from '../repositories/feria.repository';
import { Prisma } from '@prisma/client';

export class FeriaService {
  private repository: FeriaRepository;

  constructor() {
    this.repository = new FeriaRepository();
  }

  async getAllFerias() {
    return this.repository.findAll();
  }

  async createFeria(data: any) {
    // Aquí podemos agregar validaciones de negocio
    // Por ejemplo, asegurar que el template tenga un formato válido
    const feriaData: Prisma.FeriaCreateInput = {
      name: data.name,
      description: data.description,
      calculationType: data.calculationType,
      status: data.status,
      startDate: data.startDate ? new Date(data.startDate) : null,
      endDate: data.endDate ? new Date(data.endDate) : null,
      formTemplate: data.formTemplate ?? null,
      metadata: data.metadata ?? null,
    };
    
    return this.repository.create(feriaData);
  }
}
