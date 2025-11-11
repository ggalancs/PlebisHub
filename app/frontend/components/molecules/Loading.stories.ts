import type { Meta, StoryObj } from '@storybook/vue3-vite'
import { ref } from 'vue'
import Loading from './Loading.vue'
import Button from '../atoms/Button.vue'

const meta = {
  title: 'Molecules/Loading',
  component: Loading,
  tags: ['autodocs'],
} satisfies Meta<typeof Loading>

export default meta
type Story = StoryObj<typeof meta>

export const Default: Story = {
  render: () => ({
    components: { Loading, Button },
    setup() {
      const isLoading = ref(false)

      const showLoading = () => {
        isLoading.value = true
        setTimeout(() => {
          isLoading.value = false
        }, 3000)
      }

      return { isLoading, showLoading }
    },
    template: `
      <div>
        <Button @click="showLoading">Show Loading</Button>
        <Loading v-model="isLoading" />
      </div>
    `,
  }),
}

export const WithText: Story = {
  render: () => ({
    components: { Loading, Button },
    setup() {
      const isLoading = ref(false)

      const showLoading = () => {
        isLoading.value = true
        setTimeout(() => {
          isLoading.value = false
        }, 3000)
      }

      return { isLoading, showLoading }
    },
    template: `
      <div>
        <Button @click="showLoading">Show Loading with Text</Button>
        <Loading v-model="isLoading" text="Loading your data..." />
      </div>
    `,
  }),
}

export const DotsSpinner: Story = {
  render: () => ({
    components: { Loading, Button },
    setup() {
      const isLoading = ref(false)

      const showLoading = () => {
        isLoading.value = true
        setTimeout(() => {
          isLoading.value = false
        }, 3000)
      }

      return { isLoading, showLoading }
    },
    template: `
      <div>
        <Button @click="showLoading">Show Dots Spinner</Button>
        <Loading v-model="isLoading" spinner="dots" text="Processing..." />
      </div>
    `,
  }),
}

export const PulseSpinner: Story = {
  render: () => ({
    components: { Loading, Button },
    setup() {
      const isLoading = ref(false)

      const showLoading = () => {
        isLoading.value = true
        setTimeout(() => {
          isLoading.value = false
        }, 3000)
      }

      return { isLoading, showLoading }
    },
    template: `
      <div>
        <Button @click="showLoading">Show Pulse Spinner</Button>
        <Loading v-model="isLoading" spinner="pulse" />
      </div>
    `,
  }),
}

export const ProgressBar: Story = {
  render: () => ({
    components: { Loading, Button },
    setup() {
      const isLoading = ref(false)
      const progress = ref(0)

      const showLoading = () => {
        isLoading.value = true
        progress.value = 0

        const interval = setInterval(() => {
          progress.value += 10
          if (progress.value >= 100) {
            clearInterval(interval)
            setTimeout(() => {
              isLoading.value = false
            }, 500)
          }
        }, 300)
      }

      return { isLoading, progress, showLoading }
    },
    template: `
      <div>
        <Button @click="showLoading">Show Progress Bar</Button>
        <Loading
          v-model="isLoading"
          spinner="bar"
          :progress="progress"
          :text="\`\${progress}% complete\`"
        />
      </div>
    `,
  }),
}

export const DarkOpacity: Story = {
  render: () => ({
    components: { Loading, Button },
    setup() {
      const isLoading = ref(false)

      const showLoading = () => {
        isLoading.value = true
        setTimeout(() => {
          isLoading.value = false
        }, 3000)
      }

      return { isLoading, showLoading }
    },
    template: `
      <div>
        <Button @click="showLoading">Show Dark Loading</Button>
        <Loading v-model="isLoading" opacity="dark" text="Loading..." />
      </div>
    `,
  }),
}

