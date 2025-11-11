import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import ProgressBar from './ProgressBar.vue'

describe('ProgressBar', () => {
  it('renders with value', () => {
    const wrapper = mount(ProgressBar, {
      props: { value: 50 },
    })
    expect(wrapper.exists()).toBe(true)
  })

  it('calculates percentage correctly', () => {
    const wrapper = mount(ProgressBar, {
      props: { value: 50, max: 100 },
    })
    const bar = wrapper.find('.h-full')
    expect(bar.attributes('style')).toContain('width: 50%')
  })

  it('renders label', () => {
    const wrapper = mount(ProgressBar, {
      props: { value: 50, label: 'Loading' },
    })
    expect(wrapper.text()).toContain('Loading')
  })

  it('shows percentage', () => {
    const wrapper = mount(ProgressBar, {
      props: { value: 75, showPercentage: true },
    })
    expect(wrapper.text()).toContain('75%')
  })

  it('renders different sizes', () => {
    const sm = mount(ProgressBar, { props: { value: 50, size: 'sm' } })
    const lg = mount(ProgressBar, { props: { value: 50, size: 'lg' } })

    expect(sm.find('.progress-bar-track').classes()).toContain('h-2')
    expect(lg.find('.progress-bar-track').classes()).toContain('h-4')
  })

  it('renders different variants', () => {
    const success = mount(ProgressBar, { props: { value: 50, variant: 'success' } })
    const danger = mount(ProgressBar, { props: { value: 50, variant: 'danger' } })

    expect(success.find('.h-full').classes()).toContain('bg-green-600')
    expect(danger.find('.h-full').classes()).toContain('bg-red-600')
  })

  it('handles value > max', () => {
    const wrapper = mount(ProgressBar, {
      props: { value: 150, max: 100 },
    })
    const bar = wrapper.find('.h-full')
    expect(bar.attributes('style')).toContain('width: 100%')
  })

  it('handles negative value', () => {
    const wrapper = mount(ProgressBar, {
      props: { value: -10 },
    })
    const bar = wrapper.find('.h-full')
    expect(bar.attributes('style')).toContain('width: 0%')
  })

  it('has accessibility attributes', () => {
    const wrapper = mount(ProgressBar, {
      props: { value: 50, max: 100 },
    })
    const track = wrapper.find('[role="progressbar"]')
    expect(track.attributes('aria-valuenow')).toBe('50')
    expect(track.attributes('aria-valuemin')).toBe('0')
    expect(track.attributes('aria-valuemax')).toBe('100')
  })
})
