module.exports = function(grunt) {

  var requirejs = require('requirejs');

  var lessFiles = {
    "public/css/main.css": "public/less/main.less",
    "public/css/email.css": "public/less/email.less",
    "public/css/icons.data.png.css": "public/less/icons.data.png.less",
    "public/css/icons.data.svg.css": "public/less/icons.data.svg.less"
  };

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    concat: {
      options: {
        separator: '\n'
      },
      dist: {
        src: [
          'dist/css/**/*.css',
          'dist/js/**/*.js',
          'dist/svg/**/*.svg',
          'dist/img/**/*.(gif|png|jpg)',
          'dist/robots.txt',
          'dist/favicon.ico'
        ],
        dest: 'dist/all.txt'
      }
    },
    // /usr/local/share/npm/lib/node_modules/less/bin/lessc --source-map --source-map-url=/css/main.css.map --source-map-rootpath=https://lynr.co.local:9393/less public/less/main.less public/css/main.css
    less: {
      development: {
        options: {
          paths: ['public/less'],
          sourceMap: true
        },
        files: lessFiles
      },
      production: {
        options: {
          paths: ['public/less'],
          cleancss: true
        },
        files: lessFiles
      },
    },
    svgmin: {
      options: {
        plugins: [
          { removeViewBox: false },
          { removeUselessStrokeAndFill: false }
        ]
      },
      dist: {
        files: [
          {
            expand: true,
            src: ['public/svg/max/*.svg'],
            dest: 'public/svg/',
            rename: function(dest, src, opts) {
              var path = dest;
              var filename = src.replace(/^.*\/(.*)\.max\.svg$/, '$1');
              return path + '/' + filename + '.svg';
            }
          }
        ]
      }
    },
    watch: {
      less: {
        files: 'public/less/**/*.less',
        tasks: ['less:development']
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-svgmin');

  grunt.registerTask('default', ['less:development', 'watch']);
  grunt.registerTask('heroku', ['svgmin', 'less:production', 'build-almond', 'build', 'concat']);
  grunt.registerTask(
    'build',
    'Run the r.js build script',
    function() {
      var done = this.async();

      var buildjs = {
        "appDir": "public",
        "baseUrl": "js",
        "mainConfigFile": "public/js/main.js",
        "dir": "dist",
        "paths": {
          "stripe": "empty:"
        },
        "modules": [
          { "name": "main" },
          { "name": "pages/admin" },
          { "name": "pages/auth" },
          { "name": "pages/home" },
          { "name": "pages/legal" }
        ],
        "findNestedDependencies": true,
        "fileExclusionRegExp": /^(\.|less|legal|build)/
      };

      requirejs.optimize(buildjs,
        function(output) {
          grunt.log.ok('Main build complete.');
          done();
        },
        function(err) {
          grunt.log.error('Main build failure: ' + err);
          fatal('Main build failure: ' + err);
        }
      );
    }
  );
  grunt.registerTask(
    'build-almond',
    'Run the r.js build script with Almond',
    function() {
      var done = this.async();

      var buildjs = {
        "baseUrl": "public/js",
        "mainConfigFile": "public/js/main.js",
        "name": "libs/almond-0.2.9",
        "include": ['main', 'pages/admin', 'pages/auth', 'pages/home', 'pages/legal'],
        "insertRequire": ['main'],
        "out": "public/js/built/main.js",
        "paths": {
          "stripe": "empty:"
        },
        "findNestedDependencies": true
      };

      requirejs.optimize(buildjs,
        function(output) {
          grunt.log.writeln(output);
          grunt.log.ok('Main build complete.');
          done();
        },
        function(err) {
          grunt.log.error('Main build failure: ' + err);
          fatal('Main build failure: ' + err);
        }
      );
    }
  );

};
