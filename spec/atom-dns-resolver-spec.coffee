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

Logger = require '../lib/atom-dns-resolver'

describe "DNS Resolver", ->
  [logger]
  beforeEach ->
    logger = jasmine.createSpy('logger')
    dns = jasmine.createSpy('dns')
  it "resolves an hostname to an ip address", ->
    runs ->


  it "resolves an ip address but dosn't update because it resolves to itself", ->
    runs ->

  it "fails to resole a hostname", ->
    runs ->

  it "doesn't resolve an empty string", ->
    runs ->

  it "resolves multiple selections", ->
    runs ->

  it "resolves multiple selections after splitting selection", ->
    runs ->
