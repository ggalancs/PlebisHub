/**
 * Content Security Policy (CSP) Configuration
 *
 * This middleware sets HTTP security headers to prevent XSS, clickjacking,
 * and other code injection attacks.
 *
 * Implements OWASP security best practices.
 *
 * Note: This file is kept for reference but CSP is now managed by Rails SecureHeaders gem.
 * See config/initializers/secure_headers.rb for active CSP configuration.
 */

// Use Node.js environment variables for portability (works in Vite, Node.js, and tests)
const isDevelopment = process.env.NODE_ENV === 'development'
const isProduction = process.env.NODE_ENV === 'production'

export interface CSPConfig {
  directives: {
    defaultSrc: string[]
    scriptSrc: string[]
    styleSrc: string[]
    imgSrc: string[]
    fontSrc: string[]
    connectSrc: string[]
    mediaSrc: string[]
    objectSrc: string[]
    frameSrc: string[]
    baseUri: string[]
    formAction: string[]
    frameAncestors: string[]
    upgradeInsecureRequests: boolean
  }
  reportOnly: boolean
  reportUri?: string
}

/**
 * Default CSP configuration for production
 * Adjust based on your specific needs
 */
export const defaultCSPConfig: CSPConfig = {
  directives: {
    // Default source for everything not specified
    defaultSrc: ["'self'"],

    // Scripts - only from same origin and specific trusted CDNs
    scriptSrc: [
      "'self'",
      // Add your CDN domains if needed
      // "https://cdn.jsdelivr.net",
      // Vite dev server in development
      ...(isDevelopment ? ["'unsafe-eval'", "'unsafe-inline'"] : []),
    ],

    // Styles - self and inline styles (for Tailwind, Vue scoped styles)
    styleSrc: [
      "'self'",
      "'unsafe-inline'", // Required for Tailwind CSS and Vue scoped styles
    ],

    // Images - self, data URIs, and blob URIs (for uploaded images)
    imgSrc: [
      "'self'",
      "data:", // Data URIs for inline images
      "blob:", // Blob URLs for uploaded images
      "https:", // HTTPS images from any source
    ],

    // Fonts - self and data URIs
    fontSrc: [
      "'self'",
      "data:",
    ],

    // AJAX, WebSocket, EventSource
    connectSrc: [
      "'self'",
      // Add your API domains
      // "https://api.plebis-hub.com",
      ...(isDevelopment ? ["ws://localhost:*", "http://localhost:*"] : []),
    ],

    // Media sources (audio/video)
    mediaSrc: [
      "'self'",
      "blob:",
    ],

    // Object, embed, applet (deprecated but still blocked)
    objectSrc: ["'none'"],

    // Frame sources (iframes)
    frameSrc: [
      "'self'",
      // Add trusted iframe sources if needed
    ],

    // Base URI restriction
    baseUri: ["'self'"],

    // Form action restriction
    formAction: ["'self'"],

    // Prevent site from being framed (clickjacking protection)
    frameAncestors: ["'none'"],

    // Upgrade HTTP to HTTPS automatically
    upgradeInsecureRequests: true,
  },

  // Set to true during testing, false in production
  reportOnly: isDevelopment,

  // Optional: Report violations to this endpoint
  // reportUri: "/api/csp-violations",
}

/**
 * Generate CSP header value from config
 */
export function generateCSPHeader(config: CSPConfig): string {
  const directives: string[] = []

  // Add each directive
  Object.entries(config.directives).forEach(([key, value]) => {
    if (key === 'upgradeInsecureRequests') {
      if (value) {
        directives.push('upgrade-insecure-requests')
      }
      return
    }

    // Convert camelCase to kebab-case
    const directiveName = key.replace(/([A-Z])/g, '-$1').toLowerCase()

    if (Array.isArray(value) && value.length > 0) {
      directives.push(`${directiveName} ${value.join(' ')}`)
    }
  })

  // Add report URI if specified
  if (config.reportUri) {
    directives.push(`report-uri ${config.reportUri}`)
  }

  return directives.join('; ')
}

/**
 * Additional security headers
 */
export const securityHeaders = {
  // Prevent MIME type sniffing
  'X-Content-Type-Options': 'nosniff',

  // Enable XSS protection (legacy, but still useful)
  'X-XSS-Protection': '1; mode=block',

  // Prevent clickjacking
  'X-Frame-Options': 'DENY',

  // Referrer policy
  'Referrer-Policy': 'strict-origin-when-cross-origin',

  // Permissions policy (formerly Feature Policy)
  'Permissions-Policy': [
    'camera=()',
    'microphone=()',
    'geolocation=()',
    'payment=()',
  ].join(', '),

  // HSTS (HTTP Strict Transport Security) - only in production
  ...(isProduction
    ? {
        'Strict-Transport-Security': 'max-age=31536000; includeSubDomains; preload',
      }
    : {}),
}

/**
 * Express/Connect middleware for setting security headers
 */
export function securityHeadersMiddleware(req: any, res: any, next: any) {
  // Set CSP header
  const cspHeader = generateCSPHeader(defaultCSPConfig)
  const headerName = defaultCSPConfig.reportOnly
    ? 'Content-Security-Policy-Report-Only'
    : 'Content-Security-Policy'
  res.setHeader(headerName, cspHeader)

  // Set other security headers
  Object.entries(securityHeaders).forEach(([name, value]) => {
    res.setHeader(name, value)
  })

  next()
}

/**
 * Vite plugin for setting security headers in development
 */
export function viteSecurityHeadersPlugin() {
  return {
    name: 'security-headers',
    configureServer(server: any) {
      server.middlewares.use((req: any, res: any, next: any) => {
        securityHeadersMiddleware(req, res, next)
      })
    },
  }
}
