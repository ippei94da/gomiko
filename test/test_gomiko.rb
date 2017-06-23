#! /usr/bin/env ruby
# coding: utf-8

require "pp"
require "helper"

class Gomiko
  public :graft, :mkdir_time
end

class TC_Gomiko < Test::Unit::TestCase

  TRASHDIR = 'test/gomiko/trash'
  #$stdout = StringIO.new

  def setup
    #FileUtils.rm_rf 'test/gomiko/trash'
    FileUtils.rm_rf 'test/gomiko'
    @g00 = Gomiko.new(dir: TRASHDIR, verbose: false)
  end

  def teardown
    FileUtils.rm_rf 'test/gomiko'
  end

  def test_initialize
    FileUtils.rm_rf 'test/gomiko/trash'
    assert_false(FileTest.directory? TRASHDIR)
    Gomiko.new(dir: TRASHDIR, verbose: false)
    assert(FileTest.directory? TRASHDIR)
  end

  def test_throw
    # remove file
    a_relpath = 'test/gomiko/a.txt'
    a_fullpath = File.expand_path 'test/gomiko/a.txt'
    a_fullpath_dirname = File.dirname a_fullpath
    #File.open(a_relpath, 'w')
    FileUtils.touch a_relpath
    @g00.throw(paths: [a_relpath], time: Time.new(2017, 1, 23, 12, 34, 56), verbose: false)
    assert(FileTest.directory? "#{TRASHDIR}/20170123-123456#{a_fullpath_dirname}")
    assert_false(FileTest.exist? a_relpath)
    assert(FileTest.exist? ("#{TRASHDIR}/20170123-123456#{a_fullpath_dirname}"))

    # remove directory
    setup
    a_relpath = 'test/gomiko/b/a.txt'
    a_fullpath = File.expand_path 'test/gomiko/b/a.txt'
    a_fullpath_dirname = File.dirname a_fullpath
    FileUtils.mkdir_p 'test/gomiko/b'
    FileUtils.touch a_relpath
    @g00.throw(paths: [a_relpath], time: Time.new(2017, 1, 23, 12, 34, 56), verbose: false)
    pp "#{TRASHDIR}/20170123-123456#{a_fullpath_dirname}"
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
    a_relpath = 'test/gomiko/a.txt'
    a_fullpath = File.expand_path 'test/gomiko/a.txt'
    #File.open(a_relpath, 'w')
    FileUtils.touch a_relpath
    @g00.throw(paths: [a_relpath], time: Time.new(2017, 1, 23, 12, 34, 56), verbose: false)

    assert(File.exist? "#{TRASHDIR}/20170123-123456#{a_fullpath}")
    @g00.empty(verbose: false)
    assert_false(File.exist? "#{TRASHDIR}/20170123-123456#{a_fullpath}")
  end

  def test_empty_before
    # before option
    a_relpath = 'test/gomiko/a.txt'
    a_fullpath = File.expand_path 'test/gomiko/a.txt'
    #File.open(a_relpath, 'w')
    FileUtils.touch a_relpath
    @g00.throw(paths: [a_relpath],
               time: Time.new(2017, 1, 23, 12, 34, 56),
               verbose: false)

    assert(File.exist? "#{TRASHDIR}/20170123-123456#{a_fullpath}")
    @g00.empty(before: 5,
               time: Time.new(2017, 1, 27, 12, 34, 56),
               verbose: false)
    assert(File.exist? "#{TRASHDIR}/20170123-123456#{a_fullpath}")
    @g00.empty(before: 3,
               time: Time.new(2017, 1, 27, 12, 34, 56),
               verbose: false)
    assert(File.exist? "#{TRASHDIR}/20170123-123456#{a_fullpath}")
  end

  #def test_undo
  #  FileUtils.rm_rf "test/gomiko/undo"
  #  #a_relpath = 'a/b/c.txt'
  #  #b_relpath = 'a/b/d.txt'
  #  #b_fullpath = File.expand_path 'test/gomiko/b.txt'
  #  FileUtils.touch 'a/b/c.txt'
  #  FileUtils.touch 'a/b/d.txt'
  #  @g00.throw(paths: ['a/b/c.txt'], time: Time.new(2017, 1, 23, 12, 34, 56), verbose: false)
  #  @g00.throw(paths: ['a/b/d.txt'], time: Time.new(2017, 1, 23, 12, 34, 57), verbose: false)

  #  assert(File.exist? "#{TRASHDIR}/20170123-123456/a/b/c.txt")
  #  assert(File.exist? "#{TRASHDIR}/20170123-123457/a/b/d.txt")
  #  @g00.undo(verbose: false, dst_root: "test/gomiko/undo")
  #  assert      (File.exist? "#{TRASHDIR}/20170123-123457/a/b/c.txt")
  #  assert_false(File.exist? "#{TRASHDIR}/20170123-123457/a/b/d.txt")
  #  assert      (File.exist? "test/gomiko/undo/a/b/d.txt")
  #end

  # ls
  def test_ls
    io = StringIO.new
    a_relpath = 'test/gomiko/a.txt'
    a_fullpath = File.expand_path 'test/gomiko/a.txt'
    #File.open(a_relpath, 'w')
    FileUtils.touch a_relpath
    @g00.throw(paths: [a_relpath], time: Time.new(2017, 1, 23, 12, 34, 56), verbose: false)
    pp @g00.ls
    #pp @g00.ls(io: io)
  end

  def test_graft1
    FileUtils.rm_rf(  'test/gomiko/graft')
    FileUtils.mkdir_p('test/gomiko/graft/src/a/b/c')
    FileUtils.touch(  'test/gomiko/graft/src/a/b/c/d.txt')
    @g00.graft('test/gomiko/graft/src',
               '',
               dst_root: "test/gomiko/graft/dst",
              verbose: false)

    assert(FileTest.directory?('test/gomiko/graft/dst/a/b/c/'))
    assert(FileTest.file?('test/gomiko/graft/dst/a/b/c/d.txt'))
  end

  def test_graft2
    FileUtils.rm_rf(  'test/gomiko/graft')
    FileUtils.mkdir_p('test/gomiko/graft/src/a/b/c')
    FileUtils.mkdir_p('test/gomiko/graft/dst/a')
    FileUtils.touch(  'test/gomiko/graft/src/a/b/c/d.txt')
    #
    @g00.graft('test/gomiko/graft/src',
               'a',
               dst_root: "test/gomiko/graft/dst",
              verbose: false)
    assert(FileTest.directory?('test/gomiko/graft/dst/a/b/c/'))
    assert(FileTest.file?('test/gomiko/graft/dst/a/b/c/d.txt'))
  end

  def test_graft3
    FileUtils.rm_rf(  'test/gomiko/graft')
    FileUtils.mkdir_p('test/gomiko/graft/src/a/b/c')
    FileUtils.mkdir_p('test/gomiko/graft/dst/a/b/c')
    FileUtils.touch(  'test/gomiko/graft/src/a/b/c/d.txt')
    #
    @g00.graft('test/gomiko/graft/src',
               'a',
               dst_root: "test/gomiko/graft/dst",
              verbose: false)
    assert(FileTest.directory?('test/gomiko/graft/dst/a/b/c/'))
    assert(FileTest.file?('test/gomiko/graft/dst/a/b/c/d.txt'))
  end

  def test_mkdir_time
    assert_false(FileTest.directory? "#{TRASHDIR}/20170123-123456")
    @g00.mkdir_time(Time.new(2017, 1, 23, 12, 34, 56))
    assert(      FileTest.directory? "#{TRASHDIR}/20170123-123456")
    assert_false(FileTest.directory? "#{TRASHDIR}/20170123-123456-1")
    @g00.mkdir_time(Time.new(2017, 1, 23, 12, 34, 56))
    assert(      FileTest.directory? "#{TRASHDIR}/20170123-123456")
    assert(      FileTest.directory? "#{TRASHDIR}/20170123-123456-1")
    
  end
end

