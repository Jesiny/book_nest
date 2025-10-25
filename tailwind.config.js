module.exports = {
  content: [
    "./app/views/**/*.{erb,haml,html,slim}",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./node_modules/flowbite/**/*.js",
  ],
  theme: {
    extend: {
      typography: {
        DEFAULT: {
          css: {
            "--tw-format-body": "black",
          },
        },
      },
    },
  },
  plugins: [require("flowbite/plugin")],
};
