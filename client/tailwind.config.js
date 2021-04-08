const defaultTheme = require("tailwindcss/defaultTheme");

module.exports = {
  theme: {
    extend: {
      fontFamily: {
        sans: ["Inter", ...defaultTheme.fontFamily.sans],
      },
    },
  },
  variants: {
    backgroundColor: ["responsive", "hover", "focus", "disabled"],
    cursor: ["responsive", "disabled"],
    opacity: ["responsive", "hover", "focus", "disabled"],
  },
  plugins: [],
  purge: [
    "./src/**/*.{js,jsx,ts,tsx,css}",
    "./public/index.html",
    "../**/*.rb",
  ],
  future: {
    removeDeprecatedGapUtilities: true,
    purgeLayersByDefault: true,
  },
};
