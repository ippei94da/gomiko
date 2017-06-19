#! /usr/bin/env ruby
# coding: utf-8

require "pp"
require "helper"

class Gomibako
  public :graft
end

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
    #File.open(a_relpath, 'w')
    FileUtils.touch a_relpath
    @g00.throw(paths: [a_relpath], time: Time.new(2017, 1, 23, 12, 34, 56), verbose: false)
    assert(FileTest.directory? "#{TRASHDIR}/20170123-123456#{a_fullpath_dirname}")
    assert_false(FileTest.exist? a_relpath)
    assert(FileTest.exist? ("#{TRASHDIR}/20170123-123456#{a_fullpath_dirname}"))

    # remove directory
    a_relpath = 'test/gomibako/b/a.txt'
    a_fullpath = File.expand_path 'test/gomibako/b/a.txt'
    a_fullpath_dirname = File.dirname a_fullpath
    FileUtils.mkdir_p 'test/gomibako/b'
    FileUtils.touch a_relpath
    @g00.throw(paths: [a_relpath], time: Time.new(2017, 1, 23, 12, 34, 56), verbose: false)
    assert(FileTest.directory? "#{TRASHDIR}/20170123-123456#{a_fullpath_dirname}")
    assert_false(FileTest.exist? a_relpath)
    assert(FileTest.exist? ("#{TRASHDIR}/20170123-123456#{a_fullpath_dirname}"))

    # include not exist file
    #io = StringIO.new
    @g00.throw(paths: [a_relpath, 'not_exist'],
               time: Time.new(2017, 1, 23, 12, 34, 56),
               verbose: false)
    assert(FileTest.exist? (a_relpath))
  end
  
  def test_empty
    a_relpath = 'test/gomibako/a.txt'
    a_fullpath = File.expand_path 'test/gomibako/a.txt'
    #File.open(a_relpath, 'w')
    FileUtils.touch a_relpath
    @g00.throw(paths: [a_relpath], time: Time.new(2017, 1, 23, 12, 34, 56), verbose: false)

    assert(File.exist? "#{TRASHDIR}/20170123-123456#{a_fullpath}")
    @g00.empty(verbose: false)
    assert_false(File.exist? "#{TRASHDIR}/20170123-123456#{a_fullpath}")
  end

  #def test_undo
  #  FileUtils.rm_rf "test/gomibako/undo"
  #  #a_relpath = 'a/b/c.txt'
  #  #b_relpath = 'a/b/d.txt'
  #  #b_fullpath = File.expand_path 'test/gomibako/b.txt'
  #  FileUtils.touch 'a/b/c.txt'
  #  FileUtils.touch 'a/b/d.txt'
  #  @g00.throw(paths: ['a/b/c.txt'], time: Time.new(2017, 1, 23, 12, 34, 56), verbose: false)
  #  @g00.throw(paths: ['a/b/d.txt'], time: Time.new(2017, 1, 23, 12, 34, 57), verbose: false)

  #  assert(File.exist? "#{TRASHDIR}/20170123-123456/a/b/c.txt")
  #  assert(File.exist? "#{TRASHDIR}/20170123-123457/a/b/d.txt")
  #  @g00.undo(verbose: false, dst_root: "test/gomibako/undo")
  #  assert      (File.exist? "#{TRASHDIR}/20170123-123457/a/b/c.txt")
  #  assert_false(File.exist? "#{TRASHDIR}/20170123-123457/a/b/d.txt")
  #  assert      (File.exist? "test/gomibako/undo/a/b/d.txt")
  #end

  def test_graft1
    FileUtils.rm_rf(  'test/gomibako/graft')
    FileUtils.mkdir_p('test/gomibako/graft/src/a/b/c')
    FileUtils.touch(  'test/gomibako/graft/src/a/b/c/d.txt')
    @g00.graft('test/gomibako/graft/src',
               '',
               dst_root: "test/gomibako/graft/dst",
              verbose: false)

    assert(FileTest.directory?('test/gomibako/graft/dst/a/b/c/'))
    assert(FileTest.file?('test/gomibako/graft/dst/a/b/c/d.txt'))
  end

  def test_graft2
    FileUtils.rm_rf(  'test/gomibako/graft')
    FileUtils.mkdir_p('test/gomibako/graft/src/a/b/c')
    FileUtils.mkdir_p('test/gomibako/graft/dst/a')
    FileUtils.touch(  'test/gomibako/graft/src/a/b/c/d.txt')
    #
    @g00.graft('test/gomibako/graft/src',
               'a',
               dst_root: "test/gomibako/graft/dst",
              verbose: false)
    assert(FileTest.directory?('test/gomibako/graft/dst/a/b/c/'))
    assert(FileTest.file?('test/gomibako/graft/dst/a/b/c/d.txt'))
  end

  def test_graft3
    FileUtils.rm_rf(  'test/gomibako/graft')
    FileUtils.mkdir_p('test/gomibako/graft/src/a/b/c')
    FileUtils.mkdir_p('test/gomibako/graft/dst/a/b/c')
    FileUtils.touch(  'test/gomibako/graft/src/a/b/c/d.txt')
    #
    @g00.graft('test/gomibako/graft/src',
               'a',
               dst_root: "test/gomibako/graft/dst",
              verbose: false)
    assert(FileTest.directory?('test/gomibako/graft/dst/a/b/c/'))
    assert(FileTest.file?('test/gomibako/graft/dst/a/b/c/d.txt'))
  end

    #@g00.graft('test/gomibako/graft', 'a')
    #@g00.graft('test/gomibako/graft', 'a/b')
    #@g00.graft('test/gomibako/graft', 'a/b/c')
    #@g00.graft('test/gomibako/graft', 'a/b/c/d.txt')
  #end

  #undef test_graft1
  #undef test_graft2
  #undef test_graft3

end

