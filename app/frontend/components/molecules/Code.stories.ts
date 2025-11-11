import type { Meta, StoryObj } from '@storybook/vue3-vite'
import Code from './Code.vue'

const meta = {
  title: 'Molecules/Code',
  component: Code,
  tags: ['autodocs'],
} satisfies Meta<typeof Code>

export default meta
type Story = StoryObj<typeof meta>

export const Inline: Story = {
  args: {
    code: 'const greeting = "Hello World"',
  },
}

export const InlineInSentence: Story = {
  render: () => ({
    components: { Code },
    template: `
      <p class="text-gray-700">
        To declare a variable in JavaScript, use <Code code="const" /> or <Code code="let" /> keywords.
      </p>
    `,
  }),
}

export const BlockCode: Story = {
  args: {
    code: `function greet(name) {
  console.log(\`Hello, \${name}!\`)
  return true
}`,
    block: true,
  },
}

export const WithLanguage: Story = {
  args: {
    code: `def calculate_sum(a, b):
    """Calculate the sum of two numbers."""
    return a + b

result = calculate_sum(5, 3)
print(f"Result: {result}")`,
    block: true,
    language: 'python',
  },
}

export const WithCopy: Story = {
  args: {
    code: `npm install @vue/composition-api
npm install typescript
npm run dev`,
    block: true,
    language: 'bash',
    copyable: true,
  },
}

export const DarkVariant: Story = {
  args: {
    code: 'const x = 42',
    variant: 'dark',
  },
}

export const LightVariant: Story = {
  args: {
    code: 'let message = "Hello"',
    variant: 'light',
  },
}

export const DarkBlockVariant: Story = {
  args: {
    code: `interface User {
  id: number
  name: string
  email: string
}`,
    block: true,
    variant: 'dark',
    language: 'typescript',
  },
}

export const LightBlockVariant: Story = {
  args: {
    code: `<template>
  <div class="container">
    <h1>{{ title }}</h1>
  </div>
</template>`,
    block: true,
    variant: 'light',
    language: 'vue',
  },
}

export const JavaScript: Story = {
  args: {
    code: `// Array methods example
const numbers = [1, 2, 3, 4, 5]
const doubled = numbers.map(n => n * 2)
const sum = numbers.reduce((acc, n) => acc + n, 0)

console.log('Doubled:', doubled)
console.log('Sum:', sum)`,
    block: true,
    language: 'javascript',
    copyable: true,
  },
}

export const TypeScript: Story = {
  args: {
    code: `type Status = 'pending' | 'success' | 'error'

interface ApiResponse<T> {
  data: T
  status: Status
  message?: string
}

async function fetchData<T>(url: string): Promise<ApiResponse<T>> {
  const response = await fetch(url)
  const data = await response.json()
  return { data, status: 'success' }
}`,
    block: true,
    language: 'typescript',
    copyable: true,
  },
}

export const Python: Story = {
  args: {
    code: `class Calculator:
    def __init__(self):
        self.result = 0

    def add(self, x, y):
        self.result = x + y
        return self.result

    def multiply(self, x, y):
        self.result = x * y
        return self.result

calc = Calculator()
print(calc.add(5, 3))`,
    block: true,
    language: 'python',
    copyable: true,
  },
}

export const HTML: Story = {
  args: {
    code: `<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Page</title>
</head>
<body>
  <h1>Welcome</h1>
  <p>This is a sample HTML document.</p>
</body>
</html>`,
    block: true,
    language: 'html',
    copyable: true,
  },
}

export const CSS: Story = {
  args: {
    code: `.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}

.card {
  background: white;
  border-radius: 8px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  padding: 1.5rem;
}

.card:hover {
  box-shadow: 0 4px 8px rgba(0, 0, 0, 0.15);
}`,
    block: true,
    language: 'css',
    copyable: true,
  },
}

export const JSON: Story = {
  args: {
    code: `{
  "name": "my-app",
  "version": "1.0.0",
  "dependencies": {
    "vue": "^3.4.0",
    "typescript": "^5.0.0"
  },
  "scripts": {
    "dev": "vite",
    "build": "vite build"
  }
}`,
    block: true,
    language: 'json',
    copyable: true,
  },
}

export const SQL: Story = {
  args: {
    code: `SELECT u.id, u.name, u.email, COUNT(p.id) as post_count
FROM users u
LEFT JOIN posts p ON u.id = p.user_id
WHERE u.active = true
GROUP BY u.id, u.name, u.email
HAVING COUNT(p.id) > 5
ORDER BY post_count DESC
LIMIT 10;`,
    block: true,
    language: 'sql',
    copyable: true,
  },
}

export const Bash: Story = {
  args: {
    code: `#!/bin/bash

# Install dependencies
npm install

# Run tests
npm test

# Build for production
npm run build

# Deploy
./deploy.sh`,
    block: true,
    language: 'bash',
    copyable: true,
  },
}

export const MultipleBlocks: Story = {
  render: () => ({
    components: { Code },
    template: `
      <div class="space-y-4">
        <div>
          <h3 class="text-sm font-semibold mb-2">JavaScript</h3>
          <Code
            :code="'const x = 42;'"
            block
            language="javascript"
            copyable
          />
        </div>
        <div>
          <h3 class="text-sm font-semibold mb-2">Python</h3>
          <Code
            :code="'x = 42'"
            block
            language="python"
            copyable
          />
        </div>
        <div>
          <h3 class="text-sm font-semibold mb-2">Ruby</h3>
          <Code
            :code="'x = 42'"
            block
            language="ruby"
            copyable
          />
        </div>
      </div>
    `,
  }),
}

export const AllVariants: Story = {
  render: () => ({
    components: { Code },
    template: `
      <div class="space-y-4">
        <div>
          <p class="text-sm text-gray-600 mb-2">Default Inline</p>
          <Code code="const x = 1" variant="default" />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-2">Dark Inline</p>
          <Code code="const x = 1" variant="dark" />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-2">Light Inline</p>
          <Code code="const x = 1" variant="light" />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-2">Default Block</p>
          <Code code="const x = 1" block variant="default" />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-2">Dark Block</p>
          <Code code="const x = 1" block variant="dark" />
        </div>
        <div>
          <p class="text-sm text-gray-600 mb-2">Light Block</p>
          <Code code="const x = 1" block variant="light" />
        </div>
      </div>
    `,
  }),
}

export const LongCode: Story = {
  args: {
    code: `function processLargeDataset(data) {
  const filtered = data.filter(item => item.active && item.score > 50)
  const sorted = filtered.sort((a, b) => b.score - a.score)
  const grouped = sorted.reduce((acc, item) => {
    const category = item.category
    if (!acc[category]) acc[category] = []
    acc[category].push(item)
    return acc
  }, {})

  const results = Object.entries(grouped).map(([category, items]) => ({
    category,
    count: items.length,
    avgScore: items.reduce((sum, item) => sum + item.score, 0) / items.length,
    topItems: items.slice(0, 5)
  }))

  return results.sort((a, b) => b.avgScore - a.avgScore)
}

// Usage example
const data = generateTestData(1000)
const results = processLargeDataset(data)
console.log('Processing complete:', results)`,
    block: true,
    language: 'javascript',
    copyable: true,
  },
}

export const WithoutLanguageLabel: Story = {
  args: {
    code: `console.log("Hello World")`,
    block: true,
    language: 'javascript',
    showLanguage: false,
    copyable: true,
  },
}
