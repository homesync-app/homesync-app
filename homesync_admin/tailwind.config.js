/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        primary: '#7f0df2',
        secondary: '#0decf2',
        dark: '#0f172a',
      },
      backdropBlur: {
        xs: '2px',
      }
    },
  },
  plugins: [],
}
