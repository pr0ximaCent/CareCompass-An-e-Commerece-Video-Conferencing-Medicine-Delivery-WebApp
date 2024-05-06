module.exports = {
    apps: [{
        name: 'cuet_project_testing',
        script: 'node dist/index.js',

        env: {
            "PORT": 9999,
            "NODE_ENV": "testing",
        }
    },],
};
