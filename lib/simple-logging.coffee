"use strict"

{MessagePanelView, LineMessageView} = require 'atom-message-panel'

module.exports = class Logger
  messages: null
  init: (title) ->
    if @messages == null
      @messages = new MessagePanelView
        title: title
        recentMessagesAtTop: true
        closeMethod: 'hide'
    else
      @messages.clear()
    @messages.attach()
  logCore: (message, textClass, range) ->
    line = range.start.row + 1
    character = range.start.column + 1

    @messages.add new LineMessageView
      line: line
      character: character
      message: message
      className: textClass
  logInfo: (message, range) ->
    @logCore message, 'text-info', range
  logWarn: (message, range) ->
    @logCore message, 'text-warning', range
  logError: (message, range) ->
    @logCore message, 'text-error', range
  logSuccess: (message, range) ->
    @logCore message, 'text-success', range
