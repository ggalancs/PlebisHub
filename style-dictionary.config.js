export default {
  source: ['app/frontend/design-tokens/**/*.json'],
  platforms: {
    css: {
      transformGroup: 'css',
      buildPath: 'app/frontend/assets/',
      files: [
        {
          destination: 'design-tokens.css',
          format: 'css/variables',
          options: {
            outputReferences: true,
          },
        },
      ],
    },
    js: {
      transformGroup: 'js',
      buildPath: 'app/frontend/design-tokens/',
      files: [
        {
          destination: 'tokens.ts',
          format: 'javascript/es6',
        },
      ],
    },
  },
}
