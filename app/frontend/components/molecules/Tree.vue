<script setup lang="ts">
import { ref, computed } from 'vue'
import Icon from '../atoms/Icon.vue'

export interface TreeNode {
  id: string | number
  label: string
  children?: TreeNode[]
  icon?: string
  disabled?: boolean
  metadata?: Record<string, unknown>
}

export interface Props {
  nodes: TreeNode[]
  modelValue?: (string | number)[]
  label?: string
  description?: string
  error?: string
  showCheckboxes?: boolean
  expandAll?: boolean
  disabled?: boolean
  required?: boolean
}

const props = withDefaults(defineProps<Props>(), {
  modelValue: () => [],
  showCheckboxes: false,
  expandAll: false,
  disabled: false,
  required: false,
})

const emit = defineEmits<{
  'update:modelValue': [value: (string | number)[]]
  change: [value: (string | number)[]]
  'node-click': [node: TreeNode]
  'node-expand': [node: TreeNode]
  'node-collapse': [node: TreeNode]
}>()

const expandedNodes = ref<Set<string | number>>(new Set())

// Initialize expanded nodes
if (props.expandAll) {
  const expandAllNodes = (nodes: TreeNode[]) => {
    nodes.forEach((node) => {
      if (node.children && node.children.length > 0) {
        expandedNodes.value.add(node.id)
        expandAllNodes(node.children)
      }
    })
  }
  expandAllNodes(props.nodes)
}

// Check if node is expanded
const isExpanded = (nodeId: string | number): boolean => {
  return expandedNodes.value.has(nodeId)
}

// Check if node is selected
const isSelected = (nodeId: string | number): boolean => {
  return props.modelValue.includes(nodeId)
}

// Check if node is indeterminate (some but not all children selected)
const isIndeterminate = (node: TreeNode): boolean => {
  if (!node.children || node.children.length === 0) return false

  const selectedChildren = node.children.filter((child) => {
    if (child.children && child.children.length > 0) {
      return isSelected(child.id) || isIndeterminate(child)
    }
    return isSelected(child.id)
  })

  return selectedChildren.length > 0 && selectedChildren.length < node.children.length
}

// Get all descendant IDs
const getAllDescendantIds = (node: TreeNode): (string | number)[] => {
  const ids: (string | number)[] = [node.id]

  if (node.children) {
    node.children.forEach((child) => {
      ids.push(...getAllDescendantIds(child))
    })
  }

  return ids
}

// Toggle expand/collapse
const toggleExpand = (node: TreeNode) => {
  if (!node.children || node.children.length === 0) return

  if (isExpanded(node.id)) {
    expandedNodes.value.delete(node.id)
    emit('node-collapse', node)
  } else {
    expandedNodes.value.add(node.id)
    emit('node-expand', node)
  }
}

// Handle node click
const handleNodeClick = (node: TreeNode) => {
  if (node.disabled || props.disabled) return
  emit('node-click', node)
}

// Handle checkbox change
const handleCheckboxChange = (node: TreeNode, checked: boolean) => {
  if (node.disabled || props.disabled) return

  const newValue = [...props.modelValue]
  const descendantIds = getAllDescendantIds(node)

  if (checked) {
    // Add node and all descendants
    descendantIds.forEach((id) => {
      if (!newValue.includes(id)) {
        newValue.push(id)
      }
    })
  } else {
    // Remove node and all descendants
    descendantIds.forEach((id) => {
      const index = newValue.indexOf(id)
      if (index > -1) {
        newValue.splice(index, 1)
      }
    })
  }

  emit('update:modelValue', newValue)
  emit('change', newValue)
}

// Render tree node recursively
defineSlots<{
  node?: (props: { node: TreeNode; level: number }) => unknown
}>()
</script>

<template>
  <div class="tree-container">
    <!-- Label -->
    <label v-if="label" class="mb-2 block text-sm font-medium text-gray-700">
      {{ label }}
      <span v-if="required" class="ml-1 text-red-500" aria-label="required">*</span>
    </label>

    <!-- Description -->
    <p v-if="description" class="mb-2 text-sm text-gray-500">
      {{ description }}
    </p>

    <!-- Tree -->
    <div class="rounded-md border border-gray-200 bg-white p-2">
      <TreeNodeComponent
        v-for="node in nodes"
        :key="node.id"
        :node="node"
        :level="0"
        :expanded="isExpanded(node.id)"
        :selected="isSelected(node.id)"
        :indeterminate="isIndeterminate(node)"
        :show-checkboxes="showCheckboxes"
        :disabled="disabled || node.disabled"
        @toggle-expand="toggleExpand"
        @node-click="handleNodeClick"
        @checkbox-change="handleCheckboxChange"
      >
        <template #node="slotProps">
          <slot name="node" v-bind="slotProps" />
        </template>
      </TreeNodeComponent>
    </div>

    <!-- Error Message -->
    <p v-if="error" class="mt-2 text-sm text-red-600">
      {{ error }}
    </p>
  </div>
