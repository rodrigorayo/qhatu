const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

async function run() {
  try {
    const users = await prisma.user.findMany({
      include: { feria: true }
    });

    console.log('--- USERS IN DATABASE ---');
    users.forEach(user => {
      console.log(`ID: ${user.id}`);
      console.log(`Username: "${user.username}"`);
      console.log(`Role: ${user.role}`);
      console.log(`Feria: ${user.feria ? user.feria.name + ' (ID: ' + user.feria.id + ')' : 'None'}`);
      console.log('------------------------');
    });

    const ferias = await prisma.feria.findMany();
    console.log('--- FERIAS IN DATABASE ---');
    ferias.forEach(f => {
      console.log(`Feria ID: ${f.id}, Name: "${f.name}", Status: ${f.status}`);
    });

  } catch (err) {
    console.error(err);
  } finally {
    await prisma.$disconnect();
  }
}

run();
