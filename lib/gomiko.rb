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

  #class NotFoundError < StandardError; end 

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

  # If paths includes exist and not exist files,
  # throw all exist file and report not exist files.
  def throw(paths: , time: Time.new, verbose: true)
    #pp paths
    trash_subdir = mkdir_time(time)
    paths.each do |path|
      unless FileTest.exist? path
        if verbose
          puts "gomiko rm: cannot remove '#{path}': No such file or directory"
        end
        next
      end

      dst = trash_subdir + File.expand_path(path)
      dst_dir = File.dirname dst
      FileUtils.mkdir_p(dst_dir)
      FileUtils.mv(path, dst_dir + '/', :verbose => verbose)
    end
  end

  #def empty(dirs: [], before: 0, time: Time.now, verbose: true)
  def empty(before: 0, time: Time.now, verbose: true)
    dirs = []
    dirs += Dir.glob("#{@trashdir}/*").select do |path|
      time -  File.mtime(path) > 86400 * before
    end
    dirs.each {|path| FileUtils.rm_rf(path, :verbose => verbose)}
  end

  #def latest

  def undo(dst_dir, verbose: true, io: $stdout)
    #pp dst_dir; return
    fullpath = Pathname.new(@trashdir) + dst_dir

    Dir.glob("#{fullpath}/*").sort.each do |path|
      graft(fullpath, '', dst_root: '/', verbose: verbose)
    end

    if Dir.glob("#{fullpath}/**/*").find {|path| FileTest.file? path}
      io.puts "Unable to complete undo: #{fullpath}"
    else
      FileUtils.rm_rf fullpath # risky?
    end
  end

  # Example of return data:
  #236K 20170623-021233/home/ippei/private/ero/inbox/20170623-015917 ...
  def info(id)
    path = Pathname.new(@trashdir) + id
    results = []
    results << `du --human-readable --max-depth=0 #{path}`.split(' ')[0] # size
    results << id

    paths = Dir.glob("#{path}/**/*", File::FNM_DOTMATCH).sort
    #pp paths
    addition = ''
    older_files = paths.select do |subpath|
      fullpath = subpath.sub(/^#{path}/, '')
      if FileTest.exist?(fullpath)
        flag = FileTest.file? fullpath
        addition = '(may exist newer file)' if flag
      else
        flag = true
      end
      flag
    end

    older_files.map! {|v| v.sub(/^#{@trashdir}\/#{id}/, '')}
    unless older_files.empty?
      results << older_files[0]
      results[-1] += ' ...' if older_files.size > 1
      results[-1] += addition
    end
    results
  end

  # ls, list
  def list
    Dir.glob("#{@trashdir}/*").map do |path|
      path.sub(/^#{@trashdir}\//, '').split[0]
    end . sort
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

