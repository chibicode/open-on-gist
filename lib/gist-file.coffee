Shell = require 'shell'

module.exports =
class GistFile
  # Public
  @fromPath: (filePath) ->
    new GistFile(filePath)

  # Internal
  constructor: (@filePath) ->
    [@repo] = atom.project.getRepositories()

  # Public
  open: ->
    if @isOpenable()
      @openUrlInBrowser(@gistRepoUrl())
    else
      @reportValidationErrors()

  # Public
  isOpenable: ->
    @validationErrors().length is 0

  # Public
  validationErrors: ->
    unless @gitUrl()
      return ["No URL defined for remote (#{@remoteName()})"]

    unless @gistRepoUrl()
      return ["Remote URL is not hosted on GitHub.com (#{@gitUrl()})"]

    []

  # Internal
  reportValidationErrors: ->
    atom.beep()
    console.warn error for error in @validationErrors()

  # Internal
  openUrlInBrowser: (url) ->
    Shell.openExternal url

  # Internal
  gitUrl: ->
    remoteOrBestGuess = @remoteName() ? 'origin'
    @repo.getConfigValue("remote.#{remoteOrBestGuess}.url", @filePath)

  # Internal
  gistRepoUrl: ->
    url = @gitUrl()
    if url.match /https:\/\/gist\.github\.com\/[^\/]+\.git/ # e.g., https://gist.github.com/foo.git
      url = url.replace(/\.git$/, '')
    else if url.match /git@gist\.github\.com:[^:]+\.git/    # e.g., git@gist.github.com:foo.git
      url = url.replace /^git@([^:]+):(.+)$/, (match, host, repoPath) ->
        repoPath = repoPath.replace(/^\/+/, '') # replace leading slashes
        "http://#{host}/#{repoPath}".replace(/\.git$/, '')

    url = url.replace(/\/+$/, '')

    return url

  # Internal
  remoteName: ->
    shortBranch = @repo.getShortHead(@filePath)
    return null unless shortBranch

    branchRemote = @repo.getConfigValue("branch.#{shortBranch}.remote", @filePath)
    return null unless branchRemote?.length > 0

    branchRemote
