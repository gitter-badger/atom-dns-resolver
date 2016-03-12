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

atomDnsResolver = require '../lib/atom-dns-resolver'
logger = require '../lib/simple-logging'
dns = require 'dns'

describe "DNS Resolver", ->
  [fakeLogger, fakeDns, fakeWorkspace] = []

  fakeLogger = jasmine.createSpyObj('logger', ['init', 'logInfo', 'logSuccess', 'logWarn', 'logError'])
  fakeDns = jasmine.createSpyObj('dns', ['lookup'])
  fakeWorkspace = jasmine.createSpyObj('dns', ['getActiveTextEditor'])
  fakeRange = jasmine.createSpy('fakeRange')
  fakeEditor = jasmine.createSpyObj('editor', ['getSelectedText', 'getSelectedBufferRanges', 'getTextInBufferRange', 'setTextInBufferRange', 'splitSelectionsIntoLines'])
  fakeEditor.getSelectedBufferRanges.andReturn(['fakeRange'])
  fakeWorkspace.getActiveTextEditor.andReturn(fakeEditor)

  beforeEach ->
    fakeLogger.init.reset()
    fakeLogger.logInfo.reset()
    fakeLogger.logSuccess.reset()
    fakeLogger.logWarn.reset()
    fakeLogger.logError.reset()
    fakeDns.lookup.reset()
    fakeWorkspace.getActiveTextEditor.reset()
  it "resolves an hostname to an ip address", ->
    runs ->
      fakeEditor.getSelectedText.andReturn('foo')
      fakeEditor.getTextInBufferRange.andReturn('foo')
      fakeDns.lookup.andCallFake (selection, callback) ->
        callback(null, '216.58.198.68', 4)
      atomDnsResolver.activate null, fakeLogger, fakeDns, fakeWorkspace
      atomDnsResolver.resolve()
      expect(fakeLogger.init).toHaveBeenCalledWith('DNS Resolver')
      expect(fakeLogger.logInfo).toHaveBeenCalledWith('Attempting to resolve foo', 'fakeRange')
      expect(fakeDns.lookup).toHaveBeenCalled()
      expect(fakeDns.lookup.mostRecentCall.args[0]).toBe('foo')
      expect(fakeLogger.logSuccess).toHaveBeenCalledWith('Successfully resolved foo to 216.58.198.68 (IPv4)', 'fakeRange')
  it "resolves an ip address but dosn't update because it resolves to itself", ->
    runs ->
      fakeEditor.getSelectedText.andReturn('216.58.198.68')
      fakeEditor.getTextInBufferRange.andReturn('216.58.198.68')
      fakeDns.lookup.andCallFake (selection, callback) ->
        callback(null, '216.58.198.68', 4)
      atomDnsResolver.activate null, fakeLogger, fakeDns, fakeWorkspace
      atomDnsResolver.resolve()
      expect(fakeLogger.init).toHaveBeenCalledWith('DNS Resolver')
      expect(fakeLogger.logInfo).toHaveBeenCalledWith('Attempting to resolve 216.58.198.68', 'fakeRange')
      expect(fakeDns.lookup).toHaveBeenCalled()
      expect(fakeDns.lookup.mostRecentCall.args[0]).toBe('216.58.198.68')
      expect(fakeLogger.logWarn).toHaveBeenCalledWith('The selected text resolved to the value of the selection, this probably means an IP address is selected', 'fakeRange')
  it "fails to resole a hostname", ->
    runs ->
      fakeEditor.getSelectedText.andReturn('foo')
      fakeEditor.getTextInBufferRange.andReturn('foo')
      fakeDns.lookup.andCallFake (selection, callback) ->
        callback('bar')
      atomDnsResolver.activate null, fakeLogger, fakeDns, fakeWorkspace
      atomDnsResolver.resolve()
      expect(fakeLogger.init).toHaveBeenCalledWith('DNS Resolver')
      expect(fakeLogger.logInfo).toHaveBeenCalledWith('Attempting to resolve foo', 'fakeRange')
      expect(fakeDns.lookup).toHaveBeenCalled()
      expect(fakeDns.lookup.mostRecentCall.args[0]).toBe('foo')
      expect(fakeLogger.logError).toHaveBeenCalledWith('Unable to resolve foo: bar', 'fakeRange')
  it "doesn't resolve an empty string", ->
    runs ->
      fakeEditor.getSelectedText.andReturn('')
      fakeEditor.getTextInBufferRange.andReturn('')
      atomDnsResolver.activate null, fakeLogger, fakeDns, fakeWorkspace
      atomDnsResolver.resolve()
      expect(fakeLogger.init).toHaveBeenCalledWith('DNS Resolver')
      expect(fakeLogger.logWarn).toHaveBeenCalledWith('Selection is empty, skipping.', 'fakeRange')
  it "resolves multiple selections", ->
    runs ->
      fakeEditor.getSelectedText.andReturn('foo\nfoo')
      fakeEditor.getTextInBufferRange.andReturn('foo')
      fakeEditor.getSelectedBufferRanges.andReturn(['fakeRange', 'fakeRange'])
      fakeDns.lookup.andCallFake (selection, callback) ->
        callback(null, '216.58.198.68', 4)
      atomDnsResolver.activate null, fakeLogger, fakeDns, fakeWorkspace
      atomDnsResolver.resolve()
      expect(fakeLogger.init).toHaveBeenCalledWith('DNS Resolver')
      expect(fakeEditor.splitSelectionsIntoLines).toHaveBeenCalled()
      expect(fakeLogger.init.calls.length).toEqual(1)
      expect(fakeLogger.logInfo).toHaveBeenCalled()
      console.log fakeLogger.logInfo.calls
      expect(fakeLogger.logInfo.calls.length).toEqual(2)
      expect(fakeDns.lookup).toHaveBeenCalled()
      expect(fakeDns.lookup.calls.length).toEqual(2)
      expect(fakeLogger.logSuccess).toHaveBeenCalledWith('Successfully resolved foo to 216.58.198.68 (IPv4)', 'fakeRange')
      expect(fakeLogger.logSuccess.calls.length).toEqual(2)
