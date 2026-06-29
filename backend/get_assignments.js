const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function run() {
  try {
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
            username: true,
            role: true
          }
        }
      }
    });

    console.log('--- FERIAS AND STATS ---');
    for (const f of ferias) {
      const assignmentsCount = await prisma.assignment.count({
        where: { stand: { feriaId: f.id } }
      });
      console.log(`Feria: "${f.name}" (ID: ${f.id})`);
      console.log(`  Stands: ${f._count.stands}`);
      console.log(`  Areas: ${f._count.areas}`);
      console.log(`  Assignments (Evaluators assigned): ${assignmentsCount}`);
      console.log(`  Admin Users:`, f.users.filter(u => u.role === 'FERIA_ADMIN').map(u => u.username));
      console.log('------------------------');
    }

  } catch (err) {
    console.error(err);
  } finally {
    await prisma.$disconnect();
  }
}

run();
