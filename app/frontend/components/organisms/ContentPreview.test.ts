import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import ContentPreview from './ContentPreview.vue'

const _sampleMarkdown = `# Heading 1

## Heading 2

This is **bold** and this is _italic_.

- List item 1
- List item 2

> This is a quote

\`inline code\`

[Link](https://example.com)
`

describe('ContentPreview', () => {
  describe('rendering', () => {
    it('should render the component', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: 'Test content',
        },
      })

      expect(wrapper.find('.content-preview').exists()).toBe(true)
    })

    it('should display title', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: 'Test',
          title: 'Custom Title',
        },
      })

      expect(wrapper.text()).toContain('Custom Title')
    })

    it('should show device frame by default', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: 'Test',
        },
      })

      expect(wrapper.find('.content-preview__frame').exists()).toBe(true)
    })

    it('should hide device frame when showFrame is false', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: 'Test',
          showFrame: false,
        },
      })

      expect(wrapper.find('.content-preview__frame').exists()).toBe(false)
      expect(wrapper.find('.content-preview__no-frame').exists()).toBe(true)
    })

    it('should show view mode selector when showSelector is true', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: 'Test',
          showSelector: true,
        },
      })

      const buttons = wrapper.findAll('button')
      expect(buttons.length).toBeGreaterThan(0)
    })

    it('should hide view mode selector when showSelector is false', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: 'Test',
          showSelector: false,
        },
      })

      expect(wrapper.text()).not.toContain('Escritorio')
      expect(wrapper.text()).not.toContain('Tablet')
    })
  })

  describe('view modes', () => {
    it('should default to desktop view', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: 'Test',
          viewMode: 'desktop',
        },
      })

      expect(wrapper.text()).toContain('1920x1080')
    })

    it('should switch to tablet view', async () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: 'Test',
          viewMode: 'desktop',
          showSelector: true,
        },
      })

      const buttons = wrapper.findAll('button')
      const tabletButton = buttons.find((btn) => btn.text().includes('Tablet'))
      await tabletButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('768x1024')
    })

    it('should switch to mobile view', async () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: 'Test',
          viewMode: 'desktop',
          showSelector: true,
        },
      })

      const buttons = wrapper.findAll('button')
      const mobileButton = buttons.find((btn) => btn.text().includes('Móvil'))
      await mobileButton?.trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('375x667')
    })

    it('should emit view-mode-change event', async () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: 'Test',
          showSelector: true,
        },
      })

      const buttons = wrapper.findAll('button')
      await buttons[1].trigger('click')

      expect(wrapper.emitted('view-mode-change')).toBeTruthy()
    })
  })

  describe('content rendering', () => {
    it('should render plain text', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: 'Plain text content',
          contentType: 'text',
        },
      })

      expect(wrapper.html()).toContain('Plain text content')
    })

    it('should render HTML content', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: '<p>HTML content</p>',
          contentType: 'html',
        },
      })

      expect(wrapper.html()).toContain('<p>HTML content</p>')
    })

    it('should render markdown content', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: '# Heading',
          contentType: 'markdown',
        },
      })

      expect(wrapper.html()).toContain('<h1')
      expect(wrapper.html()).toContain('Heading')
    })
  })

  describe('markdown rendering', () => {
    it('should render headings', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: '# H1\n## H2\n### H3',
          contentType: 'markdown',
        },
      })

      expect(wrapper.html()).toContain('<h1')
      expect(wrapper.html()).toContain('<h2')
      expect(wrapper.html()).toContain('<h3')
    })

    it('should render bold text', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: '**bold text**',
          contentType: 'markdown',
        },
      })

      expect(wrapper.html()).toContain('<strong')
      expect(wrapper.html()).toContain('bold text')
    })

    it('should render italic text', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: '_italic text_',
          contentType: 'markdown',
        },
      })

      expect(wrapper.html()).toContain('<em')
      expect(wrapper.html()).toContain('italic text')
    })

    it('should render links', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: '[Link text](https://example.com)',
          contentType: 'markdown',
        },
      })

      expect(wrapper.html()).toContain('<a')
      expect(wrapper.html()).toContain('href="https://example.com"')
      expect(wrapper.html()).toContain('Link text')
    })

    it('should render images', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: '![Alt text](https://example.com/image.jpg)',
          contentType: 'markdown',
        },
      })

      expect(wrapper.html()).toContain('<img')
      expect(wrapper.html()).toContain('src="https://example.com/image.jpg"')
    })

    it('should render inline code', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: '`inline code`',
          contentType: 'markdown',
        },
      })

      expect(wrapper.html()).toContain('<code')
      expect(wrapper.html()).toContain('inline code')
    })

    it('should render code blocks', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: '```javascript\nconst x = 1;\n```',
          contentType: 'markdown',
        },
      })

      expect(wrapper.html()).toContain('<pre')
      expect(wrapper.html()).toContain('const x = 1;')
    })

    it('should render unordered lists', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: '- Item 1\n- Item 2',
          contentType: 'markdown',
        },
      })

      expect(wrapper.html()).toContain('<li')
      expect(wrapper.html()).toContain('Item 1')
    })

    it('should render blockquotes', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: '> This is a quote',
          contentType: 'markdown',
        },
      })

      expect(wrapper.html()).toContain('<blockquote')
      expect(wrapper.html()).toContain('This is a quote')
    })
  })

  describe('empty state', () => {
    it('should show empty state when content is empty', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: '',
        },
      })

      expect(wrapper.find('.content-preview__empty').exists()).toBe(true)
      expect(wrapper.text()).toContain('No hay contenido')
    })

    it('should not show empty state when content exists', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: 'Some content',
        },
      })

      expect(wrapper.find('.content-preview__empty').exists()).toBe(false)
    })
  })

  describe('loading state', () => {
    it('should show loading state', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: 'Test',
          loading: true,
        },
      })

      expect(wrapper.findComponent({ name: 'Card' }).props('loading')).toBe(true)
    })
  })

  describe('frame header', () => {
    it('should show device resolution in frame header', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: 'Test',
          viewMode: 'desktop',
          showFrame: true,
        },
      })

      expect(wrapper.text()).toContain('1920x1080')
    })

    it('should show browser-like controls', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: 'Test',
          showFrame: true,
        },
      })

      const frame = wrapper.find('.content-preview__frame-header')
      expect(frame.exists()).toBe(true)
    })
  })

  describe('HTML escaping in text mode', () => {
    it('should escape HTML in text mode', () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: '<script>alert("xss")</script>',
          contentType: 'text',
        },
      })

      expect(wrapper.html()).toContain('&lt;script&gt;')
      expect(wrapper.html()).not.toContain('<script>')
    })
  })

  describe('responsive width', () => {
    it('should adjust width for tablet view', async () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: 'Test',
          viewMode: 'tablet',
        },
      })

      const frame = wrapper.find('.content-preview__frame')
      expect(frame.attributes('style')).toContain('max-width: 768px')
    })

    it('should adjust width for mobile view', async () => {
      const wrapper = mount(ContentPreview, {
        props: {
          content: 'Test',
          viewMode: 'mobile',
        },
      })

      const frame = wrapper.find('.content-preview__frame')
      expect(frame.attributes('style')).toContain('max-width: 375px')
    })
  })
})
