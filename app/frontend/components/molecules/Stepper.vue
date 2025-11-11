<script setup lang="ts">
import { computed } from 'vue'
import Icon from '../atoms/Icon.vue'

export interface Step {
  /** Step label */
  label: string
  /** Step description */
  description?: string
  /** Step icon (optional) */
  icon?: string
  /** Step status (optional, computed from currentStep if not provided) */
  status?: 'complete' | 'current' | 'upcoming' | 'error'
}

export interface StepperProps {
  /** Array of steps */
  steps: Step[]
  /** Current step index (0-based) */
  currentStep: number
  /** Orientation */
  orientation?: 'horizontal' | 'vertical'
  /** Allow clicking on completed steps */
  clickable?: boolean
}

const props = withDefaults(defineProps<StepperProps>(), {
  orientation: 'horizontal',
  clickable: false,
})

const emit = defineEmits<{
  'step-click': [index: number]
}>()

const stepsWithStatus = computed(() => {
  return props.steps.map((step, index) => {
    let status = step.status

    if (!status) {
      if (index < props.currentStep) {
        status = 'complete'
      } else if (index === props.currentStep) {
        status = 'current'
      } else {
        status = 'upcoming'
      }
    }

    return {
      ...step,
      status,
      index,
    }
  })
})

const handleStepClick = (index: number, status: string) => {
  if (!props.clickable) return
  if (status !== 'complete') return

  emit('step-click', index)
}

const getStepClasses = (status: string) => {
  const classes = ['flex', 'items-center', 'gap-3']

  if (props.clickable && status === 'complete') {
    classes.push('cursor-pointer', 'hover:opacity-80')
  }

  return classes.join(' ')
}

const getStepNumberClasses = (status: string) => {
  const classes = [
    'flex',
    'items-center',
    'justify-center',
    'w-10',
    'h-10',
    'rounded-full',
    'font-semibold',
    'text-sm',
    'flex-shrink-0',
    'transition-colors',
  ]

  if (status === 'complete') {
    classes.push('bg-primary-600', 'text-white')
  } else if (status === 'current') {
    classes.push('bg-primary-600', 'text-white', 'ring-4', 'ring-primary-100')
  } else if (status === 'error') {
    classes.push('bg-red-600', 'text-white')
  } else {
    classes.push('bg-gray-200', 'text-gray-600')
  }

  return classes.join(' ')
}

const getStepLabelClasses = (status: string) => {
  const classes = ['font-medium']

  if (status === 'current') {
    classes.push('text-primary-600')
  } else if (status === 'error') {
    classes.push('text-red-600')
  } else if (status === 'complete') {
    classes.push('text-gray-900')
  } else {
    classes.push('text-gray-500')
  }

  return classes.join(' ')
}

const getStepDescriptionClasses = (status: string) => {
  const classes = ['text-sm']

  if (status === 'error') {
    classes.push('text-red-500')
  } else {
    classes.push('text-gray-500')
  }

  return classes.join(' ')
}

const getLineClasses = (currentStatus: string, _nextStatus: string) => {
  const classes = ['flex-1', 'h-0.5', 'transition-colors']

  if (props.orientation === 'vertical') {
    classes.push('w-0.5', 'h-full', 'min-h-[2rem]')
    classes.splice(classes.indexOf('flex-1'), 1)
  }

  if (currentStatus === 'complete') {
    classes.push('bg-primary-600')
  } else {
    classes.push('bg-gray-200')
  }

  return classes.join(' ')
}

const getStepIcon = (status: string, _index: number) => {
  if (status === 'complete') return 'check'
  if (status === 'error') return 'x'
  return null
}
</script>

<template>
  <div :class="['stepper', orientation === 'horizontal' ? 'flex items-start' : 'flex flex-col']">
    <template v-for="(step, index) in stepsWithStatus" :key="index">
      <div
        :class="[
          'step',
          orientation === 'horizontal' ? 'flex flex-col items-center' : 'flex gap-3',
        ]"
      >
        <div
          :class="[
            getStepClasses(step.status),
            orientation === 'horizontal' ? 'flex-col items-center' : '',
          ]"
          @click="handleStepClick(index, step.status)"
        >
          <!-- Step Number/Icon -->
          <div :class="getStepNumberClasses(step.status)">
            <Icon v-if="step.icon" :name="step.icon" size="sm" />
            <Icon
              v-else-if="getStepIcon(step.status, index)"
              :name="getStepIcon(step.status, index)!"
              size="sm"
            />
            <span v-else>{{ index + 1 }}</span>
          </div>

          <!-- Step Content -->
          <div
            :class="['step-content', orientation === 'horizontal' ? 'mt-2 text-center' : 'flex-1']"
          >
            <div :class="getStepLabelClasses(step.status)">
              {{ step.label }}
            </div>
            <div v-if="step.description" :class="getStepDescriptionClasses(step.status)">
              {{ step.description }}
            </div>
          </div>
        </div>
      </div>

      <!-- Connecting Line -->
      <div
        v-if="index < stepsWithStatus.length - 1"
        :class="[
          'step-line',
          orientation === 'horizontal' ? 'flex items-center px-4 pt-5' : 'ml-5 flex justify-center',
        ]"
      >
        <div :class="getLineClasses(step.status, stepsWithStatus[index + 1].status)" />
      </div>
    </template>
  </div>
</template>
