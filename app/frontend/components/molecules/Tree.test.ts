import { describe, it, expect } from 'vitest'
import { mount } from '@vue/test-utils'
import { nextTick } from 'vue'
import Tree, { type TreeNode } from './Tree.vue'
import Icon from '../atoms/Icon.vue'

const mockTreeData: TreeNode[] = [
  {
    id: '1',
    label: 'Root 1',
    children: [
      { id: '1-1', label: 'Child 1-1' },
      {
        id: '1-2',
        label: 'Child 1-2',
        children: [
          { id: '1-2-1', label: 'Grandchild 1-2-1' },
          { id: '1-2-2', label: 'Grandchild 1-2-2' },
        ],
      },
    ],
  },
  {
    id: '2',
    label: 'Root 2',
    children: [{ id: '2-1', label: 'Child 2-1' }],
  },
  { id: '3', label: 'Root 3' },
]

describe('Tree', () => {
  describe('Basic Rendering', () => {
    it('renders correctly', () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
        },
        global: {
          components: { Icon },
        },
      })
      expect(wrapper.exists()).toBe(true)
    })

    it('renders with label', () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
          label: 'File Tree',
        },
        global: {
          components: { Icon },
        },
      })
      expect(wrapper.find('label').text()).toContain('File Tree')
    })

    it('renders required indicator', () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
          label: 'Tree',
          required: true,
        },
        global: {
          components: { Icon },
        },
      })
      expect(wrapper.find('span[aria-label="required"]').text()).toBe('*')
    })

    it('renders description', () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
          description: 'Select items from tree',
        },
        global: {
          components: { Icon },
        },
      })
      expect(wrapper.text()).toContain('Select items from tree')
    })

    it('renders error message', () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
          error: 'Selection required',
        },
        global: {
          components: { Icon },
        },
      })
      expect(wrapper.text()).toContain('Selection required')
      expect(wrapper.find('.text-red-600').exists()).toBe(true)
    })

    it('renders root nodes', () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
        },
        global: {
          components: { Icon },
        },
      })
      expect(wrapper.text()).toContain('Root 1')
      expect(wrapper.text()).toContain('Root 2')
      expect(wrapper.text()).toContain('Root 3')
    })

    it('does not render children by default', () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
        },
        global: {
          components: { Icon },
        },
      })
      expect(wrapper.text()).not.toContain('Child 1-1')
      expect(wrapper.text()).not.toContain('Child 1-2')
    })
  })

  describe('Expand/Collapse', () => {
    it('shows expand icon for nodes with children', () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
        },
        global: {
          components: { Icon },
        },
      })
      const expandButtons = wrapper.findAll('button[type="button"]')
      expect(expandButtons.length).toBeGreaterThan(0)
    })

    it('expands node on click', async () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
        },
        global: {
          components: { Icon },
        },
      })

      const expandButtons = wrapper.findAll('button[type="button"]')
      await expandButtons[0].trigger('click')
      await nextTick()

      expect(wrapper.text()).toContain('Child 1-1')
      expect(wrapper.text()).toContain('Child 1-2')
    })

    it('collapses node on second click', async () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
        },
        global: {
          components: { Icon },
        },
      })

      const expandButtons = wrapper.findAll('button[type="button"]')
      await expandButtons[0].trigger('click')
      await nextTick()
      expect(wrapper.text()).toContain('Child 1-1')

      await expandButtons[0].trigger('click')
      await nextTick()
      expect(wrapper.text()).not.toContain('Child 1-1')
    })

    it('expands all nodes when expandAll is true', () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
          expandAll: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toContain('Child 1-1')
      expect(wrapper.text()).toContain('Child 1-2')
      expect(wrapper.text()).toContain('Grandchild 1-2-1')
      expect(wrapper.text()).toContain('Child 2-1')
    })

    it('emits node-expand event', async () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
        },
        global: {
          components: { Icon },
        },
      })

      const expandButtons = wrapper.findAll('button[type="button"]')
      await expandButtons[0].trigger('click')
      await nextTick()

      expect(wrapper.emitted('node-expand')).toBeTruthy()
    })

    it('emits node-collapse event', async () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
        },
        global: {
          components: { Icon },
        },
      })

      const expandButtons = wrapper.findAll('button[type="button"]')
      await expandButtons[0].trigger('click')
      await nextTick()
      await expandButtons[0].trigger('click')
      await nextTick()

      expect(wrapper.emitted('node-collapse')).toBeTruthy()
    })
  })

  describe('Node Click', () => {
    it('emits node-click event', async () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
        },
        global: {
          components: { Icon },
        },
      })

      const nodeLabels = wrapper.findAll('.cursor-pointer')
      await nodeLabels[0].trigger('click')
      await nextTick()

      expect(wrapper.emitted('node-click')).toBeTruthy()
    })

    it('does not emit node-click when disabled', async () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
          disabled: true,
        },
        global: {
          components: { Icon },
        },
      })

      const nodeLabels = wrapper.findAll('.cursor-pointer')
      await nodeLabels[0].trigger('click')
      await nextTick()

      expect(wrapper.emitted('node-click')).toBeFalsy()
    })
  })

  describe('Checkbox Mode', () => {
    it('shows checkboxes when showCheckboxes is true', () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
          showCheckboxes: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.findAll('input[type="checkbox"]').length).toBeGreaterThan(0)
    })

    it('hides checkboxes by default', () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
          showCheckboxes: false,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.findAll('input[type="checkbox"]').length).toBe(0)
    })

    it('checks checkbox when node is selected', () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
          modelValue: ['1'],
          showCheckboxes: true,
        },
        global: {
          components: { Icon },
        },
      })

      const checkboxes = wrapper.findAll('input[type="checkbox"]')
      expect((checkboxes[0].element as HTMLInputElement).checked).toBe(true)
    })

    it('emits update:modelValue on checkbox change', async () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
          modelValue: [],
          showCheckboxes: true,
        },
        global: {
          components: { Icon },
        },
      })

      const checkboxes = wrapper.findAll('input[type="checkbox"]')
      await checkboxes[0].trigger('change')
      await nextTick()

      expect(wrapper.emitted('update:modelValue')).toBeTruthy()
      expect(wrapper.emitted('change')).toBeTruthy()
    })

    it('selects all children when parent is selected', async () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
          modelValue: [],
          showCheckboxes: true,
          expandAll: true,
        },
        global: {
          components: { Icon },
        },
      })

      const checkboxes = wrapper.findAll('input[type="checkbox"]')
      await checkboxes[0].trigger('change')
      await nextTick()

      const emittedValue = wrapper.emitted('update:modelValue')?.[0][0] as (string | number)[]
      expect(emittedValue).toContain('1')
      expect(emittedValue).toContain('1-1')
      expect(emittedValue).toContain('1-2')
    })

    it('deselects all children when parent is deselected', async () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
          modelValue: ['1', '1-1', '1-2', '1-2-1', '1-2-2'],
          showCheckboxes: true,
          expandAll: true,
        },
        global: {
          components: { Icon },
        },
      })

      const checkboxes = wrapper.findAll('input[type="checkbox"]')
      await checkboxes[0].trigger('change')
      await nextTick()

      const emittedValue = wrapper.emitted('update:modelValue')?.[0][0] as (string | number)[]
      expect(emittedValue).not.toContain('1')
      expect(emittedValue).not.toContain('1-1')
      expect(emittedValue).not.toContain('1-2')
    })

    it('disables checkbox when node is disabled', () => {
      const disabledTree: TreeNode[] = [
        { id: '1', label: 'Node 1', disabled: true },
        { id: '2', label: 'Node 2' },
      ]

      const wrapper = mount(Tree, {
        props: {
          nodes: disabledTree,
          showCheckboxes: true,
        },
        global: {
          components: { Icon },
        },
      })

      const checkboxes = wrapper.findAll('input[type="checkbox"]')
      expect((checkboxes[0].element as HTMLInputElement).disabled).toBe(true)
      expect((checkboxes[1].element as HTMLInputElement).disabled).toBe(false)
    })
  })

  describe('Icons', () => {
    it('renders node icon when provided', () => {
      const treeWithIcons: TreeNode[] = [
        { id: '1', label: 'Folder', icon: 'folder' },
        { id: '2', label: 'File', icon: 'file' },
      ]

      const wrapper = mount(Tree, {
        props: {
          nodes: treeWithIcons,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toContain('Folder')
      expect(wrapper.text()).toContain('File')
    })
  })

  describe('Disabled State', () => {
    it('disables all nodes when disabled prop is true', () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
          disabled: true,
          showCheckboxes: true,
        },
        global: {
          components: { Icon },
        },
      })

      const checkboxes = wrapper.findAll('input[type="checkbox"]')
      checkboxes.forEach((checkbox) => {
        expect((checkbox.element as HTMLInputElement).disabled).toBe(true)
      })
    })

    it('applies disabled styles', () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
          disabled: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.html()).toContain('cursor-not-allowed')
      expect(wrapper.html()).toContain('opacity-50')
    })
  })

  describe('Nested Levels', () => {
    it('renders deeply nested nodes', async () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
          expandAll: true,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toContain('Grandchild 1-2-1')
      expect(wrapper.text()).toContain('Grandchild 1-2-2')
    })

    it('applies correct indentation for nested levels', async () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: mockTreeData,
          expandAll: true,
        },
        global: {
          components: { Icon },
        },
      })

      // Check that HTML contains elements with different padding levels
      const html = wrapper.html()
      expect(html).toContain('padding-left')
    })
  })

  describe('Edge Cases', () => {
    it('handles empty nodes array', () => {
      const wrapper = mount(Tree, {
        props: {
          nodes: [],
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.exists()).toBe(true)
    })

    it('handles nodes without children', () => {
      const flatTree: TreeNode[] = [
        { id: '1', label: 'Node 1' },
        { id: '2', label: 'Node 2' },
        { id: '3', label: 'Node 3' },
      ]

      const wrapper = mount(Tree, {
        props: {
          nodes: flatTree,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toContain('Node 1')
      expect(wrapper.text()).toContain('Node 2')
      expect(wrapper.text()).toContain('Node 3')
    })

    it('handles single level tree', () => {
      const singleLevel: TreeNode[] = [{ id: '1', label: 'Only Node' }]

      const wrapper = mount(Tree, {
        props: {
          nodes: singleLevel,
        },
        global: {
          components: { Icon },
        },
      })

      expect(wrapper.text()).toContain('Only Node')
    })
  })
})
