import type { Meta, StoryObj } from '@storybook/vue3'
import CollaborationSummary from './CollaborationSummary.vue'
import type { Collaboration } from './CollaborationSummary.vue'

const meta = {
  title: 'Organisms/CollaborationSummary',
  component: CollaborationSummary,
  tags: ['autodocs'],
  argTypes: {
    collaboration: {
      description: 'Collaboration data',
      control: 'object',
    },
    loading: {
      description: 'Loading state',
      control: 'boolean',
    },
    showActions: {
      description: 'Show action buttons',
      control: 'boolean',
    },
    onJoin: { action: 'join' },
    onLeave: { action: 'leave' },
    onContact: { action: 'contact' },
    onEdit: { action: 'edit' },
    onDelete: { action: 'delete' },
  },
} satisfies Meta<typeof CollaborationSummary>

export default meta
type Story = StoryObj<typeof meta>

const baseCollaboration: Collaboration = {
  id: '1',
  title: 'Huerto Comunitario',
  description: 'Un proyecto para crear un huerto comunitario en el barrio. Buscamos personas interesadas en agricultura sostenible y permacultura.',
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
  updatedAt: '2025-01-05',
}

/**
 * Default collaboration summary
 */
export const Default: Story = {
  args: {
    collaboration: baseCollaboration,
  },
}

/**
 * Loading state
 */
export const Loading: Story = {
  args: {
    collaboration: baseCollaboration,
    loading: true,
  },
}

/**
 * Without actions
 */
export const WithoutActions: Story = {
  args: {
    collaboration: baseCollaboration,
    showActions: false,
  },
}

/**
 * Project type collaboration
 */
export const ProjectType: Story = {
  args: {
    collaboration: {
      ...baseCollaboration,
      type: 'project',
      title: 'App de Reciclaje',
      description: 'Desarrollar una aplicación móvil para facilitar el reciclaje en la ciudad.',
      skills: ['React Native', 'Node.js', 'UX/UI'],
      imageUrl: 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=400',
    },
  },
}

/**
 * Initiative type collaboration
 */
export const InitiativeType: Story = {
  args: {
    collaboration: {
      ...baseCollaboration,
      type: 'initiative',
      title: 'Reducción de Plásticos',
      description: 'Iniciativa para reducir el uso de plásticos de un solo uso en el barrio.',
      skills: ['Comunicación', 'Organización', 'Activismo'],
      imageUrl: 'https://images.unsplash.com/photo-1528323273322-d81458248d40?w=400',
    },
  },
}

/**
 * Event type collaboration
 */
export const EventType: Story = {
  args: {
    collaboration: {
      ...baseCollaboration,
      type: 'event',
      title: 'Festival de Música Local',
      description: 'Organizar un festival de música para artistas locales.',
      startDate: '2025-07-20',
      endDate: '2025-07-22',
      skills: ['Producción', 'Sonido', 'Logística'],
      imageUrl: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400',
    },
  },
}

/**
 * Campaign type collaboration
 */
export const CampaignType: Story = {
  args: {
    collaboration: {
      ...baseCollaboration,
      type: 'campaign',
      title: 'Limpieza del Río',
      description: 'Campaña de limpieza y concienciación sobre la contaminación del río.',
      skills: ['Organización', 'Redes Sociales', 'Educación Ambiental'],
      imageUrl: 'https://images.unsplash.com/photo-1618477461853-cf6ed80faba5?w=400',
    },
  },
}

/**
 * Workshop type collaboration
 */
export const WorkshopType: Story = {
  args: {
    collaboration: {
      ...baseCollaboration,
      type: 'workshop',
      title: 'Taller de Programación',
      description: 'Taller gratuito de programación para principiantes.',
      startDate: '2025-02-10',
      endDate: '2025-02-10',
      minCollaborators: 2,
      maxCollaborators: 10,
      skills: ['JavaScript', 'Python', 'Enseñanza'],
      imageUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=400',
    },
  },
}

