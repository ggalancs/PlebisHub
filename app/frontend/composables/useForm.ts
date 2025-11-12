import { ref, computed, watch, reactive, type Ref, type ComputedRef, type UnwrapRef } from 'vue'

export type ValidationRule<T = any> = {
  validator: (value: T) => boolean | Promise<boolean>
  message: string
}

export type FieldRules<T = any> = ValidationRule<T>[]

export type FormRules<T extends Record<string, any>> = {
  [K in keyof T]?: FieldRules<T[K]>
}

export interface FieldState<T = any> {
  value: Ref<T>
  error: Ref<string | null>
  touched: Ref<boolean>
  dirty: Ref<boolean>
  validating: Ref<boolean>
}

export interface FormState<T extends Record<string, any>> {
  values: UnwrapRef<T>
  errors: Record<keyof T, string | null>
  touched: Record<keyof T, boolean>
  dirty: Record<keyof T, boolean>
  validating: Record<keyof T, boolean>
}

export interface UseFormReturn<T extends Record<string, any>> {
  /** Form values (reactive object) */
  values: UnwrapRef<T>

  /** Form errors (reactive object) */
  errors: ComputedRef<Record<keyof T, string | null>>

  /** Touched state for each field */
  touched: Readonly<Record<keyof T, boolean>>

  /** Dirty state for each field */
  dirty: Readonly<Record<keyof T, boolean>>

  /** Validating state for each field */
  validating: Readonly<Record<keyof T, boolean>>

  /** Whether form is currently validating */
  isValidating: ComputedRef<boolean>

  /** Whether form is valid (no errors) */
  isValid: ComputedRef<boolean>

  /** Whether form has been touched */
  isTouched: ComputedRef<boolean>

  /** Whether form is dirty (values changed) */
  isDirty: ComputedRef<boolean>

  /** Whether form is submitting */
  isSubmitting: Ref<boolean>

  /** Set value for a specific field */
  setFieldValue: <K extends keyof T>(field: K, value: T[K]) => void

  /** Set error for a specific field */
  setFieldError: <K extends keyof T>(field: K, error: string | null) => void

  /** Mark field as touched */
  setFieldTouched: <K extends keyof T>(field: K, touched?: boolean) => void

  /** Validate a specific field */
  validateField: <K extends keyof T>(field: K) => Promise<boolean>

  /** Validate all fields */
  validateForm: () => Promise<boolean>

  /** Reset form to initial values */
  resetForm: () => void

  /** Reset field to initial value */
  resetField: <K extends keyof T>(field: K) => void

  /** Clear all errors */
  clearErrors: () => void

  /** Handle form submission */
  handleSubmit: (onSubmit: (values: T) => void | Promise<void>) => (e?: Event) => Promise<void>
}

/**
 * useForm Composable
 *
 * Complete form management with validation, error handling, and submission
 *
 * @param initialValues - Initial form values
 * @param rules - Validation rules for each field
 * @returns Form state and methods
 *
 * @example
 * ```ts
 * const form = useForm(
 *   {
 *     email: '',
 *     password: '',
 *     age: 0
 *   },
 *   {
 *     email: [
 *       { validator: (v) => !!v, message: 'Email is required' },
 *       { validator: (v) => /\S+@\S+\.\S+/.test(v), message: 'Email is invalid' }
 *     ],
 *     password: [
 *       { validator: (v) => v.length >= 8, message: 'Password must be at least 8 characters' }
 *     ],
 *     age: [
 *       { validator: (v) => v >= 18, message: 'Must be 18 or older' }
 *     ]
 *   }
 * )
 *
 * const onSubmit = form.handleSubmit(async (values) => {
 *   await api.post('/register', values)
 * })
 * ```
 */
