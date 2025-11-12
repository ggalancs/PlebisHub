import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import VoteHistory from './VoteHistory.vue'
import type { VoteHistoryItem } from './VoteHistory.vue'

const mockHistory: VoteHistoryItem[] = [
  {
    id: 1,
    itemTitle: 'Propuesta de mejora del transporte',
    itemType: 'proposal',
    voteType: 'up',
    votedAt: new Date(Date.now() - 3600000), // 1 hour ago
    itemUrl: '/proposals/1',
  },
  {
    id: 2,
    itemTitle: 'Comentario sobre espacios verdes',
    itemType: 'comment',
    voteType: 'down',
    votedAt: new Date(Date.now() - 7200000), // 2 hours ago
  },
  {
    id: 3,
    itemTitle: 'Publicación sobre reciclaje',
    itemType: 'post',
    voteType: 'up',
    votedAt: new Date(Date.now() - 86400000), // 1 day ago
  },
]

describe('VoteHistory', () => {
  it('should render the component', () => {
    const wrapper = mount(VoteHistory, {
      props: {
        history: mockHistory,
      },
    })

    expect(wrapper.find('.vote-history').exists()).toBe(true)
  })

  it('should display history items', () => {
    const wrapper = mount(VoteHistory, {
      props: {
        history: mockHistory,
      },
    })

    expect(wrapper.text()).toContain('Propuesta de mejora del transporte')
    expect(wrapper.text()).toContain('Comentario sobre espacios verdes')
  })

  it('should show empty state when no history', () => {
    const wrapper = mount(VoteHistory, {
      props: {
        history: [],
      },
    })

    expect(wrapper.findComponent({ name: 'EmptyState' }).exists()).toBe(true)
  })

  it('should display custom empty message', () => {
    const wrapper = mount(VoteHistory, {
      props: {
        history: [],
        emptyMessage: 'Sin historial',
      },
    })

    const emptyState = wrapper.findComponent({ name: 'EmptyState' })
    expect(emptyState.props('title')).toBe('Sin historial')
  })

  it('should show upvote indicator', () => {
    const wrapper = mount(VoteHistory, {
      props: {
        history: [mockHistory[0]],
      },
    })

    expect(wrapper.text()).toContain('A favor')
  })

  it('should show downvote indicator', () => {
    const wrapper = mount(VoteHistory, {
      props: {
        history: [mockHistory[1]],
      },
    })

    expect(wrapper.text()).toContain('En contra')
  })

  it('should display item type labels', () => {
    const wrapper = mount(VoteHistory, {
      props: {
        history: mockHistory,
      },
    })

    expect(wrapper.text()).toContain('Propuesta')
    expect(wrapper.text()).toContain('Comentario')
    expect(wrapper.text()).toContain('Publicación')
  })

  it('should format dates correctly', () => {
    const wrapper = mount(VoteHistory, {
      props: {
        history: mockHistory,
      },
    })

    expect(wrapper.text()).toContain('hace')
  })

  it('should emit item-click when clicking on item', async () => {
    const wrapper = mount(VoteHistory, {
      props: {
        history: mockHistory,
      },
    })

    const item = wrapper.find('.history-item')
    await item.trigger('click')

    expect(wrapper.emitted('item-click')).toBeTruthy()
    expect(wrapper.emitted('item-click')?.[0][0]).toEqual(mockHistory[0])
  })

  it('should show loading state', () => {
    const wrapper = mount(VoteHistory, {
      props: {
        history: mockHistory,
        loading: true,
      },
    })

    expect(wrapper.findComponent({ name: 'Card' }).props('loading')).toBe(true)
  })

  it('should paginate history items', () => {
    const largeHistory = Array.from({ length: 25 }, (_, i) => ({
      ...mockHistory[0],
      id: i + 1,
    }))

    const wrapper = mount(VoteHistory, {
      props: {
        history: largeHistory,
        pageSize: 10,
        showPagination: true,
      },
    })

    const items = wrapper.findAll('.history-item')
    expect(items.length).toBe(10)
  })

  it('should not show pagination when disabled', () => {
    const wrapper = mount(VoteHistory, {
      props: {
        history: mockHistory,
        showPagination: false,
      },
    })

    expect(wrapper.text()).not.toContain('Anterior')
    expect(wrapper.text()).not.toContain('Siguiente')
  })

  it('should show link icon when itemUrl is provided', () => {
    const wrapper = mount(VoteHistory, {
      props: {
        history: [mockHistory[0]], // has itemUrl
      },
    })

    const linkIcon = wrapper.findAll({ name: 'Icon' }).find((icon) =>
      icon.props('name') === 'external-link'
    )
    expect(linkIcon).toBeTruthy()
  })
})
