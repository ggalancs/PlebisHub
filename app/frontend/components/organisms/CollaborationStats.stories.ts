import type { Meta, StoryObj } from '@storybook/vue3'
import CollaborationStats from './CollaborationStats.vue'
import type { Collaboration } from './CollaborationSummary.vue'

const meta = {
  title: 'Organisms/CollaborationStats',
  component: CollaborationStats,
  tags: ['autodocs'],
  argTypes: {
    collaborations: {
      description: 'List of collaborations for stats',
      control: 'object',
    },
    loading: {
      description: 'Loading state',
      control: 'boolean',
    },
    compact: {
      description: 'Compact mode (hide secondary stats)',
      control: 'boolean',
    },
  },
} satisfies Meta<typeof CollaborationStats>

export default meta
type Story = StoryObj<typeof meta>

const baseCollaborations: Collaboration[] = [
  {
    id: '1',
    title: 'Huerto Comunitario',
    description: 'Un proyecto para crear un huerto comunitario en el barrio.',
    type: 'project',
    location: 'Plaza Mayor',
    startDate: '2025-01-15',
    endDate: '2025-06-15',
    minCollaborators: 5,
    maxCollaborators: 20,
    skills: ['Jardinería', 'Agricultura', 'Sostenibilidad'],
    imageUrl: 'https://images.unsplash.com/photo-1592419044706-39796d40f98c?w=400',
    creator: {
      id: 'u1',
      name: 'María García',
      avatar: 'https://i.pravatar.cc/150?img=1',
    },
    currentCollaborators: 10,
    status: 'open',
    createdAt: '2025-01-01',
  },
  {
    id: '2',
    title: 'Festival de Música Local',
    description: 'Organizar un festival de música para artistas locales.',
    type: 'event',
    location: 'Parque Central',
    startDate: '2025-07-20',
    endDate: '2025-07-22',
    minCollaborators: 10,
    maxCollaborators: 30,
    skills: ['Producción', 'Sonido', 'Logística', 'Marketing'],
    imageUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400',
    creator: {
      id: 'u2',
      name: 'Carlos Ruiz',
      avatar: 'https://i.pravatar.cc/150?img=2',
    },
    currentCollaborators: 18,
    status: 'in_progress',
    createdAt: '2025-01-02',
  },
  {
    id: '3',
    title: 'Limpieza del Río',
    description: 'Campaña de limpieza y concienciación sobre la contaminación del río.',
    type: 'campaign',
    location: 'Río Guadalquivir',
    startDate: '2025-03-22',
    endDate: '2025-03-22',
    minCollaborators: 20,
    maxCollaborators: 50,
    skills: ['Organización', 'Redes Sociales', 'Educación Ambiental'],
    imageUrl: 'https://images.unsplash.com/photo-1618477461853-cf6ed80faba5?w=400',
    creator: {
      id: 'u3',
      name: 'Ana López',
      avatar: 'https://i.pravatar.cc/150?img=3',
    },
    currentCollaborators: 45,
    status: 'completed',
    createdAt: '2025-01-03',
  },
  {
    id: '4',
    title: 'Taller de Programación',
    description: 'Taller gratuito de programación para principiantes.',
    type: 'workshop',
    location: 'Centro Cívico',
    startDate: '2025-02-10',
    endDate: '2025-02-10',
    minCollaborators: 2,
    maxCollaborators: 10,
    skills: ['JavaScript', 'Python', 'Enseñanza'],
    imageUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400',
    creator: {
      id: 'u4',
      name: 'Pedro Martínez',
      avatar: 'https://i.pravatar.cc/150?img=4',
    },
    currentCollaborators: 8,
    status: 'completed',
    createdAt: '2025-01-04',
  },
  {
    id: '5',
    title: 'Red de Apoyo Vecinal',
    description: 'Crear una red de apoyo mutuo entre vecinos del barrio.',
    type: 'initiative',
    location: 'Barrio Sur',
    minCollaborators: 3,
    skills: ['Empatía', 'Comunicación', 'Organización'],
    creator: {
      id: 'u5',
      name: 'Laura Sánchez',
      avatar: 'https://i.pravatar.cc/150?img=5',
    },
    currentCollaborators: 5,
    status: 'cancelled',
    createdAt: '2025-01-05',
  },
  {
    id: '6',
    title: 'App de Reciclaje',
    description: 'Desarrollar una aplicación móvil para facilitar el reciclaje en la ciudad.',
    type: 'project',
    minCollaborators: 3,
    maxCollaborators: 8,
    skills: ['React Native', 'Node.js', 'UX/UI', 'JavaScript'],
    imageUrl: 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=400',
    creator: {
      id: 'u6',
      name: 'José Fernández',
      avatar: 'https://i.pravatar.cc/150?img=6',
    },
    currentCollaborators: 6,
    status: 'open',
    createdAt: '2025-01-06',
  },
  {
    id: '7',
    title: 'Clases de Yoga en el Parque',
    description: 'Sesiones de yoga gratuitas al aire libre.',
    type: 'workshop',
    location: 'Parque del Este',
    startDate: '2025-05-01',
    endDate: '2025-09-30',
    minCollaborators: 1,
    maxCollaborators: 5,
    skills: ['Yoga', 'Meditación', 'Bienestar'],
    imageUrl: 'https://images.unsplash.com/photo-1544367567-0f2fcb009e0b?w=400',
    creator: {
      id: 'u7',
      name: 'Carmen Díaz',
      avatar: 'https://i.pravatar.cc/150?img=7',
    },
    currentCollaborators: 3,
    status: 'in_progress',
    createdAt: '2025-01-07',
  },
  {
    id: '8',
    title: 'Campaña de Donación de Sangre',
    description: 'Organizar jornadas de donación de sangre.',
    type: 'campaign',
    location: 'Hospital General',
    startDate: '2025-04-14',
    endDate: '2025-04-14',
    minCollaborators: 5,
    maxCollaborators: 15,
    skills: ['Organización', 'Comunicación', 'Primeros Auxilios'],
    creator: {
      id: 'u8',
      name: 'Miguel Torres',
      avatar: 'https://i.pravatar.cc/150?img=8',
    },
    currentCollaborators: 12,
    status: 'open',
    createdAt: '2025-01-08',
  },
]

