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
    compress: {
      dist: {
        options: {
          mode: 'gzip'
        },
        files: [
          { expand: true, cwd: 'out/build/', dest: 'out/dist/', src: ['**/*.js'], ext: '.js', extDot: 'last' },
          { expand: true, cwd: 'out/build/', dest: 'out/dist/', src: ['**/*.css'], ext: '.css', extDot: 'last' },
          { expand: true, cwd: 'out/build/', dest: 'out/dist/', src: ['**/*.svg'], ext: '.svg', extDot: 'last' }
        ]
      }
    },
    concat: {
      options: {
        separator: '\n'
      },
      dist: {
        src: [
          'out/dist/css/**/*.css',
          'out/dist/js/**/*.js',
          'out/dist/svg/**/*.svg',
          'out/dist/img/**/*.(gif|png|jpg)',
          'out/dist/robots.txt',
          'out/dist/favicon.ico'
        ],
        dest: 'out/all.txt'
      }
    },
    copy: {
      dist: {
        files: [
          {
            expand: true,
            cwd: 'out/build/',
            dest: 'out/dist/',
            src: ['**/*', '!**/*.js', '!**/*.css', '!**/*.svg', '!build.txt']
          }
        ]
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
      build: {
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
      almond: {
        files: 'public/js/**/*.js',
        tasks: ['build-almond']
      },
      less: {
        files: 'public/less/**/*.less',
        tasks: ['less:development']
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-compress');
  grunt.loadNpmTasks('grunt-contrib-concat');
  grunt.loadNpmTasks('grunt-contrib-copy');
  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-svgmin');

  grunt.registerTask('default', ['less:development', 'build-almond', 'watch']);
  grunt.registerTask('heroku', [
    'svgmin', 'less:production', 'build-almond', 'build', 'copy', 'compress', 'concat'
  ]);
  grunt.registerTask(
    'build',
    'Run the r.js build script',
    function() {
      var done = this.async();

      var buildjs = {
        "appDir": "public",
        "baseUrl": "js",
        "mainConfigFile": "public/js/main.js",
        "dir": "out/build",
        "modules": [
          { "name": "main" },
          { "name": "pages/admin" },
          { "name": "pages/auth" },
          { "name": "pages/home" },
          { "name": "pages/legal" }
        ],
        "findNestedDependencies": true,
        "fileExclusionRegExp": /^(\.|less|legal)/
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
        "findNestedDependencies": true
      };

      requirejs.optimize(buildjs,
        function(output) {
          grunt.log.ok('Almond build complete.');
          done();
        },
        function(err) {
          grunt.log.error('Almond build failure: ' + err);
          fatal('Almond build failure: ' + err);
        }
      );
    }
  );

};
