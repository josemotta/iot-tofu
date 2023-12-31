module.exports = {
  parser: '@typescript-eslint/parser',
  parserOptions: {
    // EXPERIMENTAL_useProjectService: true,
    ecmaVersion: '2020',
    sourceType: 'module',
  },
  extends: [
    // 'eslint:recommended',
    '@loopback/eslint-config',
    // 'plugin:jest-extended/all',
    // 'plugin:@typescript-eslint/recommended', // recommended rules from the @typescript-eslint/eslint-plugin
    // 'loopback',
    // 'plugin:prettier/recommended', // Enables eslint-plugin-prettier and eslint-config-prettier. This will display prettier errors as ESLint errors. Make sure this is always the last configuration in the extends array.
  ],
  // plugins: ['@typescript-eslint'],
  rules: {
    "@typescript-eslint/camelCase": 0,
    "@typescript-eslint/naming-convention": 0,
    '@typescript-eslint/no-explicit-any': 'off',
    '@typescript-eslint/no-var-requires': 'off',
    '@typescript-eslint/no-empty-function': 'off',
    'eslint-disable-next-line @typescript-eslint/ban-ts-comment': 'off',
    '@typescript-eslint/no-non-null-assertion': 'off',
    '@typescript-eslint/ban-ts-comment': 'off',
    "no-unused-vars": "off",
    "@typescript-eslint/no-unused-vars": "warn",
    // 'eslint-disable one-var': 'off',
    // '@typescript-eslint/no-floating-promises': 'off',
    'eslint no-undef': 'off',
    'max-len': 'off',
    // 'eqeqeq': 'off',
    // 'no-fallthrough': 'off',
    "@typescript-eslint/no-empty-interface": "off",
  },
  ignorePatterns: ['config.js']
};