export function useForm<T extends Record<string, any>>(
  initialValues: T,
  rules: FormRules<T> = {}
): UseFormReturn<T> {
  // Create reactive form state
  const values = reactive({ ...initialValues }) as UnwrapRef<T>
  const initialValuesRef = ref({ ...initialValues })

  // Create refs for each field state
  const fieldErrors = reactive<Record<keyof T, string | null>>(
    {} as Record<keyof T, string | null>
  )
  const fieldTouched = reactive<Record<keyof T, boolean>>({} as Record<keyof T, boolean>)
  const fieldDirty = reactive<Record<keyof T, boolean>>({} as Record<keyof T, boolean>)
  const fieldValidating = reactive<Record<keyof T, boolean>>({} as Record<keyof T, boolean>)

  const isSubmitting = ref(false)

  // Initialize field states
  for (const key in initialValues) {
    fieldErrors[key] = null
    fieldTouched[key] = false
    fieldDirty[key] = false
    fieldValidating[key] = false
  }

  // Computed: errors object
  const errors = computed(() => fieldErrors)

  // Computed: is form validating
  const isValidating = computed(() => {
    return Object.values(fieldValidating).some((v) => v)
  })

  // Computed: is form valid
  const isValid = computed(() => {
    return Object.values(fieldErrors).every((error) => error === null)
  })

  // Computed: is form touched
  const isTouched = computed(() => {
    return Object.values(fieldTouched).some((touched) => touched)
  })

  // Computed: is form dirty
  const isDirty = computed(() => {
    return Object.values(fieldDirty).some((dirty) => dirty)
  })

  // Set field value
  const setFieldValue = <K extends keyof T>(field: K, value: T[K]) => {
    ;(values as any)[field] = value
    fieldDirty[field] = value !== initialValuesRef.value[field]
  }

  // Set field error
  const setFieldError = <K extends keyof T>(field: K, error: string | null) => {
    fieldErrors[field] = error
  }

  // Mark field as touched
  const setFieldTouched = <K extends keyof T>(field: K, touched = true) => {
    fieldTouched[field] = touched
  }

  // Validate single field
  const validateField = async <K extends keyof T>(field: K): Promise<boolean> => {
    const fieldRules = rules[field]
    if (!fieldRules || fieldRules.length === 0) {
      fieldErrors[field] = null
      return true
    }

    fieldValidating[field] = true
    const value = values[field]

    try {
      for (const rule of fieldRules) {
        const isValid = await rule.validator(value)
        if (!isValid) {
          fieldErrors[field] = rule.message
          fieldValidating[field] = false
          return false
        }
      }

      fieldErrors[field] = null
      fieldValidating[field] = false
      return true
    } catch (error) {
      fieldErrors[field] = 'Validation error'
      fieldValidating[field] = false
      return false
    }
  }

  // Validate entire form
  const validateForm = async (): Promise<boolean> => {
    const validationPromises = Object.keys(values).map((field) =>
      validateField(field as keyof T)
    )

    const results = await Promise.all(validationPromises)
    return results.every((result) => result)
  }

  // Reset form
  const resetForm = () => {
    for (const key in initialValues) {
      ;(values as any)[key] = initialValuesRef.value[key]
      fieldErrors[key] = null
      fieldTouched[key] = false
      fieldDirty[key] = false
      fieldValidating[key] = false
    }
    isSubmitting.value = false
  }

  // Reset single field
  const resetField = <K extends keyof T>(field: K) => {
    ;(values as any)[field] = initialValuesRef.value[field]
    fieldErrors[field] = null
    fieldTouched[field] = false
    fieldDirty[field] = false
    fieldValidating[field] = false
  }

  // Clear all errors
  const clearErrors = () => {
    for (const key in fieldErrors) {
      fieldErrors[key] = null
    }
  }

  // Handle form submission
  const handleSubmit =
    (onSubmit: (values: T) => void | Promise<void>) => async (e?: Event) => {
      if (e) {
        e.preventDefault()
      }

      // Mark all fields as touched
      for (const key in values) {
        fieldTouched[key as keyof T] = true
      }

      // Validate form
      const isFormValid = await validateForm()

      if (!isFormValid) {
        return
      }

      // Submit
      isSubmitting.value = true
      try {
        await onSubmit(values as T)
      } catch (error) {
        console.error('Form submission error:', error)
      } finally {
        isSubmitting.value = false
      }
    }

  // Watch for value changes and validate on blur (when touched)
  for (const key in initialValues) {
    watch(
      () => values[key],
      async (newValue) => {
        fieldDirty[key] = newValue !== initialValuesRef.value[key]

        // Validate if field has been touched
        if (fieldTouched[key]) {
          await validateField(key)
        }
      }
    )
  }

  return {
    values,
    errors,
    touched: fieldTouched,
    dirty: fieldDirty,
    validating: fieldValidating,
    isValidating,
    isValid,
    isTouched,
    isDirty,
    isSubmitting,
    setFieldValue,
    setFieldError,
    setFieldTouched,
    validateField,
    validateForm,
    resetForm,
    resetField,
    clearErrors,
    handleSubmit,
  }
}

// Common validators
export const validators = {
  required: (message = 'This field is required'): ValidationRule => ({
    validator: (value) => {
      if (typeof value === 'string') return value.trim().length > 0
      if (Array.isArray(value)) return value.length > 0
      return value !== null && value !== undefined
    },
    message,
  }),

  email: (message = 'Invalid email address'): ValidationRule => ({
    validator: (value: string) => {
      if (!value) return true // Use required validator separately
      return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)
    },
    message,
  }),

  minLength: (min: number, message?: string): ValidationRule => ({
    validator: (value: string) => {
      if (!value) return true
      return value.length >= min
    },
    message: message || `Must be at least ${min} characters`,
  }),

  maxLength: (max: number, message?: string): ValidationRule => ({
    validator: (value: string) => {
      if (!value) return true
      return value.length <= max
    },
    message: message || `Must be at most ${max} characters`,
  }),

  min: (min: number, message?: string): ValidationRule => ({
    validator: (value: number) => value >= min,
    message: message || `Must be at least ${min}`,
  }),

  max: (max: number, message?: string): ValidationRule => ({
    validator: (value: number) => value <= max,
    message: message || `Must be at most ${max}`,
  }),

  pattern: (regex: RegExp, message = 'Invalid format'): ValidationRule => ({
    validator: (value: string) => {
      if (!value) return true
      return regex.test(value)
    },
    message,
  }),

  url: (message = 'Invalid URL'): ValidationRule => ({
    validator: (value: string) => {
      if (!value) return true
      try {
        new URL(value)
        return true
      } catch {
        return false
      }
    },
    message,
  }),

  match: (fieldName: string, message?: string): ValidationRule => ({
    validator: (value: string, formValues?: any) => {
      if (!formValues) return true
      return value === formValues[fieldName]
    },
    message: message || `Must match ${fieldName}`,
  }),
}
