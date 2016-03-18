#! /usr/bin/env ruby
# coding: utf-8

require "pp"
require "helper"

class TC_Gomibako < Test::Unit::TestCase
  def setup
    @g00 = Gomibako.new
  end

  def test_throw
    @g00.throw('tmp/a')
  end

end

