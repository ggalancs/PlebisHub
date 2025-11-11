import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import Slider from './Slider.vue'

describe('Slider', () => {
  it('renders with default props', () => {
    const wrapper = mount(Slider, {
      props: { modelValue: 50 },
    })
    expect(wrapper.exists()).toBe(true)
    expect(wrapper.find('.slider-container').exists()).toBe(true)
  })

  it('renders input with correct value', () => {
    const wrapper = mount(Slider, {
      props: { modelValue: 75 },
    })
    const input = wrapper.find('input[type="range"]')
    expect(input.element.value).toBe('75')
  })

  it('applies min and max attributes', () => {
    const wrapper = mount(Slider, {
      props: { modelValue: 50, min: 10, max: 200 },
    })
    const input = wrapper.find('input[type="range"]')
    expect(input.attributes('min')).toBe('10')
    expect(input.attributes('max')).toBe('200')
  })

  it('applies step attribute', () => {
    const wrapper = mount(Slider, {
      props: { modelValue: 50, step: 5 },
    })
    const input = wrapper.find('input[type="range"]')
    expect(input.attributes('step')).toBe('5')
  })

  it('emits update:modelValue on input', async () => {
    const wrapper = mount(Slider, {
      props: { modelValue: 50 },
    })
    const input = wrapper.find('input[type="range"]')

    await input.setValue(75)

    expect(wrapper.emitted('update:modelValue')).toBeTruthy()
    expect(wrapper.emitted('update:modelValue')?.[0]).toEqual([75])
  })

  it('emits change event on change', async () => {
    const wrapper = mount(Slider, {
      props: { modelValue: 50 },
    })
    const input = wrapper.find('input[type="range"]')

    input.element.value = '75'
    await input.trigger('change')

    expect(wrapper.emitted('change')).toBeTruthy()
    expect(wrapper.emitted('change')?.[0]).toEqual([75])
  })

  it('calculates percentage correctly', () => {
    const wrapper = mount(Slider, {
      props: { modelValue: 50, min: 0, max: 100 },
    })
    const fill = wrapper.find('.slider-fill')
    expect(fill.attributes('style')).toContain('width: 50%')
  })

  it('calculates percentage with custom min/max', () => {
    const wrapper = mount(Slider, {
      props: { modelValue: 150, min: 100, max: 200 },
    })
    const fill = wrapper.find('.slider-fill')
    expect(fill.attributes('style')).toContain('width: 50%')
  })

  it('positions thumb correctly', () => {
    const wrapper = mount(Slider, {
      props: { modelValue: 75, min: 0, max: 100 },
    })
    const thumb = wrapper.find('.slider-thumb')
    expect(thumb.attributes('style')).toContain('left: 75%')
  })

  it('shows value label when showValue is true', () => {
    const wrapper = mount(Slider, {
      props: { modelValue: 42, showValue: true },
    })
    const valueLabel = wrapper.find('.slider-value')
    expect(valueLabel.exists()).toBe(true)
    expect(valueLabel.text()).toBe('42')
  })

  it('hides value label when showValue is false', () => {
    const wrapper = mount(Slider, {
      props: { modelValue: 42, showValue: false },
    })
    expect(wrapper.find('.slider-value').exists()).toBe(false)
  })

  it('applies small size classes', () => {
    const wrapper = mount(Slider, {
      props: { modelValue: 50, size: 'sm' },
    })
    const track = wrapper.find('.slider-track')
    expect(track.classes()).toContain('h-1')
  })

  it('applies medium size classes', () => {
    const wrapper = mount(Slider, {
      props: { modelValue: 50, size: 'md' },
    })
    const track = wrapper.find('.slider-track')
    expect(track.classes()).toContain('h-2')
  })

  it('applies large size classes', () => {
    const wrapper = mount(Slider, {
      props: { modelValue: 50, size: 'lg' },
    })
    const track = wrapper.find('.slider-track')
    expect(track.classes()).toContain('h-3')
  })

  it('disables input when disabled prop is true', () => {
    const wrapper = mount(Slider, {
      props: { modelValue: 50, disabled: true },
    })
    const input = wrapper.find('input[type="range"]')
    expect(input.attributes('disabled')).toBe('')
  })

  it('handles minimum value', () => {
    const wrapper = mount(Slider, {
      props: { modelValue: 0, min: 0, max: 100 },
    })
    const fill = wrapper.find('.slider-fill')
    expect(fill.attributes('style')).toContain('width: 0%')
  })

  it('handles maximum value', () => {
    const wrapper = mount(Slider, {
      props: { modelValue: 100, min: 0, max: 100 },
    })
    const fill = wrapper.find('.slider-fill')
    expect(fill.attributes('style')).toContain('width: 100%')
  })

  it('handles negative ranges', () => {
    const wrapper = mount(Slider, {
      props: { modelValue: 0, min: -50, max: 50 },
    })
    const fill = wrapper.find('.slider-fill')
    expect(fill.attributes('style')).toContain('width: 50%')
  })

  it('has correct styling classes', () => {
    const wrapper = mount(Slider, {
      props: { modelValue: 50 },
    })
    const track = wrapper.find('.slider-track')
    expect(track.classes()).toContain('rounded-full')
    expect(track.classes()).toContain('bg-gray-200')
  })

  it('fill has primary color', () => {
    const wrapper = mount(Slider, {
      props: { modelValue: 50 },
    })
    const fill = wrapper.find('.slider-fill')
    expect(fill.classes()).toContain('bg-primary')
  })

  it('thumb has correct styling', () => {
    const wrapper = mount(Slider, {
      props: { modelValue: 50 },
    })
    const thumb = wrapper.find('.slider-thumb')
    expect(thumb.classes()).toContain('rounded-full')
    expect(thumb.classes()).toContain('bg-white')
    expect(thumb.classes()).toContain('border-primary')
  })
})
