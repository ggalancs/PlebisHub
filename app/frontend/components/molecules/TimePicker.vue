<script setup lang="ts">
import { ref, computed, watch } from 'vue'
import Icon from '../atoms/Icon.vue'

export interface Props {
  modelValue: string | null
  label?: string
  description?: string
  placeholder?: string
  disabled?: boolean
  required?: boolean
  error?: string
  format?: '12h' | '24h'
  showSeconds?: boolean
  minuteStep?: number
  secondStep?: number
  size?: 'sm' | 'md' | 'lg'
}

const props = withDefaults(defineProps<Props>(), {
  disabled: false,
  required: false,
  format: '12h',
  showSeconds: false,
  minuteStep: 1,
  secondStep: 1,
  size: 'md',
  placeholder: 'Select time',
})

const emit = defineEmits<{
  'update:modelValue': [value: string | null]
  change: [value: string | null]
}>()

const isOpen = ref(false)
const selectedHour = ref<number>(12)
const selectedMinute = ref<number>(0)
const selectedSecond = ref<number>(0)
const selectedPeriod = ref<'AM' | 'PM'>('AM')

// Generate hour options
const hourOptions = computed(() => {
  if (props.format === '24h') {
    return Array.from({ length: 24 }, (_, i) => i)
  } else {
    return Array.from({ length: 12 }, (_, i) => (i === 0 ? 12 : i))
  }
})

// Generate minute options
const minuteOptions = computed(() => {
  const options: number[] = []
  for (let i = 0; i < 60; i += props.minuteStep) {
    options.push(i)
  }
  return options
})

// Generate second options
const secondOptions = computed(() => {
  const options: number[] = []
  for (let i = 0; i < 60; i += props.secondStep) {
    options.push(i)
  }
  return options
})

// Format time for display
const formatTime = (hour: number, minute: number, second: number, period?: 'AM' | 'PM'): string => {
  const pad = (n: number) => n.toString().padStart(2, '0')

  if (props.format === '24h') {
    if (props.showSeconds) {
      return `${pad(hour)}:${pad(minute)}:${pad(second)}`
    }
    return `${pad(hour)}:${pad(minute)}`
  } else {
    const displayHour = hour === 0 ? 12 : hour > 12 ? hour - 12 : hour
    if (props.showSeconds) {
      return `${pad(displayHour)}:${pad(minute)}:${pad(second)} ${period}`
    }
    return `${pad(displayHour)}:${pad(minute)} ${period}`
  }
}

// Parse time from string
const parseTime = (timeString: string) => {
  if (!timeString) return

  const parts = timeString.split(' ')
  const timeParts = parts[0].split(':')
  const period = parts[1] as 'AM' | 'PM' | undefined

  let hour = parseInt(timeParts[0])
  const minute = parseInt(timeParts[1])
  const second = timeParts[2] ? parseInt(timeParts[2]) : 0

  if (props.format === '12h' && period) {
    if (period === 'PM' && hour !== 12) {
      hour += 12
    } else if (period === 'AM' && hour === 12) {
      hour = 0
    }
    selectedPeriod.value = period
  }

  selectedHour.value = hour
  selectedMinute.value = minute
  selectedSecond.value = second
}

// Display value
const displayValue = computed(() => {
  if (!props.modelValue) return ''

  try {
    parseTime(props.modelValue)
    return formatTime(selectedHour.value, selectedMinute.value, selectedSecond.value, selectedPeriod.value)
  } catch {
    return ''
  }
})

// Convert to 24h format for internal use
const to24Hour = (hour: number, period: 'AM' | 'PM'): number => {
  if (props.format === '24h') return hour

  if (period === 'AM') {
    return hour === 12 ? 0 : hour
  } else {
    return hour === 12 ? 12 : hour + 12
  }
}

// Update time
const updateTime = () => {
  let hour = selectedHour.value
  if (props.format === '12h') {
    hour = to24Hour(selectedHour.value, selectedPeriod.value)
  }

  const timeString = formatTime(hour, selectedMinute.value, selectedSecond.value, selectedPeriod.value)

  emit('update:modelValue', timeString)
  emit('change', timeString)
}

// Handle hour change
const handleHourChange = (hour: number) => {
  selectedHour.value = hour
  updateTime()
}

// Handle minute change
const handleMinuteChange = (minute: number) => {
  selectedMinute.value = minute
  updateTime()
}

// Handle second change
const handleSecondChange = (second: number) => {
  selectedSecond.value = second
  updateTime()
}

// Handle period change
const handlePeriodChange = (period: 'AM' | 'PM') => {
  selectedPeriod.value = period
  updateTime()
}

// Toggle dropdown
const toggleDropdown = () => {
  if (props.disabled) return
  isOpen.value = !isOpen.value
}

// Close dropdown
const closeDropdown = () => {
  isOpen.value = false
}

// Clear selection
const clearSelection = () => {
  if (props.disabled) return

  selectedHour.value = 12
  selectedMinute.value = 0
  selectedSecond.value = 0
  selectedPeriod.value = 'AM'

  emit('update:modelValue', null)
  emit('change', null)
}

// Size classes
const sizeClasses = computed(() => {
  switch (props.size) {
    case 'sm':
      return 'text-sm'
    case 'lg':
      return 'text-lg'
    default:
      return 'text-base'
  }
})

// Click outside handler
const handleClickOutside = (e: MouseEvent) => {
  if (!isOpen.value) return

  const target = e.target as Node
  const container = document.querySelector('.timepicker-container')

  if (container && !container.contains(target)) {
    closeDropdown()
  }
}

