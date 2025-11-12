import type { Meta, StoryObj } from '@storybook/vue3'
import { ref } from 'vue'
import ColorPicker from './ColorPicker.vue'

const meta = {
  title: 'Molecules/ColorPicker',
  component: ColorPicker,
  tags: ['autodocs'],
  argTypes: {
    format: {
      control: 'select',
      options: ['hex', 'rgb', 'hsl'],
    },
    size: {
      control: 'select',
      options: ['sm', 'md', 'lg'],
    },
    disabled: {
      control: 'boolean',
    },
    required: {
      control: 'boolean',
    },
    showAlpha: {
      control: 'boolean',
    },
  },
} satisfies Meta<typeof ColorPicker>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  render: (args) => ({
    components: { ColorPicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <ColorPicker v-bind="args" v-model="selected" />
        <p class="mt-4 text-sm text-gray-600">Selected: {{ selected || 'None' }}</p>
      </div>
    `,
  }),
  args: {
    placeholder: 'Select a color',
  },
}

export const WithLabel: Story = {
  render: (args) => ({
    components: { ColorPicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <ColorPicker v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    label: 'Brand Color',
    description: 'Choose your brand primary color',
    placeholder: 'Select color',
  },
}

export const HexFormat: Story = {
  render: (args) => ({
    components: { ColorPicker },
    setup() {
      const selected = ref('#FF5733')
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <ColorPicker v-bind="args" v-model="selected" />
        <p class="mt-4 text-sm text-gray-600">Selected: {{ selected }}</p>
      </div>
    `,
  }),
  args: {
    format: 'hex',
    label: 'HEX Color',
  },
}

export const RgbFormat: Story = {
  render: (args) => ({
    components: { ColorPicker },
    setup() {
      const selected = ref('rgb(255, 87, 51)')
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <ColorPicker v-bind="args" v-model="selected" />
        <p class="mt-4 text-sm text-gray-600">Selected: {{ selected }}</p>
      </div>
    `,
  }),
  args: {
    format: 'rgb',
    label: 'RGB Color',
  },
}

export const HslFormat: Story = {
  render: (args) => ({
    components: { ColorPicker },
    setup() {
      const selected = ref('hsl(9, 100%, 60%)')
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <ColorPicker v-bind="args" v-model="selected" />
        <p class="mt-4 text-sm text-gray-600">Selected: {{ selected }}</p>
      </div>
    `,
  }),
  args: {
    format: 'hsl',
    label: 'HSL Color',
  },
}

export const WithAlpha: Story = {
  render: (args) => ({
    components: { ColorPicker },
    setup() {
      const selected = ref('rgba(255, 87, 51, 0.5)')
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <ColorPicker v-bind="args" v-model="selected" />
        <p class="mt-4 text-sm text-gray-600">Selected: {{ selected }}</p>
        <div class="mt-4 p-4 rounded" :style="{ backgroundColor: selected }">
          <p class="text-white">Preview with opacity</p>
        </div>
      </div>
    `,
  }),
  args: {
    format: 'rgb',
    showAlpha: true,
    label: 'Color with Opacity',
  },
}

export const CustomPresets: Story = {
  render: (args) => ({
    components: { ColorPicker },
    setup() {
      const selected = ref(null)
      const brandColors = [
        '#612d62', // Primary purple
        '#269283', // Secondary teal
        '#10b981', // Success green
        '#f59e0b', // Warning orange
        '#ef4444', // Error red
        '#3b82f6', // Info blue
      ]
      return { args, selected, brandColors }
    },
    template: `
      <div class="p-4">
        <ColorPicker v-bind="args" v-model="selected" :presets="brandColors" />
        <p class="mt-4 text-sm text-gray-600">Selected: {{ selected || 'None' }}</p>
      </div>
    `,
  }),
  args: {
    label: 'Brand Colors',
    description: 'Choose from brand color presets',
  },
}

export const Required: Story = {
  render: (args) => ({
    components: { ColorPicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <ColorPicker v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    label: 'Required Color',
    placeholder: 'Select a color',
    required: true,
  },
}

export const WithError: Story = {
  render: (args) => ({
    components: { ColorPicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <ColorPicker v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    label: 'Color',
    placeholder: 'Select a color',
    error: 'This field is required',
  },
}

export const Disabled: Story = {
  render: (args) => ({
    components: { ColorPicker },
    setup() {
      const selected = ref('#FF5733')
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <ColorPicker v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    label: 'Disabled Color Picker',
    disabled: true,
  },
}

export const SmallSize: Story = {
  render: (args) => ({
    components: { ColorPicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <ColorPicker v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    label: 'Small Color Picker',
    placeholder: 'Select color',
    size: 'sm',
  },
}

export const LargeSize: Story = {
  render: (args) => ({
    components: { ColorPicker },
    setup() {
      const selected = ref(null)
      return { args, selected }
    },
    template: `
      <div class="p-4">
        <ColorPicker v-bind="args" v-model="selected" />
      </div>
    `,
  }),
  args: {
    label: 'Large Color Picker',
    placeholder: 'Select color',
    size: 'lg',
  },
}

export const ThemingUseCase: Story = {
  render: (args) => ({
    components: { ColorPicker },
    setup() {
      const primaryColor = ref('#612d62')
      const secondaryColor = ref('#269283')
      const accentColor = ref('#10b981')

      return { args, primaryColor, secondaryColor, accentColor }
    },
    template: `
      <div class="p-4 space-y-4">
        <h3 class="text-lg font-semibold mb-4">Theme Customization</h3>

        <ColorPicker
          v-model="primaryColor"
          label="Primary Color"
          description="Main brand color used throughout the application"
        />

        <ColorPicker
          v-model="secondaryColor"
          label="Secondary Color"
          description="Supporting brand color for accents and highlights"
        />

        <ColorPicker
          v-model="accentColor"
          label="Accent Color"
          description="Additional accent color for special elements"
        />

        <div class="mt-6 p-4 border rounded-lg">
          <h4 class="font-medium mb-3">Preview</h4>
          <div class="flex gap-2">
            <div class="flex-1 h-20 rounded" :style="{ backgroundColor: primaryColor }"></div>
            <div class="flex-1 h-20 rounded" :style="{ backgroundColor: secondaryColor }"></div>
            <div class="flex-1 h-20 rounded" :style="{ backgroundColor: accentColor }"></div>
          </div>
        </div>
      </div>
    `,
  }),
}
