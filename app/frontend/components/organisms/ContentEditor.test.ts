import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import ContentEditor from './ContentEditor.vue'

describe('ContentEditor', () => {
  describe('rendering', () => {
    it('should render the component', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '',
        },
      })

      expect(wrapper.find('.content-editor').exists()).toBe(true)
    })

    it('should display textarea in edit view', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '',
          view: 'edit',
        },
      })

      expect(wrapper.find('.content-editor__textarea').exists()).toBe(true)
    })

    it('should display preview in preview view', async () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: 'Test content',
          view: 'preview',
        },
      })

      expect(wrapper.find('.content-editor__preview').exists()).toBe(true)
    })

    it('should display split view with both editor and preview', async () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: 'Test content',
          view: 'split',
        },
      })

      expect(wrapper.find('.content-editor__split').exists()).toBe(true)
      expect(wrapper.findAll('.content-editor__split-pane').length).toBe(2)
    })

    it('should show toolbar when showToolbar is true', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '',
          showToolbar: true,
        },
      })

      expect(wrapper.find('.content-editor__toolbar').exists()).toBe(true)
    })

    it('should hide toolbar when showToolbar is false', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '',
          showToolbar: false,
        },
      })

      expect(wrapper.find('.content-editor__toolbar').exists()).toBe(false)
    })

    it('should show character/word count when showCount is true', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: 'Test content here',
          showCount: true,
        },
      })

      expect(wrapper.text()).toContain('palabras')
      expect(wrapper.text()).toContain('/')
    })

    it('should hide character/word count when showCount is false', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: 'Test content',
          showCount: false,
        },
      })

      expect(wrapper.text()).not.toContain('palabras')
    })
  })

  describe('content editing', () => {
    it('should display initial content', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: 'Initial content',
        },
      })

      const textarea = wrapper.find('textarea')
      expect(textarea.element.value).toBe('Initial content')
    })

    it('should emit update:modelValue when content changes', async () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '',
        },
      })

      const textarea = wrapper.find('textarea')
      await textarea.setValue('New content')
      await nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('update:modelValue')?.[0]).toEqual(['New content'])
    })

    it('should emit change event when content changes', async () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '',
        },
      })

      const textarea = wrapper.find('textarea')
      await textarea.setValue('New content')
      await nextTick()

      expect(wrapper.emitted('change')).toBeTruthy()
      expect(wrapper.emitted('change')?.[0]).toEqual(['New content'])
    })

    it('should update when modelValue prop changes', async () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: 'Initial',
        },
      })

      await wrapper.setProps({ modelValue: 'Updated' })
      await nextTick()

      const textarea = wrapper.find('textarea')
      expect(textarea.element.value).toBe('Updated')
    })

    it('should respect maxLength', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '',
          maxLength: 100,
        },
      })

      const textarea = wrapper.find('textarea')
      expect(textarea.attributes('maxlength')).toBe('100')
    })

    it('should be disabled when disabled prop is true', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '',
          disabled: true,
        },
      })

      const textarea = wrapper.find('textarea')
      expect(textarea.attributes('disabled')).toBeDefined()
    })

    it('should be readonly when readonly prop is true', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '',
          readonly: true,
        },
      })

      const textarea = wrapper.find('textarea')
      expect(textarea.attributes('readonly')).toBeDefined()
    })
  })

  describe('character and word counting', () => {
    it('should count characters correctly', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: 'Hello world',
          showCount: true,
        },
      })

      expect(wrapper.text()).toContain('11')
    })

    it('should count words correctly', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: 'Hello world test',
          showCount: true,
        },
      })

      expect(wrapper.text()).toContain('3')
    })

    it('should count zero words for empty content', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '',
          showCount: true,
        },
      })

      expect(wrapper.text()).toContain('0')
    })

    it('should show warning color when near max length', async () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: 'a'.repeat(9600), // 400 chars remaining
          maxLength: 10000,
          showCount: true,
        },
      })

      await nextTick()
      expect(wrapper.find('.text-warning').exists()).toBe(true)
    })

    it('should show error color when very close to max length', async () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: 'a'.repeat(9950), // 50 chars remaining
          maxLength: 10000,
          showCount: true,
        },
      })

      await nextTick()
      expect(wrapper.find('.text-error').exists()).toBe(true)
    })
  })

  describe('validation', () => {
    it('should validate minimum length', async () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: 'Short',
          minLength: 10,
        },
      })

      await nextTick()
      expect(wrapper.text()).toContain('debe tener entre')
    })

    it('should validate maximum length', async () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: 'a'.repeat(150),
          maxLength: 100,
        },
      })

      await nextTick()
      expect(wrapper.text()).toContain('debe tener entre')
    })

    it('should be valid when content is within range', async () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: 'Valid content here',
          minLength: 5,
          maxLength: 100,
        },
      })

      await nextTick()
      expect(wrapper.text()).not.toContain('debe tener entre')
    })
  })

  describe('view modes', () => {
    it('should switch to preview view', async () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: 'Test',
          view: 'edit',
        },
      })

      const previewButton = wrapper.findAll('button').find((btn) =>
        btn.text().includes('Vista Previa')
      )
      await previewButton?.trigger('click')
      await nextTick()

      expect(wrapper.find('.content-editor__preview').exists()).toBe(true)
    })

    it('should switch to split view', async () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: 'Test',
          view: 'edit',
        },
      })

      const splitButton = wrapper.findAll('button').find((btn) =>
        btn.text().includes('Dividido')
      )
      await splitButton?.trigger('click')
      await nextTick()

      expect(wrapper.find('.content-editor__split').exists()).toBe(true)
    })

    it('should switch back to edit view', async () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: 'Test',
          view: 'preview',
        },
      })

      const editButton = wrapper.findAll('button').find((btn) =>
        btn.text().includes('Editar')
      )
      await editButton?.trigger('click')
      await nextTick()

      expect(wrapper.find('.content-editor__textarea').exists()).toBe(true)
    })
  })

  describe('markdown rendering', () => {
    it('should render bold text', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '**bold text**',
          mode: 'markdown',
          view: 'preview',
        },
      })

      expect(wrapper.html()).toContain('<strong>bold text</strong>')
    })

    it('should render italic text', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '_italic text_',
          mode: 'markdown',
          view: 'preview',
        },
      })

      expect(wrapper.html()).toContain('<em>italic text</em>')
    })

    it('should render headings', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '# Heading 1',
          mode: 'markdown',
          view: 'preview',
        },
      })

      expect(wrapper.html()).toContain('<h1')
      expect(wrapper.html()).toContain('Heading 1')
    })

    it('should render links', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '[Link text](https://example.com)',
          mode: 'markdown',
          view: 'preview',
        },
      })

      expect(wrapper.html()).toContain('<a href="https://example.com"')
      expect(wrapper.html()).toContain('Link text')
    })

    it('should render images', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '![Alt text](https://example.com/image.jpg)',
          mode: 'markdown',
          view: 'preview',
        },
      })

      expect(wrapper.html()).toContain('<img')
      expect(wrapper.html()).toContain('src="https://example.com/image.jpg"')
    })

    it('should render inline code', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '`code here`',
          mode: 'markdown',
          view: 'preview',
        },
      })

      expect(wrapper.html()).toContain('<code')
      expect(wrapper.html()).toContain('code here')
    })

    it('should render blockquotes', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '> Quote text',
          mode: 'markdown',
          view: 'preview',
        },
      })

      expect(wrapper.html()).toContain('<blockquote')
      expect(wrapper.html()).toContain('Quote text')
    })
  })

  describe('toolbar actions', () => {
    it('should have toolbar buttons', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '',
          showToolbar: true,
        },
      })

      const toolbar = wrapper.find('.content-editor__toolbar')
      const buttons = toolbar.findAll('button')
      expect(buttons.length).toBeGreaterThan(0)
    })

    it('should disable toolbar buttons when disabled', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '',
          disabled: true,
          showToolbar: true,
        },
      })

      const buttons = wrapper.findAll('.content-editor__toolbar button')
      buttons.forEach((button) => {
        expect(button.attributes('disabled')).toBeDefined()
      })
    })

    it('should disable toolbar buttons when readonly', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '',
          readonly: true,
          showToolbar: true,
        },
      })

      const buttons = wrapper.findAll('.content-editor__toolbar button')
      buttons.forEach((button) => {
        expect(button.attributes('disabled')).toBeDefined()
      })
    })

    it('should emit insert-media event when clicking image button', async () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '',
          showToolbar: true,
        },
      })

      const imageButton = wrapper.findAll('.content-editor__toolbar button')[4] // Image is 5th button
      await imageButton.trigger('click')

      expect(wrapper.emitted('insert-media')).toBeTruthy()
    })
  })

  describe('autosave', () => {
    it('should show autosave indicator when enabled', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '',
          autosave: true,
        },
      })

      expect(wrapper.text()).toContain('Guardado automático activado')
    })

    it('should not show autosave indicator when disabled', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '',
          autosave: false,
        },
      })

      expect(wrapper.text()).not.toContain('Guardado automático activado')
    })
  })

  describe('exposed methods', () => {
    it('should expose getContent method', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: 'Test content',
        },
      })

      expect(wrapper.vm.getContent()).toBe('Test content')
    })

    it('should expose setContent method', async () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: 'Initial',
        },
      })

      wrapper.vm.setContent('Updated content')
      await nextTick()

      expect(wrapper.vm.getContent()).toBe('Updated content')
    })

    it('should expose insertText method', async () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: 'Initial',
        },
      })

      wrapper.vm.insertText(' added')
      await nextTick()

      expect(wrapper.vm.getContent()).toContain('added')
    })
  })

  describe('placeholder', () => {
    it('should show placeholder text', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '',
          placeholder: 'Custom placeholder',
        },
      })

      const textarea = wrapper.find('textarea')
      expect(textarea.attributes('placeholder')).toBe('Custom placeholder')
    })
  })

  describe('mode indicator', () => {
    it('should show markdown mode indicator', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '',
          mode: 'markdown',
        },
      })

      expect(wrapper.text()).toContain('Markdown')
    })

    it('should show rich text mode indicator', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '',
          mode: 'rich',
        },
      })

      expect(wrapper.text()).toContain('Rich Text')
    })
  })

  describe('custom height', () => {
    it('should apply custom height', () => {
      const wrapper = mount(ContentEditor, {
        props: {
          modelValue: '',
          height: '600px',
        },
      })

      expect(wrapper.find('.content-editor').attributes('style')).toContain('height: 600px')
    })
  })
})
