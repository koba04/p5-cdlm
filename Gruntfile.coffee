module.exports = (grunt) ->
  "use strict"
  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"
    watch:
      coffee:
        files: [
          "src/coffee/**/*.coffee"
        ]
        tasks: ["coffee2js"]
        options:
          debounceDelay: 1000
      css:
        files: [
          "src/scss/*.scss"
        ]
        tasks: ["css"],
        options: "<%= watch.coffee.options %>"
      all:
        files: [
          "<%= watch.css.files %>"
          "<%= watch.coffee.files %>"
        ],
        tasks: ["coffee2js", "css"],
        options: "<%= watch.coffee.options %>"
    coffee:
      compile:
        files:
          'htdocs/js/<%= pkg.name %>.js': 'src/coffee/**/*.coffee'
    uglify:
      dist:
        src: "htdocs/js/<%= pkg.name %>.js",
        dest: "htdocs/js/<%= pkg.name %>.min.js"
    compass:
      dev:
        options:
          config: "compass_config.rb",
          environment: "development"
      prod:
        options:
          config: "compass_config.rb",
          environment: "production"

  # load grunt plugings
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-uglify"
  grunt.loadNpmTasks "grunt-contrib-compass"
  grunt.loadNpmTasks 'grunt-contrib-coffee'

  # tasks
  grunt.registerTask "coffee2js", ["coffee", "uglify"]
  grunt.registerTask "css", ["compass:prod"]
