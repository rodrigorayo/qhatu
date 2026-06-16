import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  const username = 'admin';
  const password = 'password123'; // Cambiar esto en producción

  const existingAdmin = await prisma.user.findUnique({
    where: { username }
  });

  if (!existingAdmin) {
    const salt = await bcrypt.genSalt(10);
    const passwordHash = await bcrypt.hash(password, salt);

    await prisma.user.create({
      data: {
        username,
        passwordHash,
        role: 'SUPER_ADMIN'
      }
    });

    console.log(`Usuario administrador creado: ${username} / ${password}`);
  } else {
    console.log('El usuario admin ya existe');
  }
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
