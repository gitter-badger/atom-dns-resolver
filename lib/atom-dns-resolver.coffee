"use strict"

AtomDnsResolverView = require './atom-dns-resolver-view'
Logger = require './simple-logging'
{CompositeDisposable} = require 'atom'

module.exports = AtomDnsResolver =
  atomDnsResolverView: null
  modalPanel: null
  subscriptions: null
  logger: null

  activate: (state) ->
    @atomDnsResolverView = new AtomDnsResolverView(state.atomDnsResolverViewState)
    @modalPanel = atom.workspace.addModalPanel(item: @atomDnsResolverView.getElement(), visible: false)

    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.commands.add 'atom-text-editor', 'atom-dns-resolver:resolve': => @resolve()

    @logger = new Logger()
  deactivate: ->
    @modalPanel.destroy()
    @subscriptions.dispose()
    @atomDnsResolverView.destroy()
    @logger.destroy()
  serialize: ->
    atomDnsResolverViewState: @atomDnsResolverView.serialize()
  resolve: ->
    if editor = atom.workspace.getActiveTextEditor()
      @logger.init('DNS Resolver');
      selectedText = editor.getSelectedText()

      hasNewLine = (editor.getSelectedText().match /\r|\n/) != null

      if hasNewLine
        editor.splitSelectionsIntoLines()

      ranges = editor.getSelectedBufferRanges()

      for range in ranges
        log = @logger
        do (range) ->
          selection = editor.getTextInBufferRange(range)

          if selection == ''
            log.logWarn 'Selection is empty, skipping.', range
          else
            log.logInfo 'Attempting to resolve ' + selection, range

            dns = require('dns')
            dns.lookup selection,  (error, address, family) ->
              if error
                log.logError 'Unable to resolve ' + selection + ': ' + error, range
              else
                if selection == address
                  log.logWarn 'The selected text resolved to the value of the selection, this probably means an IP Address is selected', range
                else
                  log.logSuccess 'Successfully Resolved ' + selection + ' to ' + address + ' (IPv' + family + ')', range
                  editor.setTextInBufferRange(range, address)
