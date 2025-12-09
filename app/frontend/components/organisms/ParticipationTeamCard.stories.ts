import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import ParticipationTeamCard from './ParticipationTeamCard.vue'
import type { ParticipationTeam } from './ParticipationTeamCard.vue'

const meta = {
  title: 'Organisms/ParticipationTeamCard',
  component: ParticipationTeamCard,
  tags: ['autodocs'],
  argTypes: {
    team: {
      control: 'object',
      description: 'Team data',
    },
    showJoinButton: {
      control: 'boolean',
      description: 'Show join button',
    },
    showLeaveButton: {
      control: 'boolean',
      description: 'Show leave button',
    },
    isMember: {
      control: 'boolean',
      description: 'User is member',
    },
    isLeader: {
      control: 'boolean',
      description: 'User is leader',
    },
    compact: {
      control: 'boolean',
      description: 'Compact mode',
    },
    loading: {
      control: 'boolean',
      description: 'Loading state',
    },
    disabled: {
      control: 'boolean',
      description: 'Disabled state',
    },
  },
} satisfies Meta<typeof ParticipationTeamCard>

export default meta
type Story = StoryObj<typeof meta>

const mockTeam: ParticipationTeam = {
  id: '1',
  name: 'Equipo de Medio Ambiente',
  description: 'Trabajamos en iniciativas para mejorar el medio ambiente local y promover prácticas sostenibles',
  leader: {
    id: 'leader-1',
    name: 'María González',
    avatar: 'https://i.pravatar.cc/150?img=1',
    role: 'Coordinadora',
  },
  memberCount: 8,
  maxMembers: 15,
  status: 'recruiting',
  activityLevel: 'high',
  tags: ['Medio Ambiente', 'Sostenibilidad', 'Comunidad'],
  meetingSchedule: 'Jueves 18:00',
  lastActivity: '2024-01-15',
  createdAt: '2023-12-01',
  imageUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800&h=400&fit=crop',
}

export const Default: Story = {
  args: {
    team: mockTeam,
  },
}

export const AsMember: Story = {
  args: {
    team: mockTeam,
    isMember: true,
  },
}

export const AsLeader: Story = {
  args: {
    team: mockTeam,
    isMember: true,
    isLeader: true,
  },
}

export const StatusActive: Story = {
  args: {
    team: {
      ...mockTeam,
      status: 'active',
    },
  },
}

export const StatusRecruiting: Story = {
  args: {
    team: {
      ...mockTeam,
      status: 'recruiting',
    },
  },
}

export const StatusFull: Story = {
  args: {
    team: {
      ...mockTeam,
      memberCount: 15,
      maxMembers: 15,
      status: 'full',
    },
  },
}

export const StatusInactive: Story = {
  args: {
    team: {
      ...mockTeam,
      status: 'inactive',
    },
  },
}

export const ActivityHigh: Story = {
  args: {
    team: {
      ...mockTeam,
      activityLevel: 'high',
    },
  },
}

export const ActivityMedium: Story = {
  args: {
    team: {
      ...mockTeam,
      activityLevel: 'medium',
    },
  },
}

export const ActivityLow: Story = {
  args: {
    team: {
      ...mockTeam,
      activityLevel: 'low',
    },
  },
}

export const NoActivityLevel: Story = {
  args: {
    team: {
      ...mockTeam,
      activityLevel: undefined,
    },
  },
}

export const NoMaxMembers: Story = {
  args: {
    team: {
      ...mockTeam,
      maxMembers: undefined,
    },
  },
}

export const NoImage: Story = {
  args: {
    team: {
      ...mockTeam,
      imageUrl: undefined,
    },
  },
}

export const NoMeetingSchedule: Story = {
  args: {
    team: {
      ...mockTeam,
      meetingSchedule: undefined,
    },
  },
}

export const NoTags: Story = {
  args: {
    team: {
      ...mockTeam,
      tags: [],
    },
  },
}

export const ManyTags: Story = {
  args: {
    team: {
      ...mockTeam,
      tags: ['Medio Ambiente', 'Sostenibilidad', 'Comunidad', 'Reciclaje', 'Biodiversidad', 'Energías Renovables'],
    },
  },
}