/**
 * Default collaboration stats
 */
export const Default: Story = {
  args: {
    collaborations: baseCollaborations,
  },
}

/**
 * Loading state
 */
export const Loading: Story = {
  args: {
    collaborations: baseCollaborations,
    loading: true,
  },
}

/**
 * Compact mode
 */
export const Compact: Story = {
  args: {
    collaborations: baseCollaborations,
    compact: true,
  },
}

/**
 * Empty state
 */
export const Empty: Story = {
  args: {
    collaborations: [],
  },
}

/**
 * Single collaboration
 */
export const Single: Story = {
  args: {
    collaborations: [baseCollaborations[0]],
  },
}

/**
 * Only open collaborations
 */
export const OnlyOpen: Story = {
  args: {
    collaborations: baseCollaborations.filter(c => c.status === 'open'),
  },
}

/**
 * Only completed collaborations
 */
export const OnlyCompleted: Story = {
  args: {
    collaborations: baseCollaborations.filter(c => c.status === 'completed'),
  },
}

/**
 * High activity (many collaborations)
 */
export const HighActivity: Story = {
  args: {
    collaborations: [
      ...baseCollaborations,
      ...baseCollaborations.map((c, i) => ({
        ...c,
        id: `${c.id}-copy-${i}`,
      })),
    ],
  },
}

/**
 * Low activity (few collaborations)
 */
export const LowActivity: Story = {
  args: {
    collaborations: baseCollaborations.slice(0, 2),
  },
}

/**
 * All projects
 */
