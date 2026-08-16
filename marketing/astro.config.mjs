// @ts-check

import cloudflare from "@astrojs/cloudflare"
import react from "@astrojs/react"
import tailwindcss from "@tailwindcss/vite"
import { defineConfig } from "astro/config"

export default defineConfig({
  site: "https://bob.solved.gg",
  session: false,
  vite: {
    plugins: [tailwindcss()],
  },
  integrations: [react()],
  adapter: cloudflare({
    imageService: "compile",
    prerenderEnvironment: "node",
  }),
})