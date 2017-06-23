#! /usr/bin/env ruby
# coding: utf-8

require 'fileutils'
require 'pathname'
require 'tefil'
require 'find'

#
#
#
class Gomiko

  def initialize(dir: nil, verbose: true)
    if dir
      @trashdir = dir
    else
      if ENV['UID'] == 0 # this is needed for 'su -m'
        @trashdir ='/root/.trash' 
      else
        @trashdir = ENV['HOME'] + "/.trash"
      end
    end
    FileUtils.mkdir_p(@trashdir)
  end

  def throw(paths: , time: Time.new, verbose: true)
    paths.each do |path|
      unless FileTest.exist? path
        puts "gomiko rm: cannot remove '#{path}': No such file or directory" if verbose
        exit
      end
    end

    trash_subdir = mkdir_time(time)
    paths.each do |path|
      dst = trash_subdir + File.expand_path(path)
      dst_dir = File.dirname dst
      FileUtils.mkdir_p(dst_dir)
      
      FileUtils.mv(path, dst_dir + '/', :verbose => verbose)
    end
  end

  def empty(before: 0, time: Time.now, verbose: true)
    Dir.glob("#{@trashdir}/*").each do |path|
      if time -  File.mtime(path) > 86400 * before
        FileUtils.rm_rf(path, :verbose => verbose)
      end
    end
  end

  def undo(verbose: true, dst_root: '/')
    if Dir.glob("#{@trashdir}/*").empty?
      puts "Nothing to undo in #{@trashdir}"
      exit
    end
    dst_dir = Dir.glob("#{@trashdir}/*").sort_by { |path| File.ctime path }[-1]

    Dir.glob("#{dst_dir}/*").sort.each do |path|
      #rsync seems to be an good idea.
      #but it has a problem that it cannot merge to thepath without permission.
      graft(dst_dir, '', dst_root: dst_root)
    end

    if Dir.glob("#{dst_dir}/**/*").find {|path| FileTest.file? path}
      puts "Cannot undo: #{dst_dir}"
    else
      FileUtils.rm_rf dst_dir # risky?
    end
  end

  # ls, list
  def ls(io: $stdout)
    results = [['size', 'date-time-id', 'path[ ...]']]
    Dir.glob("#{@trashdir}/*").sort.each do |path|
      tmp = []
      tmp << `du --human-readable --max-depth=0 #{path}`.split(' ')[0] # size

      #pp path
      id = path.sub(/^#{@trashdir}\//, '').split.shift
      tmp << id

      
      last_path = ''
      #not_exist_files = Find.find(path).select do |subpath|
      #  last_path = subpath
      #  fullpath = subpath.sub(/^#{path}/, '')
      #  ! FileTest.exist?(fullpath)
      #end

      info = ''
      paths = Dir.glob("#{path}/**/*")
      older_files = paths.select do |subpath|
        fullpath = subpath.sub(/^#{path}/, '')
        # ctime で比較するのはうまくいかない。
        if FileTest.exist?(fullpath)
          flag = FileTest.file? fullpath
          info = '(may exist newer file)' if flag
        else
          flag = true
        end
        flag
      end

      #pp older_files
      #exit

      older_files.map! {|v| v.sub(/^#{@trashdir}\//, '')}
      tmp << older_files[0].sub(/^#{id}/, '')
      tmp[-1] += ' ...' if older_files.size > 2
      tmp[-1] += info

      results << tmp
    end
    #pp results
    if results.size > 1
      Tefil::ColumnFormer.new.form(results, io)
    else
      io.puts "Nothing in ~/.trash"
    end
  end

  private

  # e.g., root_path = ~/.trash/20170123-012345
  #       path      = home/ippei/foo
  def graft(src_root, path, dst_root: '/', verbose: true)
    src_root = Pathname.new(src_root)
    path     = Pathname.new(path)
    dst_path = Pathname.new(dst_root) + path

    if FileTest.directory? (dst_path)
      Dir.glob("#{src_root + path}/*") do |next_path|
        next_path = Pathname.new(next_path).relative_path_from(src_root)
        graft(src_root, next_path, dst_root: dst_root, verbose: verbose)
      end
    elsif FileTest.exist? (dst_path)
      puts "normal file already exist: #{dst_path}" if verbose
    else
      FileUtils.mv(src_root + path, dst_path, noop: false, verbose: verbose )
    end
    return
  end

  def mkdir_time(time)
    time_str = time.strftime('/%Y%m%d-%H%M%S')
    dirname = nil

    i = 0
    while ! dirname

      begin
        #self.ls
        try_name = @trashdir + "#{time_str}"
        try_name += "-#{i}" if 1 <= i
        #pp try_name
        FileUtils.mkdir(try_name)
        dirname = try_name
      rescue Errno::EEXIST
        i += 1
        next
      end
    end
    dirname
  end


end

