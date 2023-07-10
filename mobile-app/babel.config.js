module.exports = function(api) {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    plugins: [
      [
        "module-resolver",
        {
          alias: {
            components: "./src/components",
            services: "./src/services",
            contexts: "./src/contexts",
            views: "./src/views",
            src: "./src",
          },
        },
      ],
      ["module:react-native-dotenv", {
        "moduleName": "@env",
        "path": ".env",
      }]
    ],
  };
};
