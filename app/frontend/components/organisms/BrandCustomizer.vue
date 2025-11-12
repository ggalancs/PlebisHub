<script setup lang="ts">
import { ref, computed } from 'vue'
import { useBrand } from '@/composables/useBrand'
import Logo from '@/components/atoms/Logo.vue'
import Button from '@/components/atoms/Button.vue'
import Card from '@/components/molecules/Card.vue'
import FormField from '@/components/molecules/FormField.vue'
import Alert from '@/components/molecules/Alert.vue'
import BrandColors from '@/components/molecules/BrandColors.vue'

const {
  currentTheme,
  brandColors,
  isCustomTheme,
  predefinedThemes,
  setTheme,
  setCustomColors,
  resetToDefault,
  exportBrandConfig,
  importBrandConfig,
  validateColorContrast,
} = useBrand()

// Local state
const activeTab = ref<'presets' | 'custom' | 'preview'>('presets')
const customPrimary = ref(brandColors.value.primary)
const customSecondary = ref(brandColors.value.secondary)
const exportedJson = ref('')
const importJson = ref('')
const showExportModal = ref(false)
const showImportModal = ref(false)
const contrastWarning = ref('')

// Computed
const hasChanges = computed(() => {
  return customPrimary.value !== brandColors.value.primary ||
         customSecondary.value !== brandColors.value.secondary
})

// Methods
const handleThemeChange = (themeId: string) => {
  setTheme(themeId)
  customPrimary.value = brandColors.value.primary
  customSecondary.value = brandColors.value.secondary
  contrastWarning.value = ''
}

const handleApplyCustomColors = () => {
  // Validate contrast
  const primaryContrast = validateColorContrast(customPrimary.value, '#ffffff')
  const secondaryContrast = validateColorContrast(customSecondary.value, '#ffffff')

  if (!primaryContrast || !secondaryContrast) {
    contrastWarning.value = 'Warning: Some colors may not meet WCAG AA contrast requirements (4.5:1)'
  } else {
    contrastWarning.value = ''
  }

  setCustomColors({
    primary: customPrimary.value,
    secondary: customSecondary.value,
  })
}

const handleReset = () => {
  resetToDefault()
  customPrimary.value = brandColors.value.primary
  customSecondary.value = brandColors.value.secondary
  contrastWarning.value = ''
}

const handleExport = () => {
  exportedJson.value = exportBrandConfig()
  showExportModal.value = true
}

const handleCopyExport = () => {
  navigator.clipboard.writeText(exportedJson.value)
  // TODO: Show toast notification
}

const handleImport = () => {
  const success = importBrandConfig(importJson.value)
  if (success) {
    showImportModal.value = false
    importJson.value = ''
    customPrimary.value = brandColors.value.primary
    customSecondary.value = brandColors.value.secondary
    // TODO: Show success toast
  } else {
    // TODO: Show error toast
  }
}
</script>