</template>

<script setup lang="ts">
// Tree Node Component (recursive)
interface TreeNodeProps {
  node: TreeNode
  level: number
  expanded: boolean
  selected: boolean
  indeterminate: boolean
  showCheckboxes: boolean
  disabled?: boolean
}

defineComponent({
  name: 'TreeNodeComponent',
  props: {
    node: {
      type: Object as PropType<TreeNode>,
      required: true,
    },
    level: {
      type: Number,
      required: true,
    },
    expanded: {
      type: Boolean,
      required: true,
    },
    selected: {
      type: Boolean,
      required: true,
    },
    indeterminate: {
      type: Boolean,
      required: true,
    },
    showCheckboxes: {
      type: Boolean,
      required: true,
    },
    disabled: {
      type: Boolean,
      default: false,
    },
  },
  emits: ['toggleExpand', 'nodeClick', 'checkboxChange'],
  setup(props, { emit, slots }) {
    const hasChildren = computed(() => props.node.children && props.node.children.length > 0)

    const handleToggle = () => {
      emit('toggleExpand', props.node)
    }

    const handleClick = () => {
      emit('nodeClick', props.node)
    }

    const handleCheckboxChange = (event: Event) => {
      const checked = (event.target as HTMLInputElement).checked
      emit('checkboxChange', props.node, checked)
    }

    return () => {
      const paddingLeft = `${props.level * 20 + 4}px`

      return h('div', { class: 'tree-node' }, [
        // Node content
        h(
          'div',
          {
            class: [
              'flex items-center gap-2 rounded px-2 py-1.5 hover:bg-gray-50 transition-colors',
              { 'bg-gray-50': props.selected && !props.showCheckboxes },
              { 'cursor-not-allowed opacity-50': props.disabled },
            ],
            style: { paddingLeft },
          },
          [
            // Expand/collapse button
            hasChildren.value
              ? h(
                  'button',
                  {
                    type: 'button',
                    class: 'flex-shrink-0 p-0.5 hover:bg-gray-200 rounded',
                    onClick: handleToggle,
                    disabled: props.disabled,
                  },
                  [
                    h(Icon, {
                      name: props.expanded ? 'chevron-down' : 'chevron-right',
                      size: 16,
                    }),
                  ]
                )
              : h('span', { class: 'w-5' }),

            // Checkbox
            props.showCheckboxes
              ? h('input', {
                  type: 'checkbox',
                  checked: props.selected,
                  disabled: props.disabled,
                  indeterminate: props.indeterminate,
                  onChange: handleCheckboxChange,
                  class: 'rounded border-gray-300 text-primary-600 focus:ring-primary-500',
                })
              : null,

            // Icon
            props.node.icon
              ? h('div', { class: 'flex-shrink-0' }, [
                  h(Icon, { name: props.node.icon, size: 18 }),
                ])
              : null,

            // Label
            slots.node
              ? slots.node({ node: props.node, level: props.level })
              : h(
                  'span',
                  {
                    class: ['flex-1 text-sm cursor-pointer', { 'font-medium': props.selected }],
                    onClick: handleClick,
                  },
                  props.node.label
                ),
          ]
        ),

        // Children (recursive)
        hasChildren.value && props.expanded
          ? h(
              'div',
              { class: 'tree-children' },
              props.node.children!.map((child) =>
                h(TreeNodeComponent, {
                  key: child.id,
                  node: child,
                  level: props.level + 1,
                  expanded: (inject('isExpanded') as (id: string | number) => boolean)(child.id),
                  selected: (inject('isSelected') as (id: string | number) => boolean)(child.id),
                  indeterminate: (inject('isIndeterminate') as (node: TreeNode) => boolean)(child),
                  showCheckboxes: props.showCheckboxes,
                  disabled: props.disabled || child.disabled,
                  onToggleExpand: (node: TreeNode) => emit('toggleExpand', node),
                  onNodeClick: (node: TreeNode) => emit('nodeClick', node),
                  onCheckboxChange: (node: TreeNode, checked: boolean) =>
                    emit('checkboxChange', node, checked),
                })
              )
            )
          : null,
      ])
    }
  },
})

