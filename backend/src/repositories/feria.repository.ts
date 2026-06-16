import { Prisma } from '@prisma/client';
import { prisma } from '../index';

export class FeriaRepository {
  async findAll() {
    return prisma.feria.findMany({
      include: {
        areas: { include: { criteria: true } },
        stands: true
      }
    });
  }

  async findById(id: string) {
    return prisma.feria.findUnique({
      where: { id },
      include: {
        areas: { include: { criteria: true } },
        stands: { include: { members: true } }
      }
    });
  }

  async create(data: Prisma.FeriaCreateInput) {
    return prisma.feria.create({ data });
  }

  async update(id: string, data: Prisma.FeriaUpdateInput) {
    return prisma.feria.update({
      where: { id },
      data
    });
  }
}
