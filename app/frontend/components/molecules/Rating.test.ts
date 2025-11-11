import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Rating from './Rating.vue'

describe('Rating', () => {
  it('renders stars', () => {
    const wrapper = mount(Rating, { props: { modelValue: 3 } })
    expect(wrapper.findAllComponents({ name: 'Icon' }).length).toBe(5)
  })

  it('emits update on click', async () => {
    const wrapper = mount(Rating, { props: { modelValue: 0 } })
    await wrapper.findAll('button')[2].trigger('click')
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([3])
  })

  it('respects readonly', async () => {
    const wrapper = mount(Rating, { props: { modelValue: 3, readonly: true } })
    await wrapper.findAll('button')[4].trigger('click')
    expect(wrapper.emitted('update:modelValue')).toBeFalsy()
  })

  it('renders different sizes', () => {
    const sm = mount(Rating, { props: { modelValue: 3, size: 'sm' } })
    const lg = mount(Rating, { props: { modelValue: 3, size: 'lg' } })
    expect(sm.find('.w-4').exists()).toBe(true)
    expect(lg.find('.w-6').exists()).toBe(true)
  })
})
