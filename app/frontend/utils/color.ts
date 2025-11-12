/**
 * Color utility functions for brand customization
 * Extracted from inline code for reusability and testing
 */

/**
 * Validates if a string is a valid hex color
 * @param color - The color string to validate
 * @returns True if valid hex color, false otherwise
 */
export function isValidHexColor(color: string): boolean {
  return /^#([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$/.test(color)
}

/**
 * Calculate relative luminance of a color (WCAG formula)
 * @param hex - Hex color string (e.g., "#612d62")
 * @returns Relative luminance value (0-1)
 */
export function getRelativeLuminance(hex: string): number {
  if (!isValidHexColor(hex)) {
    throw new Error(`Invalid hex color: ${hex}`)
  }

  // Parse hex color
  const rgb = parseInt(hex.slice(1), 16)
  const r = (rgb >> 16) & 0xff
  const g = (rgb >> 8) & 0xff
  const b = (rgb >> 0) & 0xff

  // Convert to sRGB
  const rsRGB = r / 255
  const gsRGB = g / 255
  const bsRGB = b / 255

  // Apply gamma correction
  const rLinear = rsRGB <= 0.03928 ? rsRGB / 12.92 : Math.pow((rsRGB + 0.055) / 1.055, 2.4)
  const gLinear = gsRGB <= 0.03928 ? gsRGB / 12.92 : Math.pow((gsRGB + 0.055) / 1.055, 2.4)
  const bLinear = bsRGB <= 0.03928 ? bsRGB / 12.92 : Math.pow((bsRGB + 0.055) / 1.055, 2.4)

  // Calculate luminance using WCAG formula
  return 0.2126 * rLinear + 0.7152 * gLinear + 0.0722 * bLinear
}

/**
 * Calculate contrast ratio between two colors (WCAG formula)
 * @param foreground - Foreground hex color
 * @param background - Background hex color
 * @returns Contrast ratio (1-21)
 */
export function getContrastRatio(foreground: string, background: string): number {
  const l1 = getRelativeLuminance(foreground)
  const l2 = getRelativeLuminance(background)
  const lighter = Math.max(l1, l2)
  const darker = Math.min(l1, l2)

  return (lighter + 0.05) / (darker + 0.05)
}

/**
 * Validate color contrast meets WCAG standards
 * @param foreground - Foreground hex color
 * @param background - Background hex color
 * @param level - WCAG level ('AA' or 'AAA')
 * @param size - Text size ('normal' or 'large')
 * @returns Object with validation result and contrast ratio
 */
export function validateContrast(
  foreground: string,
  background: string,
  level: 'AA' | 'AAA' = 'AA',
  size: 'normal' | 'large' = 'normal'
): { passes: boolean; ratio: number; required: number } {
  const ratio = getContrastRatio(foreground, background)

  // WCAG contrast requirements
  const requirements = {
    AA: { normal: 4.5, large: 3 },
    AAA: { normal: 7, large: 4.5 },
  }

  const required = requirements[level][size]
  const passes = ratio >= required

  return { passes, ratio, required }
}

/**
 * Lighten a hex color by a percentage
 * @param hex - Hex color string
 * @param percent - Percentage to lighten (0-100)
 * @returns Lightened hex color
 */
export function lightenColor(hex: string, percent: number): string {
  if (!isValidHexColor(hex)) {
    throw new Error(`Invalid hex color: ${hex}`)
  }

  const rgb = parseInt(hex.slice(1), 16)
  let r = (rgb >> 16) & 0xff
  let g = (rgb >> 8) & 0xff
  let b = (rgb >> 0) & 0xff

  // Lighten by moving towards 255
  r = Math.round(r + (255 - r) * (percent / 100))
  g = Math.round(g + (255 - g) * (percent / 100))
  b = Math.round(b + (255 - b) * (percent / 100))

  // Clamp values
  r = Math.min(255, Math.max(0, r))
  g = Math.min(255, Math.max(0, g))
  b = Math.min(255, Math.max(0, b))

  return `#${((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1)}`
}

/**
 * Darken a hex color by a percentage
 * @param hex - Hex color string
 * @param percent - Percentage to darken (0-100)
 * @returns Darkened hex color
 */
export function darkenColor(hex: string, percent: number): string {
  if (!isValidHexColor(hex)) {
    throw new Error(`Invalid hex color: ${hex}`)
  }

  const rgb = parseInt(hex.slice(1), 16)
  let r = (rgb >> 16) & 0xff
  let g = (rgb >> 8) & 0xff
  let b = (rgb >> 0) & 0xff

  // Darken by moving towards 0
  r = Math.round(r * (1 - percent / 100))
  g = Math.round(g * (1 - percent / 100))
  b = Math.round(b * (1 - percent / 100))

  // Clamp values
  r = Math.min(255, Math.max(0, r))
  g = Math.min(255, Math.max(0, g))
  b = Math.min(255, Math.max(0, b))

  return `#${((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1)}`
}

/**
 * Generate a complete color palette from a base color
 * Creates light and dark variants automatically
 * @param baseColor - Base hex color
 * @returns Color palette with primary, light, and dark variants
 */
export function generateColorPalette(baseColor: string): {
  primary: string
  primaryLight: string
  primaryDark: string
} {
  if (!isValidHexColor(baseColor)) {
    throw new Error(`Invalid hex color: ${baseColor}`)
  }

  return {
    primary: baseColor,
    primaryLight: lightenColor(baseColor, 20),
    primaryDark: darkenColor(baseColor, 20),
  }
}

/**
 * Convert hex color to RGB object
 * @param hex - Hex color string
 * @returns RGB object with r, g, b values (0-255)
 */
export function hexToRgb(hex: string): { r: number; g: number; b: number } | null {
  if (!isValidHexColor(hex)) {
    return null
  }

  const rgb = parseInt(hex.slice(1), 16)
  return {
    r: (rgb >> 16) & 0xff,
    g: (rgb >> 8) & 0xff,
    b: (rgb >> 0) & 0xff,
  }
}

/**
 * Convert RGB to hex color
 * @param r - Red value (0-255)
 * @param g - Green value (0-255)
 * @param b - Blue value (0-255)
 * @returns Hex color string
 */
export function rgbToHex(r: number, g: number, b: number): string {
  const toHex = (n: number) => {
    const hex = Math.round(Math.min(255, Math.max(0, n))).toString(16)
    return hex.length === 1 ? '0' + hex : hex
  }

  return `#${toHex(r)}${toHex(g)}${toHex(b)}`
}

/**
 * Get accessible text color (black or white) for a given background
 * @param backgroundColor - Background hex color
 * @returns '#000000' or '#ffffff' depending on contrast
 */
export function getAccessibleTextColor(backgroundColor: string): '#000000' | '#ffffff' {
  const contrastWithWhite = getContrastRatio(backgroundColor, '#ffffff')
  const contrastWithBlack = getContrastRatio(backgroundColor, '#000000')

  return contrastWithWhite > contrastWithBlack ? '#ffffff' : '#000000'
}
