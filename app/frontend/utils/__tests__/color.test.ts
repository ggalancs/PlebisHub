/**
 * Unit tests for color utilities
 */

import { describe, it, expect } from 'vitest'
import {
  isValidHexColor,
  getRelativeLuminance,
  getContrastRatio,
  validateContrast,
  lightenColor,
  darkenColor,
  generateColorPalette,
  hexToRgb,
  rgbToHex,
  getAccessibleTextColor,
} from '../color'

describe('color utilities', () => {
  describe('isValidHexColor', () => {
    it('should validate correct hex colors', () => {
      expect(isValidHexColor('#612d62')).toBe(true)
      expect(isValidHexColor('#fff')).toBe(true)
      expect(isValidHexColor('#FFF')).toBe(true)
      expect(isValidHexColor('#000000')).toBe(true)
    })

    it('should reject invalid hex colors', () => {
      expect(isValidHexColor('612d62')).toBe(false) // Missing #
      expect(isValidHexColor('#gg0000')).toBe(false) // Invalid characters
      expect(isValidHexColor('#ff')).toBe(false) // Too short
      expect(isValidHexColor('#fffffff')).toBe(false) // Too long
      expect(isValidHexColor('')).toBe(false) // Empty
    })
  })

  describe('getRelativeLuminance', () => {
    it('should calculate luminance correctly', () => {
      expect(getRelativeLuminance('#000000')).toBe(0) // Black
      expect(getRelativeLuminance('#ffffff')).toBe(1) // White
      expect(getRelativeLuminance('#ff0000')).toBeCloseTo(0.2126, 4) // Red
    })

    it('should throw on invalid hex', () => {
      expect(() => getRelativeLuminance('invalid')).toThrow()
    })
  })

  describe('getContrastRatio', () => {
    it('should calculate contrast ratio correctly', () => {
      const ratio = getContrastRatio('#000000', '#ffffff')
      expect(ratio).toBe(21) // Maximum contrast

      const minRatio = getContrastRatio('#ffffff', '#ffffff')
      expect(minRatio).toBe(1) // Minimum contrast (same color)
    })

    it('should be symmetric', () => {
      const ratio1 = getContrastRatio('#612d62', '#ffffff')
      const ratio2 = getContrastRatio('#ffffff', '#612d62')
      expect(ratio1).toBe(ratio2)
    })
  })

  describe('validateContrast', () => {
    it('should validate WCAG AA contrast', () => {
      const result = validateContrast('#612d62', '#ffffff', 'AA', 'normal')
      expect(result.passes).toBe(true)
      expect(result.ratio).toBeGreaterThanOrEqual(4.5)
    })

    it('should fail for insufficient contrast', () => {
      const result = validateContrast('#cccccc', '#ffffff', 'AA', 'normal')
      expect(result.passes).toBe(false)
      expect(result.ratio).toBeLessThan(4.5)
    })

    it('should have different requirements for large text', () => {
      const normalResult = validateContrast('#999999', '#ffffff', 'AA', 'normal')
      const largeResult = validateContrast('#999999', '#ffffff', 'AA', 'large')

      expect(normalResult.passes).toBe(false)
      expect(largeResult.passes).toBe(true)
    })
  })

  describe('lightenColor', () => {
    it('should lighten a color', () => {
      const original = '#612d62'
      const lightened = lightenColor(original, 20)

      expect(isValidHexColor(lightened)).toBe(true)
      expect(lightened).not.toBe(original)

      // Lightened color should have higher luminance
      const originalLuminance = getRelativeLuminance(original)
      const lightenedLuminance = getRelativeLuminance(lightened)
      expect(lightenedLuminance).toBeGreaterThan(originalLuminance)
    })

    it('should clamp at white', () => {
      const result = lightenColor('#ffffff', 50)
      expect(result).toBe('#ffffff')
    })
  })

  describe('darkenColor', () => {
    it('should darken a color', () => {
      const original = '#612d62'
      const darkened = darkenColor(original, 20)

      expect(isValidHexColor(darkened)).toBe(true)
      expect(darkened).not.toBe(original)

      // Darkened color should have lower luminance
      const originalLuminance = getRelativeLuminance(original)
      const darkenedLuminance = getRelativeLuminance(darkened)
      expect(darkenedLuminance).toBeLessThan(originalLuminance)
    })

    it('should clamp at black', () => {
      const result = darkenColor('#000000', 50)
      expect(result).toBe('#000000')
    })
  })

  describe('generateColorPalette', () => {
    it('should generate complete palette', () => {
      const palette = generateColorPalette('#612d62')

      expect(palette).toHaveProperty('primary')
      expect(palette).toHaveProperty('primaryLight')
      expect(palette).toHaveProperty('primaryDark')

      expect(isValidHexColor(palette.primary)).toBe(true)
      expect(isValidHexColor(palette.primaryLight)).toBe(true)
      expect(isValidHexColor(palette.primaryDark)).toBe(true)

      // Light should be lighter, dark should be darker
      const baseLuminance = getRelativeLuminance(palette.primary)
      const lightLuminance = getRelativeLuminance(palette.primaryLight)
      const darkLuminance = getRelativeLuminance(palette.primaryDark)

      expect(lightLuminance).toBeGreaterThan(baseLuminance)
      expect(darkLuminance).toBeLessThan(baseLuminance)
    })
  })

  describe('hexToRgb', () => {
    it('should convert hex to RGB', () => {
      expect(hexToRgb('#ff0000')).toEqual({ r: 255, g: 0, b: 0 })
      expect(hexToRgb('#00ff00')).toEqual({ r: 0, g: 255, b: 0 })
      expect(hexToRgb('#0000ff')).toEqual({ r: 0, g: 0, b: 255 })
      expect(hexToRgb('#612d62')).toEqual({ r: 97, g: 45, b: 98 })
    })

    it('should return null for invalid hex', () => {
      expect(hexToRgb('invalid')).toBeNull()
    })
  })

  describe('rgbToHex', () => {
    it('should convert RGB to hex', () => {
      expect(rgbToHex(255, 0, 0)).toBe('#ff0000')
      expect(rgbToHex(0, 255, 0)).toBe('#00ff00')
      expect(rgbToHex(0, 0, 255)).toBe('#0000ff')
      expect(rgbToHex(97, 45, 98)).toBe('#612d62')
    })

    it('should clamp values', () => {
      expect(rgbToHex(300, 0, 0)).toBe('#ff0000') // Clamped to 255
      expect(rgbToHex(-10, 0, 0)).toBe('#000000') // Clamped to 0
    })
  })

  describe('getAccessibleTextColor', () => {
    it('should return white for dark backgrounds', () => {
      expect(getAccessibleTextColor('#000000')).toBe('#ffffff')
      expect(getAccessibleTextColor('#612d62')).toBe('#ffffff')
    })

    it('should return black for light backgrounds', () => {
      expect(getAccessibleTextColor('#ffffff')).toBe('#000000')
      expect(getAccessibleTextColor('#f0f0f0')).toBe('#000000')
    })
  })
})
