/** @type {import('next').NextConfig} */
const path = require('path')

// Load .env from project root (single source of truth)
require('dotenv').config({ path: path.resolve(__dirname, '../.env') })

const nextConfig = {
  reactStrictMode: true,
  // Expose env to client so NEXT_PUBLIC_* are available in the browser
  env: {
    NEXT_PUBLIC_OPENSEARCH_DASHBOARDS_URL: process.env.NEXT_PUBLIC_OPENSEARCH_DASHBOARDS_URL || '',
  },
}

module.exports = nextConfig

