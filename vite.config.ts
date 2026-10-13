import { defineConfig } from "vite-plus";

export default defineConfig({
  staged: {
    "*.{js,ts}": "vp check --fix",
  },
});
