/**
 * Shared TypeScript types for brand system
 * Centralized type definitions for better type safety
 */

/**
 * Hex color string type
 * Format: #RRGGBB or #RGB
 */
export type HexColor = `#${string}`

/**
 * Brand color palette
 */
export interface BrandColors {
  readonly primary: HexColor
  readonly primaryLight: HexColor
  readonly primaryDark: HexColor
  readonly secondary: HexColor
  readonly secondaryLight: HexColor
  readonly secondaryDark: HexColor
}

/**
 * Partial brand colors for customization
 */
export type PartialBrandColors = Partial<BrandColors>

/**
 * Brand theme configuration
 */
export interface BrandTheme {
  readonly id: string
  readonly name: string
  readonly description?: string
  readonly colors: BrandColors
}

/**
 * Logo variant types
 */
export type LogoVariant = 'horizontal' | 'vertical' | 'mark' | 'type'

/**
 * Logo theme types
 */
export type LogoTheme = 'color' | 'monochrome' | 'inverted'

/**
 * Logo size types
 */
export type LogoSize = 'sm' | 'md' | 'lg' | 'xl'

/**
 * Logo dimensions
 */
export interface LogoDimensions {
  readonly width: number
  readonly height: number
}

/**
 * Logo props
 */
export interface LogoProps {
  variant?: LogoVariant
  theme?: LogoTheme
  size?: LogoSize
  customColors?: PartialBrandColors
}

/**
 * Brand pattern variant types
 */
export type PatternVariant = 'dots' | 'circles' | 'network' | 'waves'

/**
 * Brand pattern props
 */
export interface PatternProps {
  variant?: PatternVariant
  opacity?: number
  primaryColor?: HexColor
  secondaryColor?: HexColor
  scale?: number
}

/**
 * WCAG contrast level
 */
export type WCAGLevel = 'AA' | 'AAA'

/**
 * Text size for WCAG
 */
export type TextSize = 'normal' | 'large'

/**
 * Contrast validation result
 */
export interface ContrastValidation {
  readonly passes: boolean
  readonly ratio: number
  readonly required: number
}

/**
 * Brand storage data
 */
export interface BrandStorageData {
  themeId: string
  customColors?: PartialBrandColors
  timestamp?: number
}

/**
 * Brand export data
 */
export interface BrandExportData {
  theme: BrandTheme
  customColors: PartialBrandColors | null
  version: string
  exportedAt: string
}

/**
 * Color palette display variant
 */
export type ColorPaletteVariant = 'palette' | 'swatches' | 'compact'

/**
 * Color swatch data
 */
export interface ColorSwatch {
  readonly name: string
  readonly value: HexColor
  readonly textColor?: HexColor
  readonly description?: string
}

/**
 * RGB color object
 */
export interface RGBColor {
  readonly r: number
  readonly g: number
  readonly b: number
}

/**
 * Brand customizer tab
 */
export type CustomizerTab = 'presets' | 'custom' | 'preview'

/**
 * Error types for brand operations
 */
export enum BrandErrorType {
  INVALID_COLOR = 'INVALID_COLOR',
  STORAGE_ERROR = 'STORAGE_ERROR',
  IMPORT_ERROR = 'IMPORT_ERROR',
  VALIDATION_ERROR = 'VALIDATION_ERROR',
}

/**
 * Brand error
 */
export class BrandError extends Error {
  constructor(
    public type: BrandErrorType,
    message: string,
    public originalError?: unknown
  ) {
    super(message)
    this.name = 'BrandError'
  }
}