export const WithBlur: Story = {
  render: () => ({
    components: { Loading, Button },
    setup() {
      const isLoading = ref(false)

      const showLoading = () => {
        isLoading.value = true
        setTimeout(() => {
          isLoading.value = false
        }, 3000)
      }

      return { isLoading, showLoading }
    },
    template: `
      <div>
        <div class="p-8 bg-gradient-to-r from-purple-400 to-teal-400 rounded-lg">
          <h2 class="text-2xl font-bold text-white mb-4">Content Behind Overlay</h2>
          <p class="text-white">This content will be blurred when loading</p>
        </div>
        <Button @click="showLoading" class="mt-4">Show Blurred Loading</Button>
        <Loading v-model="isLoading" blur text="Loading..." />
      </div>
    `,
  }),
}

export const AllSizes: Story = {
  render: () => ({
    components: { Loading, Button },
    setup() {
      const isLoadingSm = ref(false)
      const isLoadingMd = ref(false)
      const isLoadingLg = ref(false)

      const showSmall = () => {
        isLoadingSm.value = true
        setTimeout(() => {
          isLoadingSm.value = false
        }, 2000)
      }

      const showMedium = () => {
        isLoadingMd.value = true
        setTimeout(() => {
          isLoadingMd.value = false
        }, 2000)
      }

      const showLarge = () => {
        isLoadingLg.value = true
        setTimeout(() => {
          isLoadingLg.value = false
        }, 2000)
      }

      return { isLoadingSm, isLoadingMd, isLoadingLg, showSmall, showMedium, showLarge }
    },
    template: `
      <div class="space-x-4">
        <Button @click="showSmall">Small</Button>
        <Button @click="showMedium">Medium</Button>
        <Button @click="showLarge">Large</Button>

        <Loading v-model="isLoadingSm" size="sm" text="Small" />
        <Loading v-model="isLoadingMd" size="md" text="Medium" />
        <Loading v-model="isLoadingLg" size="lg" text="Large" />
      </div>
    `,
  }),
}

export const AllSpinners: Story = {
  render: () => ({
    components: { Loading, Button },
    setup() {
      const spinner = ref(false)
      const dots = ref(false)
      const pulse = ref(false)
      const bar = ref(false)
      const progress = ref(0)

      const showSpinner = () => {
        spinner.value = true
        setTimeout(() => {
          spinner.value = false
        }, 2000)
      }

      const showDots = () => {
        dots.value = true
        setTimeout(() => {
          dots.value = false
        }, 2000)
      }

      const showPulse = () => {
        pulse.value = true
        setTimeout(() => {
          pulse.value = false
        }, 2000)
      }

      const showBar = () => {
        bar.value = true
        progress.value = 0

        const interval = setInterval(() => {
          progress.value += 20
          if (progress.value >= 100) {
            clearInterval(interval)
            setTimeout(() => {
              bar.value = false
            }, 500)
          }
        }, 400)
      }

      return { spinner, dots, pulse, bar, progress, showSpinner, showDots, showPulse, showBar }
    },
    template: `
      <div class="space-x-4">
        <Button @click="showSpinner">Spinner</Button>
        <Button @click="showDots">Dots</Button>
        <Button @click="showPulse">Pulse</Button>
        <Button @click="showBar">Bar</Button>

        <Loading v-model="spinner" spinner="spinner" text="Spinner" />
        <Loading v-model="dots" spinner="dots" text="Dots" />
        <Loading v-model="pulse" spinner="pulse" text="Pulse" />
        <Loading v-model="bar" spinner="bar" :progress="progress" :text="\`\${progress}%\`" />
      </div>
    `,
  }),
}

export const CustomContent: Story = {
  render: () => ({
    components: { Loading, Button },
    setup() {
      const isLoading = ref(false)

      const showLoading = () => {
        isLoading.value = true
        setTimeout(() => {
          isLoading.value = false
        }, 3000)
      }

      return { isLoading, showLoading }
    },
    template: `
      <div>
        <Button @click="showLoading">Show Custom Content</Button>
        <Loading v-model="isLoading" spinner="pulse">
          <div class="space-y-2">
            <h3 class="text-lg font-semibold">Processing Your Request</h3>
            <p class="text-sm">This may take a few moments...</p>
          </div>
        </Loading>
      </div>
    `,
  }),
}
