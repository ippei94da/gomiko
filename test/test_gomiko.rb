#! /usr/bin/env ruby
# coding: utf-8

require "pp"
require "helper"

class Gomiko
  public :graft, :mkdir_time
end

class TC_Gomiko < Test::Unit::TestCase

  #WORKDIR  = 'test/gomiko'
  #TRASHDIR = 'test/gomiko/tmp_trash'
  WORKDIR  = "#{Dir.pwd}/test/gomiko/tmp/work"
  TRASHDIR = "#{Dir.pwd}/test/gomiko/tmp/trash"

  #pp WORKDIR; exit
  def setup
    FileUtils.rm_rf TRASHDIR
    FileUtils.rm_rf WORKDIR
    FileUtils.mkdir_p WORKDIR
    @g00 = Gomiko.new(dir: TRASHDIR, verbose: false)
  end

  def teardown
    FileUtils.rm_rf TRASHDIR
  end

  def test_initialize
    FileUtils.rm_rf TRASHDIR
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
    #pp "#{TRASHDIR}/20170123-123456#{a_fullpath_dirname}"
    assert(FileTest.directory? "#{TRASHDIR}/20170123-123456#{a_fullpath_dirname}")
    assert_false(FileTest.exist? a_relpath)
    assert(FileTest.exist? ("#{TRASHDIR}/20170123-123456#{a_fullpath_dirname}"))

    # include not exist file
    # HERE
    @g00.throw(paths: [a_relpath, 'not_exist'],
               time: Time.new(2017, 1, 23, 12, 34, 56),
               verbose: false)
    assert_false(FileTest.exist? (a_relpath))
    # HERE
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

  def test_undo1
    FileUtils.mkdir_p "#{WORKDIR}/a/b"
    FileUtils.touch   "#{WORKDIR}/a/b/c.txt"
    FileUtils.touch   "#{WORKDIR}/a/b/d.txt"
    @g00.throw(paths: ["#{WORKDIR}/a/b/c.txt"],
               time: Time.new(2017, 1, 23, 12, 34, 56),
               verbose: false)
    @g00.throw(paths: ["#{WORKDIR}/a/b/d.txt"],
               time: Time.new(2017, 1, 23, 12, 34, 57),
               verbose: false)
    assert(File.exist? "#{TRASHDIR}/20170123-123456/#{WORKDIR}/a/b/c.txt")
    assert(File.exist? "#{TRASHDIR}/20170123-123457/#{WORKDIR}/a/b/d.txt")
    @g00.undo("20170123-123456", verbose: false)
    assert_false(File.exist? "#{TRASHDIR}/20170123-123456/#{WORKDIR}/a/b/c.txt")
    assert      (File.exist? "#{TRASHDIR}/20170123-123457/#{WORKDIR}/a/b/d.txt")
    assert      (File.exist? "#{WORKDIR}/a/b/c.txt")
  end

  def test_undo2
    FileUtils.mkdir_p "#{WORKDIR}/a/b"
    FileUtils.touch   "#{WORKDIR}/a/b/c.txt"
    FileUtils.touch   "#{WORKDIR}/a/b/d.txt"
    @g00.throw(paths: ["#{WORKDIR}/a/b/c.txt"],
               time: Time.new(2017, 1, 23, 12, 34, 56),
               verbose: false)
    @g00.throw(paths: ["#{WORKDIR}/a/b/d.txt"],
               time: Time.new(2017, 1, 23, 12, 34, 57),
               verbose: false)
    assert(File.exist? "#{TRASHDIR}/20170123-123456/#{WORKDIR}/a/b/c.txt")
    assert(File.exist? "#{TRASHDIR}/20170123-123457/#{WORKDIR}/a/b/d.txt")
    @g00.undo("#{TRASHDIR}/20170123-123456", verbose: false)
    assert_false(File.exist? "#{TRASHDIR}/20170123-123456/#{WORKDIR}/a/b/c.txt")
    assert      (File.exist? "#{TRASHDIR}/20170123-123457/#{WORKDIR}/a/b/d.txt")
    assert      (File.exist? "#{WORKDIR}/a/b/c.txt")
  end

  # ls, list
  def test_list
    a_relpath = 'test/gomiko/a.txt'
    FileUtils.touch a_relpath
    @g00.throw(paths: [a_relpath],
               time: Time.new(2017, 1, 23, 12, 34, 56),
               verbose: false)
    a_relpath = 'test/gomiko/a.txt'
    FileUtils.touch a_relpath
    @g00.throw(paths: [a_relpath],
               time: Time.new(2017, 1, 23, 12, 34, 57),
               verbose: false)

    corrects = ["20170123-123456", "20170123-123457" ]
    assert_equal(corrects, @g00.list)
  end

  def test_info1
    path = "#{WORKDIR}/a.txt"
    FileUtils.touch path
    @g00.throw(paths: [path],
               time: Time.new(2017, 1, 23, 12, 34, 56),
               verbose: false)
    #size is dependent on system
    results = @g00.info("20170123-123456")
    assert_equal('20170123-123456', results[1])
    assert_equal(path,              results[2])
  end

  def test_info2
    path = "#{WORKDIR}/.a"
    FileUtils.touch path
    @g00.throw(paths: [path],
               time: Time.new(2017, 1, 23, 12, 34, 56),
               verbose: false)
    #size is dependent on system
    results = @g00.info("20170123-123456")
    assert_equal('20170123-123456', results[1])
    assert_equal(path,              results[2])
  end

  def test_graft
    path_a = "#{WORKDIR}/a.txt"
    FileUtils.touch path_a
    @g00.graft('test/gomiko/graft/src',
               'a',
               dst_root: "test/gomiko/graft/dst",
               verbose: false)
    assert(FileTest.directory?('test/gomiko/graft/dst/a/b/c/'))
    assert(FileTest.file?('test/gomiko/graft/dst/a/b/c/d.txt'))
  end

  def test_graft2
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

  #undef test_initialize
  #undef test_throw
  #undef test_empty
  #undef test_empty_before
  #undef test_undo
  #undef test_ls
  #undef test_graft1
  #undef test_graft2
  #undef test_graft3
  #undef test_mkdir_time
  undef test_info1

end

