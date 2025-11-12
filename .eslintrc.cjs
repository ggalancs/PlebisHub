/* eslint-env node */
module.exports = {
  root: true,
  parser: 'vue-eslint-parser',
  parserOptions: {
    parser: '@typescript-eslint/parser',
    ecmaVersion: 'latest',
    sourceType: 'module',
  },
  extends: [
    'plugin:vue/vue3-recommended',
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'prettier',
    'plugin:storybook/recommended',
  ],
  plugins: ['@typescript-eslint'],
  env: {
    node: true,
    'vue/setup-compiler-macros': true,
  },
  rules: {
    // Vue specific
    'vue/multi-word-component-names': 'off',
    'vue/require-default-prop': 'off',
    'vue/no-v-html': 'error', // Upgraded from warn - XSS prevention
    'vue/no-mutating-props': 'error',
    'vue/no-side-effects-in-computed-properties': 'error',
    'vue/no-template-shadow': 'error',
    'vue/require-v-for-key': 'error',
    'vue/valid-v-for': 'error',
    'vue/no-use-v-if-with-v-for': 'error',
    'vue/no-duplicate-attributes': 'error',
    'vue/no-textarea-mustache': 'error',
    'vue/no-unused-components': 'warn',
    'vue/no-unused-vars': 'error',
    'vue/valid-v-bind': 'error',
    'vue/valid-v-model': 'error',
    'vue/valid-v-on': 'error',

    // TypeScript - Stricter rules
    '@typescript-eslint/no-unused-vars': [
      'error',
      { argsIgnorePattern: '^_', varsIgnorePattern: '^_' },
    ],
    '@typescript-eslint/no-explicit-any': 'error', // Prevent 'any' usage
    '@typescript-eslint/explicit-function-return-type': 'off', // Too strict for Vue
    '@typescript-eslint/explicit-module-boundary-types': 'off',
    '@typescript-eslint/no-non-null-assertion': 'warn',
    '@typescript-eslint/no-unnecessary-type-assertion': 'error',
    '@typescript-eslint/prefer-nullish-coalescing': 'warn',
    '@typescript-eslint/prefer-optional-chain': 'warn',
    '@typescript-eslint/no-floating-promises': 'error',
    '@typescript-eslint/await-thenable': 'error',
    '@typescript-eslint/no-misused-promises': 'error',
    '@typescript-eslint/require-await': 'warn',

    // Security & Best Practices
    'no-eval': 'error',
    'no-implied-eval': 'error',
    'no-new-func': 'error',
    'no-script-url': 'error',
    'no-alert': 'warn',
    'no-var': 'error',
    'prefer-const': 'error',
    'prefer-arrow-callback': 'warn',
    'no-param-reassign': ['error', { props: false }],

    // Memory Leak Prevention
    'no-unused-expressions': 'error',
    'no-return-assign': 'error',

    // Code Quality
    'eqeqeq': ['error', 'always'],
    'curly': ['error', 'all'],
    'no-throw-literal': 'error',
    'prefer-promise-reject-errors': 'error',
    'no-return-await': 'error',

    // Complexity
    'complexity': ['warn', 15],
    'max-depth': ['warn', 4],
    'max-lines-per-function': ['warn', { max: 150, skipBlankLines: true, skipComments: true }],

    // General
    'no-console': process.env.NODE_ENV === 'production' ? 'warn' : 'off',
    'no-debugger': process.env.NODE_ENV === 'production' ? 'error' : 'off',
  },
}
