module.exports = {
    files: ['.'],
    formats: [
        {
            name: 'stylish',
            output: 'console',
        },
        {
            name: 'node_modules/eslint-detailed-reporter/lib/detailed.js',
            output: 'file',
            path: 'test/lint.html',
            id: 'myJunit',
        },
    ],
};