<template>
  <div class="brand-customizer">
    <div class="brand-customizer__header">
      <h1 class="brand-customizer__title">
        🎨 Brand Customization
      </h1>
      <p class="brand-customizer__subtitle">
        Customize PlebisHub's visual identity with your own colors and branding
      </p>
    </div>

    <!-- Tabs -->
    <div class="brand-customizer__tabs">
      <button
        class="brand-customizer__tab"
        :class="{ 'brand-customizer__tab--active': activeTab === 'presets' }"
        @click="activeTab = 'presets'"
      >
        Preset Themes
      </button>
      <button
        class="brand-customizer__tab"
        :class="{ 'brand-customizer__tab--active': activeTab === 'custom' }"
        @click="activeTab = 'custom'"
      >
        Custom Colors
      </button>
      <button
        class="brand-customizer__tab"
        :class="{ 'brand-customizer__tab--active': activeTab === 'preview' }"
        @click="activeTab = 'preview'"
      >
        Preview
      </button>
    </div>

    <div class="brand-customizer__content">
      <!-- Preset Themes Tab -->
      <div v-if="activeTab === 'presets'" class="brand-customizer__panel">
        <h2 class="brand-customizer__section-title">Choose a Preset Theme</h2>

        <div class="brand-customizer__themes">
          <Card
            v-for="theme in predefinedThemes"
            :key="theme.id"
            class="brand-customizer__theme-card"
            :class="{ 'brand-customizer__theme-card--active': currentTheme.id === theme.id }"
            @click="handleThemeChange(theme.id)"
          >
            <div class="brand-customizer__theme-preview">
              <div
                class="brand-customizer__theme-color"
                :style="{ backgroundColor: theme.colors.primary }"
              />
              <div
                class="brand-customizer__theme-color"
                :style="{ backgroundColor: theme.colors.secondary }"
              />
            </div>
            <h3 class="brand-customizer__theme-name">{{ theme.name }}</h3>
            <p class="brand-customizer__theme-desc">{{ theme.description }}</p>
          </Card>
        </div>
      </div>

      <!-- Custom Colors Tab -->
      <div v-if="activeTab === 'custom'" class="brand-customizer__panel">
        <h2 class="brand-customizer__section-title">Custom Brand Colors</h2>

        <Alert v-if="contrastWarning" variant="warning" class="mb-4">
          {{ contrastWarning }}
        </Alert>

        <div class="brand-customizer__color-pickers">
          <div class="brand-customizer__color-picker">
            <FormField
              v-model="customPrimary"
              label="Primary Color"
              type="color"
              hint="Main brand color used for headers, buttons, and primary actions"
            />
            <div
              class="brand-customizer__color-preview"
              :style="{ backgroundColor: customPrimary }"
            >
              <span>{{ customPrimary }}</span>
            </div>
          </div>

          <div class="brand-customizer__color-picker">
            <FormField
              v-model="customSecondary"
              label="Secondary Color"
              type="color"
              hint="Accent color for secondary actions and highlights"
            />
            <div
              class="brand-customizer__color-preview"
              :style="{ backgroundColor: customSecondary }"
            >
              <span>{{ customSecondary }}</span>
            </div>
          </div>
        </div>

        <div class="brand-customizer__actions">
          <Button
            variant="primary"
            :disabled="!hasChanges"
            @click="handleApplyCustomColors"
          >
            Apply Colors
          </Button>
          <Button
            variant="ghost"
            @click="handleReset"
          >
            Reset to Default
          </Button>
        </div>

        <!-- Current Color Palette -->
        <div class="brand-customizer__current-palette">
          <h3 class="brand-customizer__section-title">Current Palette</h3>
          <BrandColors variant="compact" :interactive="true" />
        </div>
      </div>

      <!-- Preview Tab -->
      <div v-if="activeTab === 'preview'" class="brand-customizer__panel">
        <h2 class="brand-customizer__section-title">Brand Preview</h2>

        <div class="brand-customizer__preview">
          <!-- Logo Variants -->
          <Card class="brand-customizer__preview-section">
            <h3 class="brand-customizer__preview-title">Logo Variants</h3>
            <div class="brand-customizer__logo-grid">
              <div class="brand-customizer__logo-item">
                <p class="brand-customizer__logo-label">Horizontal</p>
                <Logo variant="horizontal" size="md" :custom-colors="{ primary: brandColors.primary, secondary: brandColors.secondary }" />
              </div>
              <div class="brand-customizer__logo-item">
                <p class="brand-customizer__logo-label">Vertical</p>
                <Logo variant="vertical" size="sm" :custom-colors="{ primary: brandColors.primary, secondary: brandColors.secondary }" />
              </div>
              <div class="brand-customizer__logo-item">
                <p class="brand-customizer__logo-label">Mark Only</p>
                <Logo variant="mark" size="md" :custom-colors="{ primary: brandColors.primary, secondary: brandColors.secondary }" />
              </div>
            </div>
          </Card>

          <!-- UI Components -->
          <Card class="brand-customizer__preview-section">
            <h3 class="brand-customizer__preview-title">UI Components</h3>
            <div class="brand-customizer__ui-preview">
              <Button variant="primary" size="md">Primary Button</Button>
              <Button variant="secondary" size="md">Secondary Button</Button>
              <Button variant="ghost" size="md">Ghost Button</Button>
            </div>
          </Card>
        </div>
      </div>
    </div>

    <!-- Actions Footer -->
    <div class="brand-customizer__footer">
      <div class="brand-customizer__footer-actions">
        <Button variant="ghost" @click="showExportModal = true; handleExport()">
          Export Configuration
        </Button>
        <Button variant="ghost" @click="showImportModal = true">
          Import Configuration
        </Button>
      </div>

      <div v-if="isCustomTheme" class="brand-customizer__status">
        ✓ Custom theme active
      </div>
    </div>

    <!-- Export Modal -->
    <teleport to="body">
      <div v-if="showExportModal" class="brand-customizer__modal-overlay" @click="showExportModal = false">
        <Card class="brand-customizer__modal" @click.stop>
          <h3 class="brand-customizer__modal-title">Export Brand Configuration</h3>
          <p class="brand-customizer__modal-desc">
            Copy this JSON configuration to save your brand settings
          </p>
          <textarea
            v-model="exportedJson"
            class="brand-customizer__modal-textarea"
            readonly
            rows="15"
          />
          <div class="brand-customizer__modal-actions">
            <Button variant="primary" @click="handleCopyExport">
              Copy to Clipboard
            </Button>
            <Button variant="ghost" @click="showExportModal = false">
              Close
            </Button>
          </div>
        </Card>
      </div>
    </teleport>

    <!-- Import Modal -->
    <teleport to="body">
      <div v-if="showImportModal" class="brand-customizer__modal-overlay" @click="showImportModal = false">
        <Card class="brand-customizer__modal" @click.stop>
          <h3 class="brand-customizer__modal-title">Import Brand Configuration</h3>
          <p class="brand-customizer__modal-desc">
            Paste your brand configuration JSON below
          </p>
          <textarea
            v-model="importJson"
            class="brand-customizer__modal-textarea"
            placeholder="Paste JSON here..."
            rows="15"
          />
          <div class="brand-customizer__modal-actions">
            <Button variant="primary" :disabled="!importJson" @click="handleImport">
              Import
            </Button>
            <Button variant="ghost" @click="showImportModal = false; importJson = ''">
              Cancel
            </Button>
          </div>
        </Card>
      </div>
    </teleport>
  </div>
