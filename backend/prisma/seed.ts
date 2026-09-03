import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding NexaTalk development database...');

  const defaultPasswordHash = await bcrypt.hash('NexaTalkDemo2026!', 10);

  const mockUsers = [
    {
      email: 'alex.morgan@nexatalk.app',
      username: 'alex_morgan',
      displayName: 'Alex Morgan',
      phone: '+15551002001',
      bio: 'Senior Product Designer • Building the future of messaging 🚀',
      status: 'Available',
    },
    {
      email: 'maya.chen@nexatalk.app',
      username: 'maya_chen',
      displayName: 'Maya Chen',
      phone: '+15551002002',
      bio: 'Lead Architect @ NexaLab | Passionate about sleek UIs 🎨',
      status: 'In a meeting',
    },
    {
      email: 'ryan.lee@nexatalk.app',
      username: 'ryan_lee',
      displayName: 'Ryan Lee',
      phone: '+15551002003',
      bio: 'Engineering Lead ⚡ Let’s ship things fast.',
      status: 'Coding...',
    },
    {
      email: 'sophia.reed@nexatalk.app',
      username: 'sophia_reed',
      displayName: 'Sophia Reed',
      phone: '+15551002004',
      bio: 'UX Strategist & Design Systems advocate ✨',
      status: 'Available',
    },
    {
      email: 'noah.carter@nexatalk.app',
      username: 'noah_carter',
      displayName: 'Noah Carter',
      phone: '+15551002005',
      bio: 'Mobile Engineer | Flutter Enthusiast 📱',
      status: 'Away',
    },
    {
      email: 'emma.wilson@nexatalk.app',
      username: 'emma_wilson',
      displayName: 'Emma Wilson',
      phone: '+15551002006',
      bio: 'Product Manager • Connecting people across borders 🌍',
      status: 'Available',
    },
  ];

  const createdUsers: Record<string, any> = {};

  for (const u of mockUsers) {
    const user = await prisma.user.upsert({
      where: { email: u.email },
      update: {
        displayName: u.displayName,
        bio: u.bio,
        status: u.status,
      },
      create: {
        email: u.email,
        username: u.username,
        displayName: u.displayName,
        phone: u.phone,
        bio: u.bio,
        status: u.status,
        passwordHash: defaultPasswordHash,
        profile: {
          create: {
            customStatus: u.status,
            language: 'English (US)',
          },
        },
        authIdentities: {
          create: {
            provider: 'PASSWORD',
            providerUserId: u.email,
          },
        },
      },
    });
    createdUsers[u.username] = user;
  }

  console.log(`✅ Seeded ${mockUsers.length} development users.`);

  // Create Direct Conversation between Alex Morgan and Maya Chen
  const alex = createdUsers['alex_morgan'];
  const maya = createdUsers['maya_chen'];

  if (alex && maya) {
    let conv = await prisma.conversation.findFirst({
      where: {
        type: 'DIRECT',
        AND: [
          { members: { some: { userId: alex.id } } },
          { members: { some: { userId: maya.id } } },
        ],
      },
    });

    if (!conv) {
      conv = await prisma.conversation.create({
        data: {
          type: 'DIRECT',
          members: {
            create: [
              { userId: alex.id, role: 'ADMIN' },
              { userId: maya.id, role: 'MEMBER' },
            ],
          },
        },
      });

      // Add initial messages
      const msg1 = await prisma.message.create({
        data: {
          conversationId: conv.id,
          senderId: maya.id,
          text: 'Hey Alex! Did you get a chance to check the updated dark mode tokens?',
          createdAt: new Date(Date.now() - 3600000),
        },
      });

      const msg2 = await prisma.message.create({
        data: {
          conversationId: conv.id,
          senderId: alex.id,
          text: 'Yes! The midnight turquoise contrast is gorgeous. Let us finalize it.',
          createdAt: new Date(Date.now() - 1800000),
        },
      });

      // Add reaction
      await prisma.messageReaction.create({
        data: {
          messageId: msg2.id,
          userId: maya.id,
          emoji: '🔥',
        },
      });

      console.log('✅ Seeded demo conversation and messages between Alex and Maya.');
    }
  }

  console.log('🎉 Development seed completed.');
}

main()
  .catch((e) => {
    console.error('❌ Seed error:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
