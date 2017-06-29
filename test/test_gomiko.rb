#! /usr/bin/env ruby
# coding: utf-8

require "pp"
require "helper"

class Gomiko
  public :graft, :mkdir_time, :path2id
end

class TC_Gomiko < Test::Unit::TestCase

  TMPDIR   = "#{Dir.pwd}/test/tmp"
  WORKDIR  = "#{TMPDIR}/work"
  TRASHDIR = "#{TMPDIR}/trash"

  #pp WORKDIR; exit
  def setup
    FileUtils.rm_rf TMPDIR
    FileUtils.mkdir_p WORKDIR
    @g00 = Gomiko.new(dir: TRASHDIR, verbose: false)
  end

  def teardown
    FileUtils.rm_rf TMPDIR
  end

  def test_initialize
    FileUtils.rm_rf TRASHDIR
    assert_false(FileTest.directory? TRASHDIR)
    Gomiko.new(dir: TRASHDIR, verbose: false)
    assert(FileTest.directory? TRASHDIR)
  end

  def test_throw1
    # remove file
    a_relpath = 'test/tmp/a.txt'
    a_fullpath = File.expand_path 'test/a.txt'
    a_fullpath_dirname = File.dirname a_fullpath
    FileUtils.touch a_relpath
    @g00.throw(paths: [a_relpath], time: Time.new(2017, 1, 23, 12, 34, 56), verbose: false)
    assert(FileTest.directory? "#{TRASHDIR}/20170123-123456#{a_fullpath_dirname}")
    assert_false(FileTest.exist? a_relpath)
    assert(FileTest.exist? ("#{TRASHDIR}/20170123-123456#{a_fullpath_dirname}"))
    assert_equal( Time.new(2017, 1, 23, 12, 34, 56), 
           File.mtime("#{TRASHDIR}/20170123-123456"))
  end

  def test_throw2
    # remove directory
    setup
    a_relpath = 'test/tmp/b/a.txt'
    a_fullpath = File.expand_path 'test/tmp/b/a.txt'
    a_fullpath_dirname = File.dirname a_fullpath
    FileUtils.mkdir_p 'test/tmp/b'
    FileUtils.touch a_relpath
    @g00.throw(paths: [a_relpath], time: Time.new(2017, 1, 23, 12, 34, 56), verbose: false)
    assert(FileTest.directory? "#{TRASHDIR}/20170123-123456#{a_fullpath_dirname}")
    assert_false(FileTest.exist? a_relpath)
    assert(FileTest.exist? ("#{TRASHDIR}/20170123-123456#{a_fullpath_dirname}"))
    @g00.throw(paths: [a_relpath, 'not_exist'],
               time: Time.new(2017, 1, 23, 12, 34, 56),
               verbose: false)
    assert_false(FileTest.exist? (a_relpath))
  end

  def test_throw3
    # remove deadlink
    a_relpath = 'test/tmp/a.txt'
    b_relpath = 'test/tmp/b.txt'
    a_fullpath = File.expand_path 'test/a.txt'
    a_fullpath_dirname = File.dirname a_fullpath
    FileUtils.ln_s(b_relpath, a_relpath)
    #FileUtils.rm b_relpath
    @g00.throw(paths: [], time: Time.new(2017, 1, 23, 12, 34, 56), verbose: false)
    assert(FileTest.directory? "#{TRASHDIR}/20170123-123456#{a_fullpath_dirname}")
    assert_false(FileTest.exist? a_relpath)
    assert(FileTest.exist? ("#{TRASHDIR}/20170123-123456#{a_fullpath_dirname}"))
    assert_equal( Time.new(2017, 1, 23, 12, 34, 56), 
           File.mtime("#{TRASHDIR}/20170123-123456"))
  end

  def test_empty1
    a_relpath = 'test/tmp/a.txt'
    a_fullpath = File.expand_path 'test/tmp/a.txt'
    FileUtils.touch a_relpath
    @g00.throw(paths: [a_relpath], time: Time.new(2017, 1, 23, 12, 34, 56), verbose: false)
    assert(File.exist? "#{TRASHDIR}/20170123-123456#{a_fullpath}")
    @g00.empty(verbose: false)
    assert_false(File.exist? "#{TRASHDIR}/20170123-123456#{a_fullpath}")
  end

  def test_empty2
    a_relpath = 'test/tmp/a.txt'
    b_relpath = 'test/tmp/b.txt'
    a_fullpath = File.expand_path 'test/tmp/a.txt'
    b_fullpath = File.expand_path 'test/tmp/b.txt'
    FileUtils.touch a_relpath
    FileUtils.touch b_relpath
    @g00.throw(paths: [a_relpath], time: Time.new(2017, 1, 23, 12, 34, 56), verbose: false)
    @g00.throw(paths: [b_relpath], time: Time.new(2017, 1, 23, 12, 34, 57), verbose: false)
    assert(File.exist? "#{TRASHDIR}/20170123-123456#{a_fullpath}")
    assert(File.exist? "#{TRASHDIR}/20170123-123457#{b_fullpath}")
    @g00.empty(ids: ['20170123-123456'], verbose: false)
    assert_false(File.exist? "#{TRASHDIR}/20170123-123456#{a_fullpath}")
    assert      (File.exist? "#{TRASHDIR}/20170123-123457#{b_fullpath}")
  end

  def test_empty3 #mtime
    # mtime option
    a_relpath = 'test/tmp/a.txt'
    a_fullpath = File.expand_path 'test/tmp/a.txt'
    FileUtils.touch a_relpath
    @g00.throw(paths: [a_relpath],
               time: Time.new(2017, 6, 15, 00, 00, 00),
               verbose: false)

    assert(File.exist? "#{TRASHDIR}/20170615-000000#{a_fullpath}")
    @g00.empty(mtime: -10,
               time: Time.new(2017, 6, 24, 23, 59, 59),
               verbose: false)
    assert(File.exist? "#{TRASHDIR}/20170615-000000#{a_fullpath}")
    @g00.empty(mtime: -10,
               time: Time.new(2017, 6, 25, 00, 00, 00),
               verbose: false)
    assert_false(File.exist? "#{TRASHDIR}/20170123-123456#{a_fullpath}")
  end

  def test_empty4 #mtime
    # mtime option
    a_relpath = 'test/tmp/a.txt'
    b_relpath = 'test/tmp/b.txt'
    c_relpath = 'test/tmp/c.txt'
    d_relpath = 'test/tmp/d.txt'
    a_fullpath = File.expand_path 'test/tmp/a.txt'
    b_fullpath = File.expand_path 'test/tmp/b.txt'
    c_fullpath = File.expand_path 'test/tmp/c.txt'
    d_fullpath = File.expand_path 'test/tmp/d.txt'
    FileUtils.touch a_relpath
    FileUtils.touch b_relpath
    FileUtils.touch c_relpath
    FileUtils.touch d_relpath

    @g00.throw(paths: [a_relpath],
               time: Time.new(2017, 6, 15, 00, 00, 00),
               verbose: false)
    @g00.throw(paths: [b_relpath],
               time: Time.new(2017, 6, 15, 12, 00, 00),
               verbose: false)
    @g00.throw(paths: [c_relpath],
               time: Time.new(2017, 7, 15, 00, 00, 00),
               verbose: false)
    @g00.throw(paths: [d_relpath],
               time: Time.new(2017, 7, 15, 12, 00, 00),
               verbose: false)

    assert(File.exist? "#{TRASHDIR}/20170615-000000#{a_fullpath}")
    assert(File.exist? "#{TRASHDIR}/20170615-120000#{b_fullpath}")
    assert(File.exist? "#{TRASHDIR}/20170715-000000#{c_fullpath}")
    assert(File.exist? "#{TRASHDIR}/20170715-120000#{d_fullpath}")
    @g00.empty(ids: %w(20170615-000000 20170715-000000),
               mtime: -3,
               time: Time.new(2017, 7, 16, 01, 00, 00),
               verbose: false)
    assert_false(File.exist? "#{TRASHDIR}/20170615-000000#{a_fullpath}")
    assert      (File.exist? "#{TRASHDIR}/20170615-120000#{b_fullpath}")
    assert      (File.exist? "#{TRASHDIR}/20170715-000000#{c_fullpath}")
    assert      (File.exist? "#{TRASHDIR}/20170715-120000#{d_fullpath}")
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
  def test_list1
    a_relpath = 'test/tmp/a.txt'
    FileUtils.touch a_relpath
    @g00.throw(paths: [a_relpath],
               time: Time.new(2017, 1, 23, 12, 34, 56),
               verbose: false)
    a_relpath = 'test/tmp/a.txt'
    FileUtils.touch a_relpath
    @g00.throw(paths: [a_relpath],
               time: Time.new(2017, 1, 23, 12, 34, 57),
               verbose: false)
    corrects = ["20170123-123456", "20170123-123457" ]
    assert_equal(corrects, @g00.list)
  end

  def test_list2
    FileUtils.mkdir_p @g00.trashdir + '20170628-000000'
    #pp @g00.list
    #assert_equal(corrects, @g00.list)
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
    #pp results[3]
    corrects = [
      ["/", "/", "/home"],
      ["/", "/", "/home/ippei"],
      ["/", "/", "/home/ippei/git"],
      ["/", "/", "/home/ippei/git/gomiko"],
      ["/", "/", "/home/ippei/git/gomiko/test"],
      ["/", "/", "/home/ippei/git/gomiko/test/tmp"],
      ["/", "/", "/home/ippei/git/gomiko/test/tmp/work"],
      [".", " ", "/home/ippei/git/gomiko/test/tmp/work/a.txt"]
    ]
    assert_equal(corrects, results[3])

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

  def test_info3
    FileUtils.mkdir_p "#{WORKDIR}/a/"
    FileUtils.touch "#{WORKDIR}/a/b"
    @g00.throw(paths: ["#{WORKDIR}/a"],
               time: Time.new(2017, 1, 23, 12, 34, 56),
               verbose: false)
    #size is dependent on system
    results = @g00.info("20170123-123456")
    assert_equal('20170123-123456', results[1])
    assert_equal("#{WORKDIR}/a/", results[2])
  end

  def test_info4
    FileUtils.mkdir_p "#{WORKDIR}/a/"
    FileUtils.touch "#{WORKDIR}/a/b"
    FileUtils.mkdir_p "#{WORKDIR}/c/"
    FileUtils.touch "#{WORKDIR}/c/d"
    @g00.throw(paths: ["#{WORKDIR}/a", "#{WORKDIR}/c"],
               time: Time.new(2017, 1, 23, 12, 34, 56),
               verbose: false)
    #size is dependent on system
    results = @g00.info("20170123-123456")
    assert_equal('20170123-123456', results[1])
    assert_equal("#{WORKDIR}/a/ ...", results[2])
  end

  def test_info5
    FileUtils.mkdir_p "#{WORKDIR}/a/b"
    @g00.throw(paths: ["#{WORKDIR}/a", "#{WORKDIR}/c"],
               time: Time.new(2017, 1, 23, 12, 34, 56),
               verbose: false)
    FileUtils.mkdir_p "#{WORKDIR}/a/b"
    results = @g00.info("20170123-123456")
    #pp results
    assert_equal('20170123-123456', results[1])
    assert_equal("#{WORKDIR}/a/b (exist in original path)", results[2])
  end

  def test_graft
    FileUtils.rm_rf(  'test/tmp/graft')
    FileUtils.mkdir_p('test/tmp/graft/src/a/b/c')
    FileUtils.mkdir_p('test/tmp/graft/dst/a/b/c')
    FileUtils.touch(  'test/tmp/graft/src/a/b/c/d.txt')
    #
    @g00.graft('test/tmp/graft/src',
               'a',
               dst_root: "test/tmp/graft/dst",
               verbose: false)
    assert(FileTest.directory?('test/tmp/graft/dst/a/b/c/'))
    assert(FileTest.file?('test/tmp/graft/dst/a/b/c/d.txt'))
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

  def test_path2id
    assert_equal("20170123-123456", @g00.path2id("#{TRASHDIR}/20170123-123456"))
    assert_equal("20170123-123456", @g00.path2id("20170123-123456"))
  end

end