// Initialize from modelValue
watch(
  () => props.modelValue,
  (value) => {
    if (value) {
      parseTime(value)
    }
  },
  { immediate: true }
)

watch(isOpen, (value) => {
  if (value) {
    document.addEventListener('click', handleClickOutside)
  } else {
    document.removeEventListener('click', handleClickOutside)
  }
})

// Pad number with zero
const pad = (n: number) => n.toString().padStart(2, '0')
</script>

<template>
  <div class="timepicker-container" :class="sizeClasses">
    <!-- Label -->
    <label v-if="label" class="mb-2 block text-sm font-medium text-gray-700">
      {{ label }}
      <span v-if="required" class="ml-1 text-red-500" aria-label="required">*</span>
    </label>

    <!-- Description -->
    <p v-if="description" class="mb-2 text-sm text-gray-500">
      {{ description }}
    </p>

    <!-- Input -->
    <div class="relative">
      <div
        class="flex w-full cursor-pointer items-center rounded-md border bg-white"
        :class="[
          error ? 'border-red-500' : 'border-gray-300',
          disabled ? 'cursor-not-allowed bg-gray-100' : 'hover:border-gray-400',
        ]"
        @click="toggleDropdown"
      >
        <div class="flex-1 px-3 py-2 text-gray-700" :class="{ 'text-gray-400': !displayValue }">
          {{ displayValue || placeholder }}
        </div>

        <div class="flex items-center gap-1 pr-2">
          <button
            v-if="displayValue && !disabled"
            type="button"
            class="rounded p-1 hover:bg-gray-100"
            @click.stop="clearSelection"
            aria-label="Clear selection"
          >
            <Icon name="x" :size="16" />
          </button>

          <Icon name="clock" :size="20" class="text-gray-400" />
        </div>
      </div>

      <!-- Time Picker Dropdown -->
      <Transition
        enter-active-class="transition-opacity duration-100"
        leave-active-class="transition-opacity duration-100"
        enter-from-class="opacity-0"
        leave-to-class="opacity-0"
      >
        <div
          v-if="isOpen"
          class="absolute z-50 mt-1 rounded-lg border border-gray-200 bg-white shadow-lg"
          @click.stop
        >
          <div class="flex gap-2 p-4">
            <!-- Hour selector -->
            <div class="flex flex-col">
              <div class="mb-2 text-center text-xs font-medium text-gray-500">Hour</div>
              <div class="h-48 w-16 overflow-y-auto rounded border border-gray-200">
                <button
                  v-for="hour in hourOptions"
                  :key="hour"
                  type="button"
                  class="w-full px-3 py-2 text-center text-sm transition-colors hover:bg-gray-100"
                  :class="{
                    'bg-primary-600 text-white hover:bg-primary-700': selectedHour === hour,
                  }"
                  @click="handleHourChange(hour)"
                >
                  {{ pad(hour) }}
                </button>
              </div>
            </div>

            <!-- Minute selector -->
            <div class="flex flex-col">
              <div class="mb-2 text-center text-xs font-medium text-gray-500">Min</div>
              <div class="h-48 w-16 overflow-y-auto rounded border border-gray-200">
                <button
                  v-for="minute in minuteOptions"
                  :key="minute"
                  type="button"
                  class="w-full px-3 py-2 text-center text-sm transition-colors hover:bg-gray-100"
                  :class="{
                    'bg-primary-600 text-white hover:bg-primary-700': selectedMinute === minute,
                  }"
                  @click="handleMinuteChange(minute)"
                >
                  {{ pad(minute) }}
                </button>
              </div>
            </div>

            <!-- Second selector -->
            <div v-if="showSeconds" class="flex flex-col">
              <div class="mb-2 text-center text-xs font-medium text-gray-500">Sec</div>
              <div class="h-48 w-16 overflow-y-auto rounded border border-gray-200">
                <button
                  v-for="second in secondOptions"
                  :key="second"
                  type="button"
                  class="w-full px-3 py-2 text-center text-sm transition-colors hover:bg-gray-100"
                  :class="{
                    'bg-primary-600 text-white hover:bg-primary-700': selectedSecond === second,
                  }"
                  @click="handleSecondChange(second)"
                >
                  {{ pad(second) }}
                </button>
              </div>
            </div>

            <!-- Period selector (12h format) -->
            <div v-if="format === '12h'" class="flex flex-col">
              <div class="mb-2 text-center text-xs font-medium text-gray-500">Period</div>
              <div class="flex h-48 w-16 flex-col gap-2">
                <button
                  type="button"
                  class="flex-1 rounded border border-gray-200 text-sm transition-colors hover:bg-gray-100"
                  :class="{
                    'bg-primary-600 text-white hover:bg-primary-700': selectedPeriod === 'AM',
                  }"
                  @click="handlePeriodChange('AM')"
                >
                  AM
                </button>
                <button
                  type="button"
                  class="flex-1 rounded border border-gray-200 text-sm transition-colors hover:bg-gray-100"
                  :class="{
                    'bg-primary-600 text-white hover:bg-primary-700': selectedPeriod === 'PM',
                  }"
                  @click="handlePeriodChange('PM')"
                >
                  PM
                </button>
              </div>
            </div>
          </div>
        </div>
      </Transition>
    </div>

    <!-- Error Message -->
    <p v-if="error" class="mt-2 text-sm text-red-600">
      {{ error }}
    </p>
  </div>
</template>
