#! /usr/bin/env ruby
# coding: utf-8

require "pp"
require "helper"

class TC_Gomibako < Test::Unit::TestCase

  TRASHDIR = 'test/gomibako/trash'
  #$stdout = StringIO.new

  def setup
    FileUtils.rm_rf 'test/gomibako/trash'
    @g00 = Gomibako.new(dir: TRASHDIR, verbose: false)
  end

  def teardown
    FileUtils.rm_rf 'test/gomibako/trash'
  end

  def test_initialize
    FileUtils.rm_rf 'test/gomibako/trash'
    assert_false(FileTest.directory? TRASHDIR)
    Gomibako.new(dir: TRASHDIR, verbose: false)
    assert(FileTest.directory? TRASHDIR)
  end

  def test_throw
    # remove file
    a_relpath = 'test/gomibako/a.txt'
    a_fullpath = File.expand_path 'test/gomibako/a.txt'
    a_fullpath_dirname = File.dirname a_fullpath
    File.open(a_relpath, 'w')
    @g00.throw(paths: [a_relpath], time: Time.new(2017, 1, 23, 12, 34, 56), verbose: false)
    assert(FileTest.directory? "#{TRASHDIR}/20170123-123456#{a_fullpath_dirname}")
    assert_false(FileTest.exist? a_relpath)
    assert(FileTest.exist? ("#{TRASHDIR}/20170123-123456#{a_fullpath_dirname}"))

    # remove directory
    a_relpath = 'test/gomibako/b/a.txt'
    a_fullpath = File.expand_path 'test/gomibako/b/a.txt'
    a_fullpath_dirname = File.dirname a_fullpath
    FileUtils.mkdir_p 'test/gomibako/b'
    File.open(a_relpath, 'w')
    @g00.throw(paths: [a_relpath], time: Time.new(2017, 1, 23, 12, 34, 56), verbose: false)
    assert(FileTest.directory? "#{TRASHDIR}/20170123-123456#{a_fullpath_dirname}")
    assert_false(FileTest.exist? a_relpath)
    assert(FileTest.exist? ("#{TRASHDIR}/20170123-123456#{a_fullpath_dirname}"))
  end
  
  def test_empty
    a_relpath = 'test/gomibako/a.txt'
    a_fullpath = File.expand_path 'test/gomibako/a.txt'
    File.open(a_relpath, 'w')
    @g00.throw(paths: [a_relpath], time: Time.new(2017, 1, 23, 12, 34, 56), verbose: false)

    assert(File.exist? "#{TRASHDIR}/20170123-123456#{a_fullpath}")
    @g00.empty(verbose: false)
    assert_false(File.exist? "#{TRASHDIR}/20170123-123456#{a_fullpath}")
  end

  def test_undo
    a_relpath = 'test/gomibako/a.txt'
    a_fullpath = File.expand_path 'test/gomibako/a.txt'
    File.open(a_relpath, 'w')
    @g00.throw(paths: [a_relpath], time: Time.new(2017, 1, 23, 12, 34, 56), verbose: false)
    b_relpath = 'test/gomibako/b.txt'
    b_fullpath = File.expand_path 'test/gomibako/b.txt'
    File.open(b_relpath, 'w')
    @g00.throw(paths: [b_relpath], time: Time.new(2017, 1, 23, 12, 34, 57), verbose: false)

    assert(File.exist? "#{TRASHDIR}/20170123-123457#{b_fullpath}")
    @g00.undo(verbose: false)
    assert_false(File.exist? "#{TRASHDIR}/20170123-123457#{b_fullpath}")
    assert(File.exist? "#{b_fullpath}")
  end

  def test_graft
  end

end