/**
 * Other type collaboration
 */
export const OtherType: Story = {
  args: {
    collaboration: {
      ...baseCollaboration,
      type: 'other',
      title: 'Red de Apoyo Vecinal',
      description: 'Crear una red de apoyo mutuo entre vecinos del barrio.',
      skills: ['Empatía', 'Comunicación', 'Organización'],
    },
  },
}

/**
 * Open status (can join)
 */
export const OpenStatus: Story = {
  args: {
    collaboration: {
      ...baseCollaboration,
      status: 'open',
      currentCollaborators: 8,
    },
  },
}

/**
 * In progress status (can leave)
 */
export const InProgressStatus: Story = {
  args: {
    collaboration: {
      ...baseCollaboration,
      status: 'in_progress',
      currentCollaborators: 15,
    },
  },
}

/**
 * Completed status
 */
export const CompletedStatus: Story = {
  args: {
    collaboration: {
      ...baseCollaboration,
      status: 'completed',
      currentCollaborators: 18,
    },
  },
}

/**
 * Cancelled status
 */
export const CancelledStatus: Story = {
  args: {
    collaboration: {
      ...baseCollaboration,
      status: 'cancelled',
      currentCollaborators: 5,
    },
  },
}

/**
 * Almost full (yellow progress)
 */
export const AlmostFull: Story = {
  args: {
    collaboration: {
      ...baseCollaboration,
      currentCollaborators: 17,
      maxCollaborators: 20,
    },
  },
}

/**
 * Full capacity (red progress)
 */
export const FullCapacity: Story = {
  args: {
    collaboration: {
      ...baseCollaboration,
      currentCollaborators: 20,
      maxCollaborators: 20,
    },
  },
}

/**
 * Low participation (green progress)
 */
export const LowParticipation: Story = {
  args: {
    collaboration: {
      ...baseCollaboration,
      currentCollaborators: 3,
      maxCollaborators: 20,
    },
  },
}

/**
 * Without image
 */
export const WithoutImage: Story = {
  args: {
    collaboration: {
      ...baseCollaboration,
      imageUrl: undefined,
    },
  },
}

/**
 * Without location
 */
export const WithoutLocation: Story = {
  args: {
    collaboration: {
      ...baseCollaboration,
      location: undefined,
    },
  },
}

/**
 * Without dates
 */
export const WithoutDates: Story = {
  args: {
    collaboration: {
      ...baseCollaboration,
      startDate: undefined,
      endDate: undefined,
    },
  },
}

/**
 * Without collaborator limits
 */
export const WithoutLimits: Story = {
  args: {
    collaboration: {
      ...baseCollaboration,
      minCollaborators: undefined,
      maxCollaborators: undefined,
    },
  },
}

/**
 * Without skills
 */
export const WithoutSkills: Story = {
  args: {
    collaboration: {
      ...baseCollaboration,
      skills: [],
    },
  },
}

/**
 * Many skills
 */
export const ManySkills: Story = {
  args: {
    collaboration: {
      ...baseCollaboration,
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
    },
  },
}

/**
 * Long description
 */
export const LongDescription: Story = {
  args: {
    collaboration: {
      ...baseCollaboration,
      description: `Este es un proyecto ambicioso que busca crear un huerto comunitario en el centro del barrio.

El objetivo principal es promover la agricultura urbana sostenible y crear un espacio de encuentro para la comunidad.

Actividades planificadas:
- Preparación del terreno
- Construcción de bancales elevados
- Sistema de riego por goteo
- Talleres de permacultura
- Eventos comunitarios

Buscamos personas con diferentes habilidades: desde jardinería y agricultura hasta carpintería, fontanería y educación ambiental.

Todos los participantes tendrán acceso a los productos cultivados y participarán en la toma de decisiones del proyecto.`,
    },
  },
}

/**
 * Minimal information
 */
