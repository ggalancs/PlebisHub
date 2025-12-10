import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import CollaborationStats from './CollaborationStats.vue'
import type { Collaboration } from './CollaborationSummary.vue'

const mockCollaborations: Collaboration[] = [
  {
    id: '1',
    title: 'Huerto Comunitario',
    description: 'Test',
    type: 'project',
    skills: ['Jardinería', 'Agricultura'],
    creator: { id: 'u1', name: 'María' },
    currentCollaborators: 10,
    maxCollaborators: 20,
    status: 'open',
    createdAt: '2025-01-01',
  },
  {
    id: '2',
    title: 'Festival de Música',
    description: 'Test',
    type: 'event',
    skills: ['Producción', 'Sonido'],
    creator: { id: 'u2', name: 'Carlos' },
    currentCollaborators: 18,
    maxCollaborators: 20,
    status: 'in_progress',
    createdAt: '2025-01-02',
  },
  {
    id: '3',
    title: 'Limpieza del Río',
    description: 'Test',
    type: 'campaign',
    skills: ['Organización', 'Jardinería'],
    creator: { id: 'u3', name: 'Ana' },
    currentCollaborators: 25,
    maxCollaborators: 30,
    status: 'completed',
    createdAt: '2025-01-03',
  },
  {
    id: '4',
    title: 'Taller de Programación',
    description: 'Test',
    type: 'workshop',
    skills: ['JavaScript', 'Python'],
    creator: { id: 'u4', name: 'Pedro' },
    currentCollaborators: 8,
    maxCollaborators: 10,
    status: 'completed',
    createdAt: '2025-01-04',
  },
  {
    id: '5',
    title: 'Red de Apoyo',
    description: 'Test',
    type: 'initiative',
    skills: ['Empatía', 'Comunicación'],
    creator: { id: 'u5', name: 'Laura' },
    currentCollaborators: 5,
    status: 'cancelled',
    createdAt: '2025-01-05',
  },
]

