module.exports = (grunt) ->
  require('load-grunt-tasks')(grunt)

  grunt.initConfig

    clean:
      development: ['build/development','build/css']
      production: ['build/production','build/css']

    coffee:
      development:
        options:
          sourceMap: true
        files: [
          expand: true
          cwd: "app/scripts"
          src: "**/*.coffee"
          dest: "build/development/assets"
          ext: ".js"
        ]
      production:
        files: [
          expand: true
          cwd: "app/scripts"
          src: "**/*.coffee"
          dest: "build/production/assets"
          ext: ".js"
        ]

    copy:
      html: 
        src: 'app/index.html'
        dest: 'build/development/index.html'
      source:
        src: 'app/scripts/**/*.coffee'
        dest: 'build/development/'
      data:
        cwd: 'app'
        src: 'data/*'
        dest: 'build/development/'
        expand: true
      textures:
        cwd: 'app'
        src: 'textures/*'
        dest: 'build/development/'
        expand: true
      vendor:
        src: 'vendor/**/*.{js,css,png,gif}'
        dest: 'build/development/'

    connect:
      development:
        options:
          hostname: ''
          port: 8000
          base: 'build/development'
          livereload: true
          middleware: (connect, options) -> [
            connect.compress()
            connect.static('build/development')
          ]

    watch:
      index:
        files: 'app/index.html'
        tasks: ['copy:html']
      scripts:
        files: 'app/scripts/**/*.coffee'
        tasks: ['coffee', 'copy:source']
      data:
        files: 'app/data/**/*.coffee'
        tasks: ['copy:data']
      textures:
        files: 'app/textures/**/*.coffee'
        tasks: ['copy:textures']
      options:
        livereload: true

  grunt.registerTask 'default', [
    'clean:development'
    'copy:vendor'
    'copy:source'
    'copy:html'
    'copy:data'
    'copy:textures'
    'coffee:development'
    'connect:development'
    'watch'
  ]