// Provide functions for nested components
provide('isExpanded', isExpanded)
provide('isSelected', isSelected)
provide('isIndeterminate', isIndeterminate)
</script>

<script lang="ts">
import { defineComponent, h, computed, inject, provide, type PropType } from 'vue'
export const TreeNodeComponent = defineComponent({
  name: 'TreeNodeComponent',
  props: {
    node: {
      type: Object as PropType<TreeNode>,
      required: true,
    },
    level: {
      type: Number,
      required: true,
    },
    expanded: {
      type: Boolean,
      required: true,
    },
    selected: {
      type: Boolean,
      required: true,
    },
    indeterminate: {
      type: Boolean,
      required: true,
    },
    showCheckboxes: {
      type: Boolean,
      required: true,
    },
    disabled: {
      type: Boolean,
      default: false,
    },
  },
  emits: ['toggleExpand', 'nodeClick', 'checkboxChange'],
  setup(props, { emit, slots }) {
    const hasChildren = computed(() => props.node.children && props.node.children.length > 0)
    const isExpanded = inject('isExpanded') as ((id: string | number) => boolean) | undefined
    const isSelected = inject('isSelected') as ((id: string | number) => boolean) | undefined
    const isIndeterminate = inject('isIndeterminate') as ((node: TreeNode) => boolean) | undefined

    const handleToggle = () => {
      emit('toggleExpand', props.node)
    }

    const handleClick = () => {
      emit('nodeClick', props.node)
    }

    const handleCheckboxChange = (event: Event) => {
      const checked = (event.target as HTMLInputElement).checked
      emit('checkboxChange', props.node, checked)
    }

    return () => {
      const paddingLeft = `${props.level * 20 + 4}px`

      return h('div', { class: 'tree-node' }, [
        h(
          'div',
          {
            class: [
              'flex items-center gap-2 rounded px-2 py-1.5 hover:bg-gray-50 transition-colors',
              { 'bg-gray-50': props.selected && !props.showCheckboxes },
              { 'cursor-not-allowed opacity-50': props.disabled },
            ],
            style: { paddingLeft },
          },
          [
            hasChildren.value
              ? h(
                  'button',
                  {
                    type: 'button',
                    class: 'flex-shrink-0 p-0.5 hover:bg-gray-200 rounded',
                    onClick: handleToggle,
                    disabled: props.disabled,
                  },
                  [h(Icon, { name: props.expanded ? 'chevron-down' : 'chevron-right', size: 16 })]
                )
              : h('span', { class: 'w-5' }),

            props.showCheckboxes
              ? h('input', {
                  type: 'checkbox',
                  checked: props.selected,
                  disabled: props.disabled,
                  indeterminate: props.indeterminate,
                  onChange: handleCheckboxChange,
                  class: 'rounded border-gray-300 text-primary-600 focus:ring-primary-500',
                })
              : null,

            props.node.icon ? h('div', { class: 'flex-shrink-0' }, [h(Icon, { name: props.node.icon, size: 18 })]) : null,

            slots.node
              ? slots.node({ node: props.node, level: props.level })
              : h(
                  'span',
                  {
                    class: ['flex-1 text-sm cursor-pointer', { 'font-medium': props.selected }],
                    onClick: handleClick,
                  },
                  props.node.label
                ),
          ]
        ),

        hasChildren.value && props.expanded
          ? h(
              'div',
              { class: 'tree-children' },
              props.node.children!.map((child) =>
                h(TreeNodeComponent, {
                  key: child.id,
                  node: child,
                  level: props.level + 1,
                  expanded: isExpanded ? isExpanded(child.id) : false,
                  selected: isSelected ? isSelected(child.id) : false,
                  indeterminate: isIndeterminate ? isIndeterminate(child) : false,
                  showCheckboxes: props.showCheckboxes,
                  disabled: props.disabled || child.disabled,
                  onToggleExpand: (node: TreeNode) => emit('toggleExpand', node),
                  onNodeClick: (node: TreeNode) => emit('nodeClick', node),
                  onCheckboxChange: (node: TreeNode, checked: boolean) => emit('checkboxChange', node, checked),
                })
              )
            )
          : null,
      ])
    }
  },
})
</script>