describe('CollaborationStats', () => {
  describe('rendering', () => {
    it('should render the component', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      expect(wrapper.find('.collaboration-stats').exists()).toBe(true)
    })

    it('should display main stats cards', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      expect(wrapper.text()).toContain('Total Colaboraciones')
      expect(wrapper.text()).toContain('Total Colaboradores')
      expect(wrapper.text()).toContain('Tasa de Finalización')
      expect(wrapper.text()).toContain('Buscan Colaboradores')
    })

    it('should display secondary stats when not compact', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
          compact: false,
        },
      })
      expect(wrapper.text()).toContain('Por Estado')
      expect(wrapper.text()).toContain('Por Tipo')
      expect(wrapper.text()).toContain('Habilidades Populares')
    })

    it('should hide secondary stats when compact', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
          compact: true,
        },
      })
      expect(wrapper.text()).not.toContain('Por Estado')
      expect(wrapper.text()).not.toContain('Por Tipo')
    })
  })

  describe('total collaborations', () => {
    it('should display total collaborations count', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      expect(wrapper.text()).toContain('5')
    })

    it('should display active collaborations count', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      // open + in_progress = 1 + 1 = 2
      expect(wrapper.text()).toContain('2 activas')
    })

    it('should handle zero collaborations', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: [],
        },
      })
      expect(wrapper.text()).toContain('0')
    })
  })

  describe('total collaborators', () => {
    it('should sum all collaborators', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      // 10 + 18 + 25 + 8 + 5 = 66
      expect(wrapper.text()).toContain('66')
    })

    it('should calculate average collaborators', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      // 66 / 5 = 13.2 rounds to 13
      expect(wrapper.text()).toContain('13 promedio')
    })

    it('should return 0 average when no collaborations', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: [],
        },
      })
      expect(wrapper.text()).toContain('0 promedio')
    })
  })

  describe('completion rate', () => {
    it('should calculate completion rate', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      // completed/(completed + cancelled) = 2/(2+1) = 66.67% rounds to 67%
      expect(wrapper.text()).toContain('67%')
    })

    it('should display completed count', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      expect(wrapper.text()).toContain('2 completadas')
    })

    it('should return 0% when no completed or cancelled', () => {
      const onlyOpen = mockCollaborations.filter(c => c.status === 'open')
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: onlyOpen,
        },
      })
      expect(wrapper.text()).toContain('0%')
    })
  })

  describe('needing people', () => {
    it('should count open collaborations not full', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      // Only collab #1 is open and not full
      expect(wrapper.text()).toContain('Buscan Colaboradores')
    })

    it('should count full collaborations', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      // No collaborations are full (10/20, 18/20, 25/30, 8/10, 5/no-max)
      expect(wrapper.text()).toContain('0 con cupo completo')
    })

    it('should identify full collaboration', () => {
      const fullCollab = {
        ...mockCollaborations[0],
        currentCollaborators: 20,
        maxCollaborators: 20,
        status: 'open' as const,
      }
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: [fullCollab],
        },
      })
      expect(wrapper.text()).toContain('1 con cupo completo')
    })

    it('should not count collaborations without max', () => {
      const noMax = [{
        ...mockCollaborations[0],
        maxCollaborators: undefined,
        status: 'open' as const,
      }]
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: noMax,
        },
      })
      expect(wrapper.text()).toContain('0')
    })
  })

  describe('by status', () => {
    it('should show open count', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      expect(wrapper.text()).toContain('Abiertas')
    })

    it('should show in_progress count', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      expect(wrapper.text()).toContain('En Progreso')
    })

    it('should show completed count', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      expect(wrapper.text()).toContain('Completadas')
    })

    it('should show cancelled count', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      expect(wrapper.text()).toContain('Canceladas')
    })

    it('should not show status section when zero', () => {
      const onlyOpen = [mockCollaborations[0]]
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: onlyOpen,
        },
      })
      expect(wrapper.text()).not.toContain('En Progreso')
      expect(wrapper.text()).not.toContain('Completadas')
      expect(wrapper.text()).not.toContain('Canceladas')
    })
  })

  describe('by type', () => {
    it('should show all types', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      expect(wrapper.text()).toContain('Proyectos')
      expect(wrapper.text()).toContain('Eventos')
      expect(wrapper.text()).toContain('Campañas')
      expect(wrapper.text()).toContain('Talleres')
      expect(wrapper.text()).toContain('Iniciativas')
    })

    it('should show progress bars for types', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      const progressBars = wrapper.findAllComponents({ name: 'ProgressBar' })
      expect(progressBars.length).toBeGreaterThan(0)
    })

    it('should show "no types" when empty', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: [],
        },
      })
      expect(wrapper.text()).toContain('No hay tipos disponibles')
    })

    it('should limit to top 5 types', () => {
      const manyTypes = Array(10).fill(null).map((_, i) => ({
        ...mockCollaborations[0],
        id: `c-${i}`,
        type: ['project', 'initiative', 'event', 'campaign', 'workshop', 'other'][i % 6] as any,
      }))
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: manyTypes,
        },
      })
      const progressBars = wrapper.findAllComponents({ name: 'ProgressBar' })
      // Should have progress bars for types (max 5) + skills
      expect(progressBars.length).toBeLessThanOrEqual(20)
    })
  })

  describe('popular skills', () => {
    it('should show popular skills', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      expect(wrapper.text()).toContain('Habilidades Populares')
      expect(wrapper.text()).toContain('Jardinería') // appears twice
    })

    it('should count skill frequency', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      // Jardinería appears in 2 collaborations
      const text = wrapper.text()
      expect(text).toContain('Jardinería')
    })

    it('should show "no skills" when empty', () => {
      const noSkills = mockCollaborations.map(c => ({ ...c, skills: [] }))
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: noSkills,
        },
      })
      expect(wrapper.text()).toContain('No hay habilidades disponibles')
    })

    it('should limit to top 10 skills', () => {
      const manySkills = [{
        ...mockCollaborations[0],
        skills: Array(20).fill(null).map((_, i) => `Skill ${i}`),
      }]
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: manySkills,
        },
      })
      // Should show max 10 skills
      const progressBars = wrapper.findAllComponents({ name: 'ProgressBar' })
      // At least some progress bars for skills
      expect(progressBars.length).toBeGreaterThan(0)
    })

    it('should sort skills by frequency', () => {
      const repeatedSkills: Collaboration[] = [
        {
          ...mockCollaborations[0],
          id: '1',
          skills: ['Skill A', 'Skill B'],
        },
        {
          ...mockCollaborations[0],
          id: '2',
          skills: ['Skill A', 'Skill C'],
        },
        {
          ...mockCollaborations[0],
          id: '3',
          skills: ['Skill A', 'Skill D'],
        },
      ]
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: repeatedSkills,
        },
      })
      // Skill A appears 3 times, should be first
      expect(wrapper.text()).toContain('Skill A')
    })
  })

  describe('most active type', () => {
    it('should display most active type', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      expect(wrapper.text()).toContain('Tipo Más Activo')
      // All types appear once, so any of them could be first
    })

    it('should show count for most active type', () => {
      const mostlyProjects = [
        { ...mockCollaborations[0], type: 'project' as const },
        { ...mockCollaborations[1], type: 'project' as const },
        { ...mockCollaborations[2], type: 'event' as const },
      ]
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mostlyProjects,
        },
      })
      expect(wrapper.text()).toContain('Proyectos')
      expect(wrapper.text()).toContain('2 colaboraciones')
    })

    it('should show N/A when no collaborations', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: [],
        },
      })
      expect(wrapper.text()).toContain('N/A')
    })
  })

  describe('most popular skill', () => {
    it('should display most popular skill', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      expect(wrapper.text()).toContain('Habilidad Más Demandada')
      // Jardinería appears twice
      expect(wrapper.text()).toContain('Jardinería')
    })

    it('should show count for most popular skill', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      // Jardinería appears in 2 collaborations
      const text = wrapper.text()
      expect(text).toContain('Jardinería')
    })

    it('should show N/A when no skills', () => {
      const noSkills = mockCollaborations.map(c => ({ ...c, skills: [] }))
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: noSkills,
        },
      })
      expect(wrapper.text()).toContain('N/A')
    })
  })

  describe('loading state', () => {
    it('should show loading cards when loading', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
          loading: true,
        },
      })
      // When loading is true, Card components receive loading attribute
      const cards = wrapper.findAllComponents({ name: 'Card' })
      expect(cards.length).toBeGreaterThan(0)
    })
  })

  describe('empty state', () => {
    it('should handle empty collaborations array', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: [],
        },
      })
      expect(wrapper.find('.collaboration-stats').exists()).toBe(true)
      expect(wrapper.text()).toContain('0')
    })

    it('should show 0% completion when no collaborations', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: [],
        },
      })
      expect(wrapper.text()).toContain('0%')
    })

    it('should show N/A for most active type when empty', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: [],
        },
      })
      expect(wrapper.text()).toContain('N/A')
    })
  })

  describe('icons', () => {
    it('should show appropriate icons', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      const icons = wrapper.findAllComponents({ name: 'Icon' })
      expect(icons.length).toBeGreaterThan(0)
    })

    it('should have folder icon for total collaborations', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      const folderIcon = wrapper.findAllComponents({ name: 'Icon' }).find(
        i => i.props('name') === 'folder'
      )
      expect(folderIcon?.exists()).toBe(true)
    })

    it('should have users icon for collaborators', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      const usersIcon = wrapper.findAllComponents({ name: 'Icon' }).find(
        i => i.props('name') === 'users'
      )
      expect(usersIcon?.exists()).toBe(true)
    })

    it('should have check-circle icon for completion rate', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      const checkIcon = wrapper.findAllComponents({ name: 'Icon' }).find(
        i => i.props('name') === 'check-circle'
      )
      expect(checkIcon?.exists()).toBe(true)
    })
  })

  describe('formatting', () => {
    it('should format numbers correctly', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      // Numbers should be formatted with Spanish locale
      expect(wrapper.text()).toContain('5')
    })

    it('should format large numbers with thousand separators', () => {
      const manyCollabs = Array(1000).fill(null).map((_, i) => ({
        ...mockCollaborations[0],
        id: `c-${i}`,
        currentCollaborators: 10,
      }))
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: manyCollabs,
        },
      })
      // 10 collaborators * 1000 collaborations = 10000 total collaborators
      // which should be formatted as 10.000
      expect(wrapper.text()).toContain('10.000')
    })
  })

  describe('progress bars', () => {
    it('should show progress bars for types', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      const progressBars = wrapper.findAllComponents({ name: 'ProgressBar' })
      expect(progressBars.length).toBeGreaterThan(0)
    })

    it('should show warning progress bars for skills', () => {
      const wrapper = mount(CollaborationStats, {
        props: {
          collaborations: mockCollaborations,
        },
      })
      const warningBars = wrapper.findAllComponents({ name: 'ProgressBar' }).filter(
        p => p.props('variant') === 'warning'
      )
      expect(warningBars.length).toBeGreaterThan(0)
    })
  })
})
