lrSnippet = require('grunt-contrib-livereload/lib/utils').livereloadSnippet
mountFolder = (connect, dir) ->
  connect.static(require('path').resolve(dir))


module.exports = (grunt) ->

  grunt.initConfig
    pkg: grunt.file.readJSON "package.json"

    coffee:
      compile:
        expand: true
        src: ["src/*.coffee"]
        rename: (dist, src) ->
          # It is impossible to specify the name of compiled js file when source file has
          # more than one dot string such as "MMD.Model.coffee", and described "ext: '.js'" as an option.
          # Therefore using 'rename' function as an alternative solution.
          # See: http://gruntjs.com/configuring-tasks
          fileName = src.split('.')
          fileName.pop()
          fileName.push 'js'
          dist + fileName.join '.'
        dest: "./src/"

    concat:
      dist:
        src: [
          "src/MMD.js" # required at first
          "src/MMD.*.js"
        ]
        dest: "dist/<%= pkg.fileName %>.js"

    uglify:
      dist:
        src: "<%= concat.dist.dest %>"
        dest: "dist/<%= pkg.fileName %>.min.js"

    connect:
      livereload:
        options:
          port: 9000
          hostname: 'localhost'
          middleware: (connect) ->
            [
              lrSnippet
              mountFolder(connect, '.')
            ]

    regarde:
      build:
        files: "<%= coffee.compile.src %>"
        tasks: ["build"]

      livereload:
        files: "<%= coffee.compile.src %>"
        tasks: ["livereload"]

    open:
      server:
        url: 'http://localhost:<%= connect.livereload.options.port %>'

  grunt.loadNpmTasks "grunt-open"
  grunt.loadNpmTasks "grunt-regarde"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-concat"
  grunt.loadNpmTasks "grunt-contrib-connect"
  grunt.loadNpmTasks "grunt-contrib-livereload"
  grunt.loadNpmTasks "grunt-contrib-uglify"

  grunt.registerTask "build", ["coffee", "concat", "uglify"]
  grunt.registerTask "run", [
    'coffee',
    'livereload-start',
    'connect:livereload',
    'open'
    'regarde'
  ]

  grunt.registerTask "default", ["build"]
