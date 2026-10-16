/** @type {import('tailwindcss').Config} */
export default {
  content: ["./index.html", "./src/**/*.{js,ts,jsx,tsx}"],
  theme: {
    extend: {
      colors: {
        pixeldrop: {
          bg: "#080808",
          surface: "#121217",
          card: "#181820",
          accent: "#FF6338",
          cyan: "#00F0FF",
          border: "#282836",
        },
      },
    },
  },
  plugins: [],
};
