# Copyright 2016 Richard Slater
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
    if range
      line = range.start.row + 1
      character = range.start.column + 1
    else
      line = 0
      character = 0

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
