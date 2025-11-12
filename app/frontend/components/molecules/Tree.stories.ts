import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import Tree, { type TreeNode } from './Tree.vue'

const fileSystemTree: TreeNode[] = [
  {
    id: 'root',
    label: 'Project Root',
    icon: 'folder',
    children: [
      {
        id: 'src',
        label: 'src',
        icon: 'folder',
        children: [
          { id: 'app.ts', label: 'app.ts', icon: 'file-text' },
          { id: 'index.ts', label: 'index.ts', icon: 'file-text' },
          {
            id: 'components',
            label: 'components',
            icon: 'folder',
            children: [
              { id: 'button.vue', label: 'Button.vue', icon: 'file-code' },
              { id: 'input.vue', label: 'Input.vue', icon: 'file-code' },
            ],
          },
        ],
      },
      {
        id: 'public',
        label: 'public',
        icon: 'folder',
        children: [
          { id: 'favicon.ico', label: 'favicon.ico', icon: 'image' },
          { id: 'logo.png', label: 'logo.png', icon: 'image' },
        ],
      },
      { id: 'package.json', label: 'package.json', icon: 'file-text' },
      { id: 'readme.md', label: 'README.md', icon: 'file-text' },
    ],
  },
]

const organizationTree: TreeNode[] = [
  {
    id: 'ceo',
    label: 'CEO - John Smith',
    icon: 'user',
    children: [
      {
        id: 'engineering',
        label: 'Engineering',
        icon: 'users',
        children: [
          { id: 'eng-lead', label: 'Engineering Lead - Alice Johnson', icon: 'user' },
          { id: 'dev-1', label: 'Senior Developer - Bob Wilson', icon: 'user' },
          { id: 'dev-2', label: 'Junior Developer - Carol Davis', icon: 'user' },
        ],
      },
      {
        id: 'marketing',
        label: 'Marketing',
        icon: 'users',
        children: [
          { id: 'mkt-lead', label: 'Marketing Lead - David Brown', icon: 'user' },
          { id: 'mkt-1', label: 'Marketing Specialist - Eve Martinez', icon: 'user' },
        ],
      },
      {
        id: 'sales',
        label: 'Sales',
        icon: 'users',
        children: [
          { id: 'sales-lead', label: 'Sales Lead - Frank Miller', icon: 'user' },
        ],
      },
    ],
  },
]

const meta = {
  title: 'Molecules/Tree',
  component: Tree,
  tags: ['autodocs'],
  argTypes: {
    showCheckboxes: {
      control: 'boolean',
    },
    expandAll: {
      control: 'boolean',
    },
    disabled: {
      control: 'boolean',
    },
    required: {
      control: 'boolean',
    },
  },
} satisfies Meta<typeof Tree>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  render: (args) => ({
    components: { Tree },
    setup() {
      const selected = ref([])
      return { args, fileSystemTree, selected }
    },
    template: `
      <div class="p-4">
        <Tree v-bind="args" :nodes="fileSystemTree" />
      </div>
    `,
  }),
}

export const WithLabel: Story = {
  render: (args) => ({
    components: { Tree },
    setup() {
      return { args, fileSystemTree }
    },
    template: `
      <div class="p-4">
        <Tree v-bind="args" :nodes="fileSystemTree" />
      </div>
    `,
  }),
  args: {
    label: 'File Explorer',
    description: 'Browse project files and folders',
  },
}

export const WithCheckboxes: Story = {
  render: (args) => ({
    components: { Tree },
    setup() {
      const selected = ref([])
      return { args, fileSystemTree, selected }
    },
    template: `
      <div class="p-4">
        <Tree v-bind="args" :nodes="fileSystemTree" v-model="selected" />
        <div class="mt-4 p-3 bg-gray-50 rounded">
          <p class="text-sm font-medium">Selected: {{ selected.length }} items</p>
          <p class="text-xs text-gray-600 mt-1">{{ selected.join(', ') }}</p>
        </div>
      </div>
    `,
  }),
  args: {
    label: 'Select Files',
    showCheckboxes: true,
  },
}

export const ExpandedByDefault: Story = {
  render: (args) => ({
    components: { Tree },
    setup() {
      return { args, fileSystemTree }
    },
    template: `
      <div class="p-4">
        <Tree v-bind="args" :nodes="fileSystemTree" />
      </div>
    `,
  }),
  args: {
    label: 'File System (Expanded)',
    expandAll: true,
  },
}

export const OrganizationChart: Story = {
  render: (args) => ({
    components: { Tree },
    setup() {
      return { args, organizationTree }
    },
    template: `
      <div class="p-4">
        <Tree v-bind="args" :nodes="organizationTree" />
      </div>
    `,
  }),
  args: {
    label: 'Company Organization',
    description: 'Click to expand departments and view team members',
    expandAll: true,
  },
}

