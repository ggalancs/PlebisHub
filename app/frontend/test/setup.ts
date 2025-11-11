/**
 * Vitest setup file
 * Runs before all tests
 */

import { expect } from 'vitest'
import * as matchers from '@testing-library/jest-dom/matchers'

// Extend Vitest's expect with jest-dom matchers
expect.extend(matchers)

// Note: cleanup() is called automatically when using globals: true in vitest config
