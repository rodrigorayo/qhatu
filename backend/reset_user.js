const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');
const prisma = new PrismaClient();

async function main() {
  const salt = await bcrypt.genSalt(10);
  const passwordHash = await bcrypt.hash('pass123', salt);
  
  const updated = await prisma.user.update({
    where: { username: 'jurado1' },
    data: { passwordHash }
  });
  console.log("UPDATED USER:", updated.username);
  await prisma.$disconnect();
}

main().catch(e => {
  console.error(e);
  process.exit(1);
});