export const AlmostFull: Story = {
  args: {
    team: {
      ...mockTeam,
      memberCount: 14,
      maxMembers: 15,
    },
  },
}

export const SmallTeam: Story = {
  args: {
    team: {
      ...mockTeam,
      memberCount: 3,
      maxMembers: 5,
    },
  },
}

export const LargeTeam: Story = {
  args: {
    team: {
      ...mockTeam,
      memberCount: 45,
      maxMembers: 50,
    },
  },
}

export const Compact: Story = {
  args: {
    team: mockTeam,
    compact: true,
  },
}

export const Loading: Story = {
  args: {
    team: mockTeam,
    loading: true,
  },
}

export const Disabled: Story = {
  args: {
    team: mockTeam,
    disabled: true,
  },
}

export const NoButtons: Story = {
  args: {
    team: mockTeam,
    showJoinButton: false,
    showLeaveButton: false,
  },
}

export const Interactive: Story = {
  render: () => ({
    components: { ParticipationTeamCard },
    setup() {
      const team = ref<ParticipationTeam>({ ...mockTeam })
      const isMember = ref(false)
      const isLeader = ref(false)

      const handleJoin = (teamId: string) => {
        console.log('Joining team:', teamId)
        isMember.value = true
        team.value.memberCount++
        alert(`¡Te has unido a ${team.value.name}!`)
      }

      const handleLeave = (teamId: string) => {
        console.log('Leaving team:', teamId)
        if (confirm('¿Estás seguro de que quieres salir del equipo?')) {
          isMember.value = false
          isLeader.value = false
          team.value.memberCount--
          alert('Has salido del equipo')
        }
      }

      const handleViewDetails = (teamId: string) => {
        console.log('Viewing details for team:', teamId)
        alert('Abriendo detalles del equipo...')
      }

      const handleContactLeader = (leaderId: string) => {
        console.log('Contacting leader:', leaderId)
        alert(`Enviando mensaje a ${team.value.leader.name}...`)
      }

      return {
        team,
        isMember,
        isLeader,
        handleJoin,
        handleLeave,
        handleViewDetails,
        handleContactLeader,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Tarjeta de Equipo Interactiva</h2>
        <p class="text-sm text-gray-600 mb-6">
          Estado: {{ isMember ? (isLeader ? 'Líder' : 'Miembro') : 'No miembro' }}
        </p>
        <ParticipationTeamCard
          :team="team"
          :is-member="isMember"
          :is-leader="isLeader"
          @join="handleJoin"
          @leave="handleLeave"
          @view-details="handleViewDetails"
          @contact-leader="handleContactLeader"
        />
      </div>
    `,
  }),
  args: {},
}

export const DifferentTeams: Story = {
  render: () => ({
    components: { ParticipationTeamCard },
    setup() {
      const teams: ParticipationTeam[] = [
        {
          id: '1',
          name: 'Equipo de Educación',
          description: 'Trabajamos en mejorar la educación en nuestra comunidad',
          leader: {
            id: 'l1',
            name: 'Pedro Martínez',
            avatar: 'https://i.pravatar.cc/150?img=12',
            role: 'Coordinador',
          },
          memberCount: 12,
          maxMembers: 20,
          status: 'active',
          activityLevel: 'high',
          tags: ['Educación', 'Comunidad'],
          meetingSchedule: 'Lunes 17:00',
          lastActivity: '2024-01-18',
        },
        {
          id: '2',
          name: 'Equipo de Cultura',
          description: 'Promovemos actividades culturales y artísticas',
          leader: {
            id: 'l2',
            name: 'Ana López',
            avatar: 'https://i.pravatar.cc/150?img=5',
            role: 'Coordinadora',
          },
          memberCount: 6,
          maxMembers: 10,
          status: 'recruiting',
          activityLevel: 'medium',
          tags: ['Cultura', 'Arte', 'Música'],
          meetingSchedule: 'Martes 19:00',
          lastActivity: '2024-01-10',
        },
        {
          id: '3',
          name: 'Equipo de Tecnología',
          description: 'Desarrollamos soluciones tecnológicas para problemas locales',
          leader: {
            id: 'l3',
            name: 'Carlos Ruiz',
            avatar: 'https://i.pravatar.cc/150?img=8',
            role: 'Coordinador',
          },
          memberCount: 15,
          maxMembers: 15,
          status: 'full',
          activityLevel: 'high',
          tags: ['Tecnología', 'Innovación', 'Programación'],
          meetingSchedule: 'Viernes 18:30',
          lastActivity: '2024-01-17',
        },
        {
          id: '4',
          name: 'Equipo de Deporte',
          description: 'Organizamos actividades deportivas para todas las edades',
          leader: {
            id: 'l4',
            name: 'Laura Sánchez',
            avatar: 'https://i.pravatar.cc/150?img=9',
            role: 'Coordinadora',
          },
          memberCount: 3,
          maxMembers: 12,
          status: 'inactive',
          activityLevel: 'low',
          tags: ['Deporte', 'Salud'],
          lastActivity: '2023-12-01',
        },
      ]
      return { teams }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Diferentes Equipos</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <ParticipationTeamCard
            v-for="team in teams"
            :key="team.id"
            :team="team"
          />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const AllStatuses: Story = {
  render: () => ({
    components: { ParticipationTeamCard },
    setup() {
      const statuses: Array<{ status: 'active' | 'recruiting' | 'full' | 'inactive'; memberCount: number }> = [
        { status: 'active', memberCount: 8 },
        { status: 'recruiting', memberCount: 5 },
        { status: 'full', memberCount: 15 },
        { status: 'inactive', memberCount: 3 },
      ]
      return { statuses, mockTeam }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Todos los Estados</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div v-for="({ status, memberCount }, index) in statuses" :key="index">
            <h3 class="font-semibold mb-3 capitalize">{{ status }}</h3>
            <ParticipationTeamCard
              :team="{ ...mockTeam, status, memberCount }"
            />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const AllActivityLevels: Story = {
  render: () => ({
    components: { ParticipationTeamCard },
    setup() {
      const levels: Array<'high' | 'medium' | 'low'> = ['high', 'medium', 'low']
      return { levels, mockTeam }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Todos los Niveles de Actividad</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div v-for="level in levels" :key="level">
            <h3 class="font-semibold mb-3 capitalize">{{ level }} Activity</h3>
            <ParticipationTeamCard
              :team="{ ...mockTeam, activityLevel: level }"
            />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const MembershipStates: Story = {
  render: () => ({
    components: { ParticipationTeamCard },
    setup() {
      const states = [
        { label: 'No Miembro', isMember: false, isLeader: false },
        { label: 'Miembro', isMember: true, isLeader: false },
        { label: 'Líder', isMember: true, isLeader: true },
      ]
      return { states, mockTeam }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Estados de Membresía</h2>
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
          <div v-for="state in states" :key="state.label">
            <h3 class="font-semibold mb-3">{{ state.label }}</h3>
            <ParticipationTeamCard
              :team="mockTeam"
              :is-member="state.isMember"
              :is-leader="state.isLeader"
            />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const OccupancyLevels: Story = {
  render: () => ({
    components: { ParticipationTeamCard },
    setup() {
      const occupancies = [
        { label: '20%', memberCount: 3, maxMembers: 15 },
        { label: '50%', memberCount: 8, maxMembers: 15 },
        { label: '80%', memberCount: 12, maxMembers: 15 },
        { label: '100%', memberCount: 15, maxMembers: 15 },
      ]
      return { occupancies, mockTeam }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Niveles de Ocupación</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div v-for="occupancy in occupancies" :key="occupancy.label">
            <h3 class="font-semibold mb-3">{{ occupancy.label }} Ocupado</h3>
            <ParticipationTeamCard
              :team="{
                ...mockTeam,
                memberCount: occupancy.memberCount,
                maxMembers: occupancy.maxMembers
              }"
            />
          </div>
        </div>
      </div>
    `,
  }),
  args: {},
}

export const CompactGrid: Story = {
  render: () => ({
    components: { ParticipationTeamCard },
    setup() {
      const teams: ParticipationTeam[] = Array(6).fill(null).map((_, i) => ({
        ...mockTeam,
        id: `team-${i}`,
        name: `Equipo ${i + 1}`,
        memberCount: Math.floor(Math.random() * 15) + 1,
      }))
      return { teams }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-6">Grid de Tarjetas Compactas</h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <ParticipationTeamCard
            v-for="team in teams"
            :key="team.id"
            :team="team"
            compact
          />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const MobileView: Story = {
  render: () => ({
    components: { ParticipationTeamCard },
    setup() {
      return { mockTeam }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Vista Móvil (max-width: 400px)</h2>
        <div class="max-w-sm mx-auto border border-gray-300 rounded-lg p-4">
          <ParticipationTeamCard :team="mockTeam" />
        </div>
      </div>
    `,
  }),
  args: {},
}

export const TeamJoinFlow: Story = {
  render: () => ({
    components: { ParticipationTeamCard },
    setup() {
      const team = ref<ParticipationTeam>({ ...mockTeam, memberCount: 14, maxMembers: 15 })
      const isMember = ref(false)
      const joinCount = ref(0)

      const handleJoin = () => {
        joinCount.value++
        isMember.value = true
        team.value.memberCount++

        if (team.value.memberCount >= (team.value.maxMembers || 0)) {
          team.value.status = 'full'
        }
      }

      const handleLeave = () => {
        isMember.value = false
        team.value.memberCount--
        team.value.status = 'recruiting'
      }

      const reset = () => {
        isMember.value = false
        joinCount.value = 0
        team.value = { ...mockTeam, memberCount: 14, maxMembers: 15 }
      }

      return {
        team,
        isMember,
        joinCount,
        handleJoin,
        handleLeave,
        reset,
      }
    },
    template: `
      <div class="p-6">
        <h2 class="text-2xl font-bold mb-4">Flujo de Unión a Equipo</h2>
        <p class="text-sm text-gray-600 mb-2">
          El equipo está casi lleno. Únete para completarlo.
        </p>
        <p class="text-sm text-gray-600 mb-6">
          Veces unido: {{ joinCount }}
        </p>
        <ParticipationTeamCard
          :team="team"
          :is-member="isMember"
          @join="handleJoin"
          @leave="handleLeave"
        />
        <button
          @click="reset"
          class="mt-4 px-4 py-2 bg-gray-600 text-white rounded hover:bg-gray-700 text-sm"
        >
          Reiniciar
        </button>
      </div>
    `,
  }),
  args: {},
}

export const WithoutOptionalFields: Story = {
  args: {
    team: {
      id: '1',
      name: 'Equipo Mínimo',
      description: 'Equipo con campos mínimos requeridos',
      leader: {
        id: 'leader-1',
        name: 'Líder Simple',
      },
      memberCount: 5,
      status: 'active',
    },
  },
}

export const RichContent: Story = {
  args: {
    team: {
      id: '1',
      name: 'Equipo Completo con Todos los Campos',
      description: 'Este es un equipo de ejemplo que muestra todos los campos posibles con contenido detallado para demostrar la capacidad de la tarjeta',
      leader: {
        id: 'leader-1',
        name: 'María del Carmen González López',
        avatar: 'https://i.pravatar.cc/150?img=1',
        role: 'Coordinadora Principal',
      },
      memberCount: 8,
      maxMembers: 15,
      status: 'recruiting',
      activityLevel: 'high',
      tags: ['Medio Ambiente', 'Sostenibilidad', 'Comunidad', 'Reciclaje', 'Biodiversidad'],
      meetingSchedule: 'Jueves 18:00 - 20:00 (Sala Principal)',
      lastActivity: '2024-01-15',
      createdAt: '2023-12-01',
      imageUrl: 'https://images.unsplash.com/photo-1542601906990-b4d3fb778b09?w=800&h=400&fit=crop',
    },
  },
}
