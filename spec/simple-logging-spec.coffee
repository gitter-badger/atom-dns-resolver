"use strict"

Logger = require '../lib/simple-logging'

describe "SimpleLogging", ->
  [panel] = []
  it "attaches to the atom viewport when init is called", ->
    waitsFor "new panel to be added", ->
      logger = new Logger()
      logger.init('DNS Resolver')
      panel = atom.workspace.getBottomPanels()[0]
    runs ->
      expect(panel.item.title).toBe('DNS Resolver')