</template>

<style scoped>
.brand-customizer {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.brand-customizer__header {
  margin-bottom: 2rem;
}

.brand-customizer__title {
  font-family: 'Montserrat', sans-serif;
  font-size: 2.5rem;
  font-weight: 700;
  color: #1a1a1a;
  margin: 0 0 0.5rem 0;
}

.brand-customizer__subtitle {
  font-size: 1.125rem;
  color: #666;
  margin: 0;
}

/* Tabs */
.brand-customizer__tabs {
  display: flex;
  gap: 1rem;
  border-bottom: 2px solid #e5e5e5;
  margin-bottom: 2rem;
}

.brand-customizer__tab {
  padding: 1rem 1.5rem;
  font-family: 'Montserrat', sans-serif;
  font-size: 1rem;
  font-weight: 600;
  color: #666;
  background: none;
  border: none;
  border-bottom: 3px solid transparent;
  cursor: pointer;
  transition: all 0.2s ease;
  margin-bottom: -2px;
}

.brand-customizer__tab:hover {
  color: #1a1a1a;
}

.brand-customizer__tab--active {
  color: var(--brand-primary, #612d62);
  border-bottom-color: var(--brand-primary, #612d62);
}

/* Content */
.brand-customizer__content {
  min-height: 500px;
}

.brand-customizer__panel {
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from {
    opacity: 0;
    transform: translateY(10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.brand-customizer__section-title {
  font-family: 'Montserrat', sans-serif;
  font-size: 1.5rem;
  font-weight: 600;
  color: #1a1a1a;
  margin: 0 0 1.5rem 0;
}

/* Theme Cards */
.brand-customizer__themes {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 1.5rem;
}

.brand-customizer__theme-card {
  cursor: pointer;
  transition: all 0.2s ease;
  border: 2px solid transparent;
}

.brand-customizer__theme-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 16px rgba(0, 0, 0, 0.15);
}

.brand-customizer__theme-card--active {
  border-color: var(--brand-primary, #612d62);
  box-shadow: 0 4px 12px rgba(97, 45, 98, 0.2);
}

.brand-customizer__theme-preview {
  display: flex;
  gap: 0.5rem;
  margin-bottom: 1rem;
}

.brand-customizer__theme-color {
  flex: 1;
  height: 60px;
  border-radius: 6px;
}

.brand-customizer__theme-name {
  font-family: 'Montserrat', sans-serif;
  font-size: 1.125rem;
  font-weight: 600;
  margin: 0 0 0.25rem 0;
}

.brand-customizer__theme-desc {
  font-size: 0.875rem;
  color: #666;
  margin: 0;
}

/* Color Pickers */
.brand-customizer__color-pickers {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 2rem;
  margin-bottom: 2rem;
}

.brand-customizer__color-picker {
  display: flex;
  flex-direction: column;
  gap: 1rem;
}

.brand-customizer__color-preview {
  height: 100px;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-family: 'Monaco', 'Courier New', monospace;
  font-size: 1rem;
  font-weight: 600;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

.brand-customizer__actions {
  display: flex;
  gap: 1rem;
  margin-bottom: 3rem;
}

.brand-customizer__current-palette {
  margin-top: 3rem;
}

/* Preview */
.brand-customizer__preview {
  display: flex;
  flex-direction: column;
  gap: 2rem;
}

.brand-customizer__preview-section {
  padding: 2rem;
}

.brand-customizer__preview-title {
  font-family: 'Montserrat', sans-serif;
  font-size: 1.25rem;
  font-weight: 600;
  margin: 0 0 1.5rem 0;
}

.brand-customizer__logo-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 2rem;
}

.brand-customizer__logo-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 1rem;
}

.brand-customizer__logo-label {
  font-size: 0.875rem;
  color: #666;
  margin: 0;
}

.brand-customizer__ui-preview {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
}

/* Footer */
.brand-customizer__footer {
  margin-top: 3rem;
  padding-top: 2rem;
  border-top: 2px solid #e5e5e5;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.brand-customizer__footer-actions {
  display: flex;
  gap: 1rem;
}

.brand-customizer__status {
  color: var(--brand-secondary, #269283);
  font-weight: 600;
}

/* Modal */
.brand-customizer__modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.brand-customizer__modal {
  width: 90%;
  max-width: 600px;
  max-height: 90vh;
  overflow-y: auto;
  padding: 2rem;
}

.brand-customizer__modal-title {
  font-family: 'Montserrat', sans-serif;
  font-size: 1.5rem;
  font-weight: 600;
  margin: 0 0 0.5rem 0;
}

.brand-customizer__modal-desc {
  color: #666;
  margin: 0 0 1.5rem 0;
}

.brand-customizer__modal-textarea {
  width: 100%;
  padding: 1rem;
  font-family: 'Monaco', 'Courier New', monospace;
  font-size: 0.875rem;
  border: 2px solid #e5e5e5;
  border-radius: 8px;
  resize: vertical;
  margin-bottom: 1.5rem;
}

.brand-customizer__modal-actions {
  display: flex;
  gap: 1rem;
  justify-content: flex-end;
}

/* Responsive */
@media (max-width: 768px) {
  .brand-customizer {
    padding: 1rem;
  }

  .brand-customizer__title {
    font-size: 2rem;
  }

  .brand-customizer__tabs {
    overflow-x: auto;
  }

  .brand-customizer__themes {
    grid-template-columns: 1fr;
  }

  .brand-customizer__color-pickers {
    grid-template-columns: 1fr;
  }

  .brand-customizer__footer {
    flex-direction: column;
    gap: 1rem;
    align-items: flex-start;
  }
}
</style>
