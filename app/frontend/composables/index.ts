/**
 * Composables Index
 *
 * Central export point for all composables in the PlebisHub Design System
 */

// Debounce composable
export { useDebounce, useDebouncedFn, useDebouncedFnWithCancel } from './useDebounce'

// Pagination composable
export { usePagination, type PaginationOptions, type PaginationReturn } from './usePagination'

// Form composable
export {
  useForm,
  validators,
  type ValidationRule,
  type FieldRules,
  type FormRules,
  type FieldState,
  type FormState,
  type UseFormReturn,
} from './useForm'

// Theme composable
export {
  useTheme,
  type ThemeColors,
  type Theme,
  type UseThemeReturn,
} from './useTheme'

// Brand composable
export { useBrand } from './useBrand'

// Date formatting composable
export { useDateFormat } from './useDateFormat'

// Rate limit handler composable
export { useRateLimitHandler } from './useRateLimitHandler'

// Virtual scroll composable
export { useVirtualScroll } from './useVirtualScroll'

// Flash messages composable
export {
  useFlash,
  addFlash,
  removeFlash,
  clearFlashes,
  flashMessages,
  type FlashType,
  type FlashMessage,
} from './useFlash'

// Select composable (replaces Select2)
export { useSelect, type SelectOption, type UseSelectOptions } from './useSelect'

// File upload composable (replaces jQuery File Upload)
export { useFileUpload, type UploadedFile, type UseFileUploadOptions } from './useFileUpload'

// API composable (replaces jQuery AJAX)
export {
  useApi,
  api,
  createApiClient,
  type ApiOptions,
  type RequestOptions,
  type ApiResponse,
} from './useApi'