export const MinimalInfo: Story = {
  args: {
    collaboration: {
      id: '1',
      title: 'Proyecto Simple',
      description: 'Una descripción básica del proyecto.',
      type: 'project',
      skills: [],
      creator: {
        id: 'u1',
        name: 'Usuario',
      },
      currentCollaborators: 1,
      status: 'open',
      createdAt: '2025-01-01',
    },
  },
}

/**
 * Complete information
 */
export const CompleteInfo: Story = {
  args: {
    collaboration: baseCollaboration,
  },
}

/**
 * Without updated date
 */
export const WithoutUpdatedDate: Story = {
  args: {
    collaboration: {
      ...baseCollaboration,
      updatedAt: undefined,
    },
  },
}

/**
 * Interactive - join workflow
 */
export const InteractiveJoin: Story = {
  args: {
    collaboration: {
      ...baseCollaboration,
      status: 'open',
      currentCollaborators: 10,
    },
  },
  render: (args) => ({
    components: { CollaborationSummary },
    setup() {
      return { args }
    },
    template: `
      <div>
        <CollaborationSummary
          v-bind="args"
          @join="onJoin"
          @contact="onContact"
          @edit="onEdit"
          @delete="onDelete"
        />
      </div>
    `,
    methods: {
      onJoin() {
        alert('¡Te has unido a la colaboración!')
      },
      onContact() {
        alert('Abriendo chat con el creador...')
      },
      onEdit() {
        alert('Abriendo formulario de edición...')
      },
      onDelete() {
        if (confirm('¿Estás seguro de que quieres eliminar esta colaboración?')) {
          alert('Colaboración eliminada')
        }
      },
    },
  }),
}

/**
 * Interactive - leave workflow
 */
export const InteractiveLeave: Story = {
  args: {
    collaboration: {
      ...baseCollaboration,
      status: 'in_progress',
      currentCollaborators: 15,
    },
  },
  render: (args) => ({
    components: { CollaborationSummary },
    setup() {
      return { args }
    },
    template: `
      <div>
        <CollaborationSummary
          v-bind="args"
          @leave="onLeave"
          @contact="onContact"
          @edit="onEdit"
          @delete="onDelete"
        />
      </div>
    `,
    methods: {
      onLeave() {
        if (confirm('¿Estás seguro de que quieres abandonar esta colaboración?')) {
          alert('Has abandonado la colaboración')
        }
      },
      onContact() {
        alert('Abriendo chat con el creador...')
      },
      onEdit() {
        alert('Abriendo formulario de edición...')
      },
      onDelete() {
        if (confirm('¿Estás seguro de que quieres eliminar esta colaboración?')) {
          alert('Colaboración eliminada')
        }
      },
    },
  }),
}

/**
 * Multiple collaborations comparison
 */
export const MultipleComparison: Story = {
  render: () => ({
    components: { CollaborationSummary },
    setup() {
      const collaborations: Collaboration[] = [
        {
          ...baseCollaboration,
          id: '1',
          title: 'Huerto Comunitario',
          type: 'project',
          currentCollaborators: 10,
          status: 'open',
        },
        {
          ...baseCollaboration,
          id: '2',
          title: 'Festival de Música',
          type: 'event',
          currentCollaborators: 18,
          maxCollaborators: 20,
          status: 'in_progress',
        },
        {
          ...baseCollaboration,
          id: '3',
          title: 'Limpieza del Río',
          type: 'campaign',
          currentCollaborators: 25,
          maxCollaborators: 30,
          status: 'completed',
        },
      ]
      return { collaborations }
    },
    template: `
      <div class="space-y-6">
        <CollaborationSummary
          v-for="collaboration in collaborations"
          :key="collaboration.id"
          :collaboration="collaboration"
        />
      </div>
    `,
  }),
}

/**
 * Mobile view
 */
export const MobileView: Story = {
  args: {
    collaboration: baseCollaboration,
  },
  parameters: {
    viewport: {
      defaultViewport: 'mobile1',
    },
  },
}