export const AllProjects: Story = {
  args: {
    collaborations: baseCollaborations.map(c => ({
      ...c,
      type: 'project' as const,
    })),
  },
}

/**
 * All events
 */
export const AllEvents: Story = {
  args: {
    collaborations: baseCollaborations.map(c => ({
      ...c,
      type: 'event' as const,
    })),
  },
}

/**
 * Mixed types
 */
export const MixedTypes: Story = {
  args: {
    collaborations: baseCollaborations,
  },
}

/**
 * Many collaborators
 */
export const ManyCollaborators: Story = {
  args: {
    collaborations: baseCollaborations.map(c => ({
      ...c,
      currentCollaborators: c.maxCollaborators || 50,
    })),
  },
}

/**
 * Few collaborators
 */
export const FewCollaborators: Story = {
  args: {
    collaborations: baseCollaborations.map(c => ({
      ...c,
      currentCollaborators: 2,
    })),
  },
}

/**
 * High completion rate
 */
export const HighCompletionRate: Story = {
  args: {
    collaborations: baseCollaborations.map(c => ({
      ...c,
      status: Math.random() > 0.2 ? ('completed' as const) : ('cancelled' as const),
    })),
  },
}

/**
 * Low completion rate
 */
export const LowCompletionRate: Story = {
  args: {
    collaborations: baseCollaborations.map(c => ({
      ...c,
      status: Math.random() > 0.8 ? ('completed' as const) : ('cancelled' as const),
    })),
  },
}

/**
 * Popular skills - JavaScript ecosystem
 */
export const JavaScriptSkills: Story = {
  args: {
    collaborations: Array(10).fill(null).map((_, i) => ({
      ...baseCollaborations[0],
      id: `js-${i}`,
      skills: ['JavaScript', 'TypeScript', 'React', 'Node.js', 'Vue.js'].slice(0, i % 5 + 1),
    })),
  },
}

/**
 * Popular skills - Design
 */
export const DesignSkills: Story = {
  args: {
    collaborations: Array(10).fill(null).map((_, i) => ({
      ...baseCollaborations[0],
      id: `design-${i}`,
      skills: ['Figma', 'Photoshop', 'Illustrator', 'UX/UI', 'Diseño Gráfico'].slice(0, i % 5 + 1),
    })),
  },
}

/**
 * No skills
 */
export const NoSkills: Story = {
  args: {
    collaborations: baseCollaborations.map(c => ({
      ...c,
      skills: [],
    })),
  },
}

/**
 * Many skills per collaboration
 */
export const ManySkills: Story = {
  args: {
    collaborations: baseCollaborations.map(c => ({
      ...c,
      skills: [
        'JavaScript',
        'TypeScript',
        'Vue.js',
        'React',
        'Node.js',
        'Python',
        'Django',
        'PostgreSQL',
        'Docker',
        'AWS',
        'Git',
        'Scrum',
        'UX/UI',
        'Testing',
        'CI/CD',
      ],
    })),
  },
}

/**
 * All collaborations needing people
 */
export const AllNeedingPeople: Story = {
  args: {
    collaborations: baseCollaborations.map(c => ({
      ...c,
      status: 'open' as const,
      currentCollaborators: 1,
      maxCollaborators: 20,
    })),
  },
}

/**
 * All collaborations full
 */
export const AllFull: Story = {
  args: {
    collaborations: baseCollaborations.map(c => ({
      ...c,
      status: 'open' as const,
      currentCollaborators: 20,
      maxCollaborators: 20,
    })),
  },
}

/**
 * Mixed capacity
 */
export const MixedCapacity: Story = {
  args: {
    collaborations: baseCollaborations,
  },
}

/**
 * Large numbers
 */
export const LargeNumbers: Story = {
  args: {
    collaborations: Array(100).fill(null).map((_, i) => ({
      ...baseCollaborations[i % baseCollaborations.length],
      id: `large-${i}`,
      currentCollaborators: Math.floor(Math.random() * 50) + 10,
    })),
  },
}