export const WithSelection: Story = {
  render: (args) => ({
    components: { Tree },
    setup() {
      const selected = ref(['src', 'components', 'button.vue'])
      return { args, fileSystemTree, selected }
    },
    template: `
      <div class="p-4">
        <Tree v-bind="args" :nodes="fileSystemTree" v-model="selected" />
        <div class="mt-4">
          <p class="text-sm font-medium">Selected Items ({{ selected.length }}):</p>
          <ul class="mt-2 text-xs text-gray-600 list-disc list-inside">
            <li v-for="id in selected" :key="id">{{ id }}</li>
          </ul>
        </div>
      </div>
    `,
  }),
  args: {
    label: 'File Selection',
    showCheckboxes: true,
    expandAll: true,
  },
}

export const Required: Story = {
  render: (args) => ({
    components: { Tree },
    setup() {
      const selected = ref([])
      return { args, fileSystemTree, selected }
    },
    template: `
      <div class="p-4">
        <Tree v-bind="args" :nodes="fileSystemTree" v-model="selected" />
      </div>
    `,
  }),
  args: {
    label: 'Select Required Files',
    showCheckboxes: true,
    required: true,
  },
}

export const WithError: Story = {
  render: (args) => ({
    components: { Tree },
    setup() {
      const selected = ref([])
      return { args, fileSystemTree, selected }
    },
    template: `
      <div class="p-4">
        <Tree v-bind="args" :nodes="fileSystemTree" v-model="selected" />
      </div>
    `,
  }),
  args: {
    label: 'Select Files',
    showCheckboxes: true,
    error: 'At least one file must be selected',
  },
}

export const Disabled: Story = {
  render: (args) => ({
    components: { Tree },
    setup() {
      const selected = ref(['src'])
      return { args, fileSystemTree, selected }
    },
    template: `
      <div class="p-4">
        <Tree v-bind="args" :nodes="fileSystemTree" v-model="selected" />
      </div>
    `,
  }),
  args: {
    label: 'Disabled Tree',
    showCheckboxes: true,
    disabled: true,
  },
}

export const DisabledNodes: Story = {
  render: (args) => ({
    components: { Tree },
    setup() {
      const selected = ref([])
      const treeWithDisabled: TreeNode[] = [
        {
          id: 'root',
          label: 'Project Root',
          icon: 'folder',
          children: [
            { id: 'file1', label: 'file1.ts', icon: 'file-text' },
            { id: 'file2', label: 'file2.ts (read-only)', icon: 'file-text', disabled: true },
            { id: 'file3', label: 'file3.ts', icon: 'file-text' },
          ],
        },
      ]
      return { args, treeWithDisabled, selected }
    },
    template: `
      <div class="p-4">
        <Tree v-bind="args" :nodes="treeWithDisabled" v-model="selected" />
        <p class="mt-2 text-xs text-gray-500">Some files are read-only and cannot be selected</p>
      </div>
    `,
  }),
  args: {
    label: 'Files with Restrictions',
    showCheckboxes: true,
    expandAll: true,
  },
}

export const SimpleList: Story = {
  render: (args) => ({
    components: { Tree },
    setup() {
      const simpleList: TreeNode[] = [
        { id: '1', label: 'Item 1', icon: 'check' },
        { id: '2', label: 'Item 2', icon: 'check' },
        { id: '3', label: 'Item 3', icon: 'check' },
        { id: '4', label: 'Item 4', icon: 'check' },
      ]
      const selected = ref([])
      return { args, simpleList, selected }
    },
    template: `
      <div class="p-4">
        <Tree v-bind="args" :nodes="simpleList" v-model="selected" />
      </div>
    `,
  }),
  args: {
    label: 'Simple Checklist',
    showCheckboxes: true,
  },
}

export const InteractiveDemo: Story = {
  render: (args) => ({
    components: { Tree },
    setup() {
      const selected = ref([])
      const handleNodeClick = (node: TreeNode) => {
        console.log('Node clicked:', node)
      }
      const handleNodeExpand = (node: TreeNode) => {
        console.log('Node expanded:', node)
      }
      const handleNodeCollapse = (node: TreeNode) => {
        console.log('Node collapsed:', node)
      }
      return {
        args,
        fileSystemTree,
        selected,
        handleNodeClick,
        handleNodeExpand,
        handleNodeCollapse,
      }
    },
    template: `
      <div class="p-4">
        <Tree
          v-bind="args"
          :nodes="fileSystemTree"
          v-model="selected"
          @node-click="handleNodeClick"
          @node-expand="handleNodeExpand"
          @node-collapse="handleNodeCollapse"
        />
        <div class="mt-4 p-3 bg-gray-50 rounded">
          <p class="text-sm font-medium">Check console for events</p>
          <p class="text-xs text-gray-600 mt-1">
            Selected: {{ selected.length }} items
          </p>
        </div>
      </div>
    `,
  }),
  args: {
    label: 'Interactive Tree',
    description: 'Click nodes, expand/collapse, and check selections',
    showCheckboxes: true,
  },
}
