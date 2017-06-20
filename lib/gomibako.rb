#! /usr/bin/env ruby
# coding: utf-8

require 'fileutils'
require 'pathname'
require 'tefil'
require 'find'

#
#
#
class Gomibako

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
        puts "gomibako rm: cannot remove '#{path}': No such file or directory" if verbose
        exit
      end
    end

    trash_subdir = @trashdir + time.strftime('/%Y%m%d-%H%M%S')
    FileUtils.mkdir_p(trash_subdir)
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

    begin
      Dir.glob("#{dst_dir}/*").sort.each do |path|
        #rsync might be an idea.
        #but it has a problem that it cannot merge to thepath without permission.
        graft(dst_dir, '', dst_root: dst_root)
      end
      FileUtils.rm_rf dst_dir # risky?
    rescue
      puts "Cannot undo: #{dst_dir}"
    end
  end

  def ls()
    results = [['size', '[date-time dir]/path[ ...]']]
    Dir.glob("#{@trashdir}/*").sort.each do |path|
      tmp = []
      tmp << `du --human-readable --max-depth=0 #{path}`.split(' ')[0] # size

      not_exist_files = Find.find(path).select do |subpath|
        fullpath = subpath.sub(/^#{path}/, '')
        ! FileTest.exist?(fullpath)
      end
      not_exist_files.shift # path for root dir
      not_exist_files.map! {|v| v.sub(/^#{@trashdir}\//, '')}
      tmp << not_exist_files[0]
      tmp[-1] += ' ...' if not_exist_files.size > 2

      results << tmp
    end
    Tefil::ColumnFormer.new.form(results)
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

end

