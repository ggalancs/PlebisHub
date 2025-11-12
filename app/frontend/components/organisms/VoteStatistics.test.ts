import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import VoteStatistics from './VoteStatistics.vue'
import type { VoteStats } from './VoteStatistics.vue'

const mockStats: VoteStats = {
  totalVotes: 1000,
  upvotes: 650,
  downvotes: 350,
  abstentions: 0,
  participation: 75,
  trend: 'up',
}

describe('VoteStatistics', () => {
  it('should render the component', () => {
    const wrapper = mount(VoteStatistics, {
      props: {
        stats: mockStats,
      },
    })

    expect(wrapper.find('.vote-statistics').exists()).toBe(true)
  })

  it('should display total votes', () => {
    const wrapper = mount(VoteStatistics, {
      props: {
        stats: mockStats,
      },
    })

    expect(wrapper.text()).toContain('1000')
  })

  it('should display upvotes', () => {
    const wrapper = mount(VoteStatistics, {
      props: {
        stats: mockStats,
      },
    })

    expect(wrapper.text()).toContain('650')
  })

  it('should display downvotes', () => {
    const wrapper = mount(VoteStatistics, {
      props: {
        stats: mockStats,
      },
    })

    expect(wrapper.text()).toContain('350')
  })

  it('should calculate and display net score', () => {
    const wrapper = mount(VoteStatistics, {
      props: {
        stats: mockStats,
      },
    })

    expect(wrapper.text()).toContain('+300') // 650 - 350
  })

  it('should calculate upvote percentage', () => {
    const wrapper = mount(VoteStatistics, {
      props: {
        stats: mockStats,
      },
    })

    expect(wrapper.text()).toContain('65%') // 650/1000
  })

  it('should calculate downvote percentage', () => {
    const wrapper = mount(VoteStatistics, {
      props: {
        stats: mockStats,
      },
    })

    expect(wrapper.text()).toContain('35%') // 350/1000
  })

  it('should calculate approval rating', () => {
    const wrapper = mount(VoteStatistics, {
      props: {
        stats: mockStats,
      },
    })

    expect(wrapper.text()).toContain('65%') // 650/(650+350)
  })

  it('should display participation when available', () => {
    const wrapper = mount(VoteStatistics, {
      props: {
        stats: mockStats,
        showParticipation: true,
      },
    })

    expect(wrapper.text()).toContain('75%')
  })

  it('should show trend badge when trend is provided', () => {
    const wrapper = mount(VoteStatistics, {
      props: {
        stats: mockStats,
        showTrend: true,
      },
    })

    expect(wrapper.findComponent({ name: 'Badge' }).exists()).toBe(true)
  })

  it('should show upward trend', () => {
    const wrapper = mount(VoteStatistics, {
      props: {
        stats: { ...mockStats, trend: 'up' },
        showTrend: true,
      },
    })

    expect(wrapper.text()).toContain('Al alza')
  })

  it('should show downward trend', () => {
    const wrapper = mount(VoteStatistics, {
      props: {
        stats: { ...mockStats, trend: 'down' },
        showTrend: true,
      },
    })

    expect(wrapper.text()).toContain('A la baja')
  })

  it('should format large numbers with K suffix', () => {
    const wrapper = mount(VoteStatistics, {
      props: {
        stats: {
          ...mockStats,
          totalVotes: 5000,
          upvotes: 3500,
          downvotes: 1500,
        },
      },
    })

    expect(wrapper.text()).toContain('5K')
  })

  it('should format very large numbers with M suffix', () => {
    const wrapper = mount(VoteStatistics, {
      props: {
        stats: {
          ...mockStats,
          totalVotes: 2000000,
          upvotes: 1300000,
          downvotes: 700000,
        },
      },
    })

    expect(wrapper.text()).toContain('2M')
  })

  it('should show loading state', () => {
    const wrapper = mount(VoteStatistics, {
      props: {
        stats: mockStats,
        loading: true,
      },
    })

    expect(wrapper.findComponent({ name: 'Card' }).props('loading')).toBe(true)
  })

  it('should hide percentages when showPercentages is false', () => {
    const wrapper = mount(VoteStatistics, {
      props: {
        stats: mockStats,
        showPercentages: false,
      },
    })

    const statPercentages = wrapper.findAll('.stat-percentage')
    expect(statPercentages.length).toBe(0)
  })

  it('should show progress bars in non-compact mode', () => {
    const wrapper = mount(VoteStatistics, {
      props: {
        stats: mockStats,
        compact: false,
      },
    })

    const progressBars = wrapper.findAllComponents({ name: 'ProgressBar' })
    expect(progressBars.length).toBeGreaterThan(0)
  })

  it('should hide progress bars in compact mode', () => {
    const wrapper = mount(VoteStatistics, {
      props: {
        stats: mockStats,
        compact: true,
      },
    })

    const progressBars = wrapper.findAllComponents({ name: 'ProgressBar' })
    expect(progressBars.length).toBe(0)
  })

  it('should display abstentions when provided', () => {
    const wrapper = mount(VoteStatistics, {
      props: {
        stats: {
          ...mockStats,
          abstentions: 100,
        },
      },
    })

    expect(wrapper.text()).toContain('Abstenciones')
    expect(wrapper.text()).toContain('100')
  })

  it('should handle zero votes gracefully', () => {
    const wrapper = mount(VoteStatistics, {
      props: {
        stats: {
          totalVotes: 0,
          upvotes: 0,
          downvotes: 0,
        },
      },
    })

    expect(wrapper.text()).toContain('0')
  })

  it('should show positive net score with + sign', () => {
    const wrapper = mount(VoteStatistics, {
      props: {
        stats: mockStats,
      },
    })

    expect(wrapper.text()).toContain('+300')
  })

  it('should show negative net score without extra sign', () => {
    const wrapper = mount(VoteStatistics, {
      props: {
        stats: {
          totalVotes: 1000,
          upvotes: 300,
          downvotes: 700,
        },
      },
    })

    expect(wrapper.text()).toContain('-400')
  })
})