/**
 * Real-world scenario - Community center
 */
export const CommunityCenterScenario: Story = {
  args: {
    collaborations: [
      {
        id: '1',
        title: 'Clases de Idiomas',
        description: 'Intercambio de idiomas',
        type: 'workshop',
        skills: ['Inglés', 'Francés', 'Alemán'],
        creator: { id: 'u1', name: 'María' },
        currentCollaborators: 15,
        maxCollaborators: 20,
        status: 'in_progress',
        createdAt: '2025-01-01',
      },
      {
        id: '2',
        title: 'Huerto Urbano',
        description: 'Cultivo comunitario',
        type: 'project',
        skills: ['Jardinería', 'Agricultura'],
        creator: { id: 'u2', name: 'Carlos' },
        currentCollaborators: 12,
        maxCollaborators: 15,
        status: 'open',
        createdAt: '2025-01-02',
      },
      {
        id: '3',
        title: 'Biblioteca Comunitaria',
        description: 'Intercambio de libros',
        type: 'initiative',
        skills: ['Organización', 'Catalogación'],
        creator: { id: 'u3', name: 'Ana' },
        currentCollaborators: 8,
        status: 'completed',
        createdAt: '2025-01-03',
      },
      {
        id: '4',
        title: 'Cine al Aire Libre',
        description: 'Proyecciones mensuales',
        type: 'event',
        skills: ['Técnica', 'Programación'],
        creator: { id: 'u4', name: 'Pedro' },
        currentCollaborators: 6,
        maxCollaborators: 10,
        status: 'in_progress',
        createdAt: '2025-01-04',
      },
      {
        id: '5',
        title: 'Banco de Tiempo',
        description: 'Intercambio de servicios',
        type: 'initiative',
        skills: ['Gestión', 'Comunicación'],
        creator: { id: 'u5', name: 'Laura' },
        currentCollaborators: 20,
        status: 'open',
        createdAt: '2025-01-05',
      },
    ],
  },
}

/**
 * Real-world scenario - Tech community
 */
export const TechCommunityScenario: Story = {
  args: {
    collaborations: [
      {
        id: '1',
        title: 'Hackathon Solidario',
        description: 'Desarrollo de apps para ONGs',
        type: 'event',
        skills: ['JavaScript', 'Python', 'React', 'Node.js'],
        creator: { id: 'u1', name: 'María' },
        currentCollaborators: 45,
        maxCollaborators: 50,
        status: 'completed',
        createdAt: '2025-01-01',
      },
      {
        id: '2',
        title: 'Meetup de Vue.js',
        description: 'Charlas mensuales',
        type: 'workshop',
        skills: ['Vue.js', 'TypeScript', 'Vite'],
        creator: { id: 'u2', name: 'Carlos' },
        currentCollaborators: 8,
        maxCollaborators: 15,
        status: 'in_progress',
        createdAt: '2025-01-02',
      },
      {
        id: '3',
        title: 'Curso de Python',
        description: 'Para principiantes',
        type: 'workshop',
        skills: ['Python', 'Django', 'Enseñanza'],
        creator: { id: 'u3', name: 'Ana' },
        currentCollaborators: 12,
        maxCollaborators: 20,
        status: 'open',
        createdAt: '2025-01-03',
      },
      {
        id: '4',
        title: 'Open Source Fridays',
        description: 'Contribuir a proyectos OSS',
        type: 'initiative',
        skills: ['Git', 'GitHub', 'Open Source'],
        creator: { id: 'u4', name: 'Pedro' },
        currentCollaborators: 15,
        status: 'in_progress',
        createdAt: '2025-01-04',
      },
    ],
  },
}

/**
 * Mobile view
 */
export const MobileView: Story = {
  args: {
    collaborations: baseCollaborations,
  },
  parameters: {
    viewport: {
      defaultViewport: 'mobile1',
    },
  },
}
