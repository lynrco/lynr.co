module.exports = function(grunt) {

  grunt.initConfig({
    pkg: grunt.file.readJSON('package.json'),
    grunticon: {
      icons: {
        files: [
          {
            expand: true,
            cwd: 'public',
            src: ['svg/*.svg'],
            dest: 'public'
          }
        ],
        options: {
          datasvgcss: '/css/icons.data.svg.css',
          datapngcss: '/css/icons.data.png.css',
          urlpngcss: '/css/icons.fallback.css',
          pngfolder: '/img/icon'
        }
      }
    },
    // /usr/local/share/npm/lib/node_modules/less/bin/lessc --source-map --source-map-url=/css/main.css.map --source-map-rootpath=https://lynr.co.local:9393/less public/less/main.less public/css/main.css
    less: {
      development: {
        options: {
          paths: ['public/less'],
          sourceMap: true
        },
        files: {
          "public/css/main.css": "public/less/main.less",
          "public/css/marketing.css": "public/less/marketing.less"
        }
      }
    },
    svgmin: {
      options: {
        plugins: [
          { removeViewBox: false },
          { removeUselessStrokeAndFill: false }
        ]
      },
      dist: {
        files: {
          "public/svg/add-photo.svg": "public/svg/max/add-photo.max.svg",
          "public/svg/wordmark.svg": "public/svg/max/wordmark.max.svg",
          "public/svg/wordmark-white.svg": "public/svg/max/wordmark-white.max.svg"
        }
      }
    },
    watch: {
      less: {
        files: 'public/less/**/*.less',
        tasks: ['less:development']
      }
    }
  });

  grunt.loadNpmTasks('grunt-contrib-less');
  grunt.loadNpmTasks('grunt-contrib-watch');
  grunt.loadNpmTasks('grunt-grunticon');
  grunt.loadNpmTasks('grunt-svgmin');

  grunt.registerTask('default', ['less', 'watch']);

};
