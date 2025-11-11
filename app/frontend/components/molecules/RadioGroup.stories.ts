import type { Meta, StoryObj } from '@storybook/vue3-vite'
import RadioGroup from './RadioGroup.vue'

const meta = {
  title: 'Molecules/RadioGroup',
  component: RadioGroup,
  tags: ['autodocs'],
  argTypes: {
    orientation: {
      control: 'select',
      options: ['vertical', 'horizontal'],
    },
    disabled: {
      control: 'boolean',
    },
    required: {
      control: 'boolean',
    },
  },
} satisfies Meta<typeof RadioGroup>

export default meta
type Story = StoryObj<typeof meta>

const mockOptions = [
  { label: 'Option 1', value: '1' },
  { label: 'Option 2', value: '2' },
  { label: 'Option 3', value: '3' },
]

export const Default: Story = {
  args: {
    modelValue: null,
    options: mockOptions,
  },
}

export const WithLabel: Story = {
  args: {
    modelValue: null,
    options: mockOptions,
    label: 'Select an option',
  },
}

export const WithDescription: Story = {
  args: {
    modelValue: null,
    options: mockOptions,
    label: 'Select an option',
    description: 'Choose the option that best fits your needs',
  },
}

export const PreSelected: Story = {
  args: {
    modelValue: '2',
    options: mockOptions,
    label: 'Select an option',
  },
}

export const HorizontalOrientation: Story = {
  args: {
    modelValue: null,
    options: mockOptions,
    label: 'Select an option',
    orientation: 'horizontal',
  },
}

export const Required: Story = {
  args: {
    modelValue: null,
    options: mockOptions,
    label: 'Select an option',
    required: true,
  },
}

export const WithError: Story = {
  args: {
    modelValue: null,
    options: mockOptions,
    label: 'Select an option',
    error: 'Please select an option',
  },
}

export const Disabled: Story = {
  args: {
    modelValue: null,
    options: mockOptions,
    label: 'Select an option',
    disabled: true,
  },
}

export const DisabledOption: Story = {
  args: {
    modelValue: null,
    options: [
      { label: 'Option 1', value: '1' },
      { label: 'Option 2 (Disabled)', value: '2', disabled: true },
      { label: 'Option 3', value: '3' },
    ],
    label: 'Select an option',
  },
}

export const ManyOptions: Story = {
  args: {
    modelValue: null,
    options: [
      { label: 'Extra Small', value: 'xs' },
      { label: 'Small', value: 'sm' },
      { label: 'Medium', value: 'md' },
      { label: 'Large', value: 'lg' },
      { label: 'Extra Large', value: 'xl' },
      { label: '2X Large', value: '2xl' },
    ],
    label: 'Select size',
  },
}

export const NumericValues: Story = {
  args: {
    modelValue: 2,
    options: [
      { label: 'One', value: 1 },
      { label: 'Two', value: 2 },
      { label: 'Three', value: 3 },
    ],
    label: 'Select a number',
  },
}
