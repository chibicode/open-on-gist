GistFile  = require './gist-file'

module.exports =

  activate: ->
    return if atom.project.getRepositories().length is 0

    atom.commands.add 'atom-pane',
      'open-on-gist:project': ->
        if itemPath = atom.project.getPath()
          GistFile.fromPath(itemPath).open()
