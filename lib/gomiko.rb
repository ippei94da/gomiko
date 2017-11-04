#! /usr/bin/env ruby
# coding: utf-8

require 'fileutils'
require 'pathname'
require 'tefil'
require 'find'
require 'yaml'

#
#
#
class Gomiko

  attr_reader :trashdir

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
  def throw(paths: , time: Time.new, verbose: true, io: $stdout)
    paths = paths.select do |path|
      flag = FileTest.symlink?(path) || FileTest.exist?(path) # for deadlink
      unless flag
        if verbose
          io.puts "gomiko rm: cannot remove '#{path}': No such file or directory"
        end
      end
      flag
    end
    return if paths.empty?

    trash_subdir = mkdir_time(time)
    File.open(trash_subdir + ".yaml", "w") do |yaml_io|
      YAML.dump( { 'pwd' => ENV["PWD"], 'paths' => paths }, yaml_io)
    end

    paths.each do |path|
      dst = trash_subdir + File.expand_path(path)
      dst_dir = File.dirname dst
      FileUtils.mkdir_p(dst_dir)
      if path == '.'
        io.puts "gomiko rm: failed to remove '.': Invalid argument" if verbose
        next
      else
        FileUtils.mv(path, dst_dir + '/')
        io.puts "mv #{path} #{dst_dir}" if verbose
        File.utime(time, time, trash_subdir)
      end
    end
  end

  def empty(ids: [], mtime: 0, time: Time.now, verbose: true, io: $stdout)
    if ids.empty?
      tgts = (dir_list + yaml_list.map{|v| v.sub(".yaml", "")}).sort.uniq
    else
      tgts = ids.map {|v|  path2id(v)}
    end
    #pp tgts; exit
    tgts = tgts.select { |v|
      begin
        str2datetime(v) - time < 86400 * mtime
      rescue Errno::ENOENT
        io.puts "Not found: #{v}"
      end
    }
    tgts.map! {|v|  @trashdir + '/' + v}
    if tgts.empty?
      io.puts "No directory was emptied."
    else
      tgts.each do |path|
        ["", ".yaml"].each do |ext|
          new_path = path + ext
          FileUtils.rm_rf(new_path, :verbose => verbose) if File.exist? new_path
        end
      end
    end
  end

  def undo(id, verbose: true, io: $stdout)
    id = path2id id
    fullpath = Pathname.new(@trashdir) + id
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
  # [
  #   236K,
  #   20170623-021233,
  #   [/home/ippei/tmp/a.txt, /home/ippei/tmp/b.txt ]
  # ]
  def info(id)
    id = path2id id
    cur_trash_dir = Pathname.new(@trashdir) + id
    results = []
    results << `du --human-readable --max-depth=0 #{cur_trash_dir}`.split(' ')[0]
    results << id

    trash_paths = Dir.glob("#{cur_trash_dir}/**/*", File::FNM_DOTMATCH).sort
    trash_paths = trash_paths.select { |t_path| ! /\/\.$/.match t_path } # '/.', で終わるのを除外

    candidates = [] # fo rm target
    results_long = []
    additions = []
    #flag_conflict = false
    flag_include_file = false
    trash_paths.each do |trash_path|
      orig_path = trash_path.sub(/^#{cur_trash_dir}/, '')
      trash_type = ftype_str(trash_path)
      flag_include_file = true unless File.directory? trash_path
      if FileTest.exist? orig_path
        orig_type = ftype_str(orig_path)
        if File.ftype(trash_path) != File.ftype(orig_path)
          #flag_conflict = true
          additions << 'conflict'
          candidates << trash_path
        end
      else
        candidates << trash_path
        orig_type   = ' '
      end
      results_long << [ trash_type, orig_type,
                        trash_path.sub(/^#{cur_trash_dir}/, '') ]
    end
    unless flag_include_file
      additions << 'only directory'
      candidates << trash_paths[-1]
    end

    results <<  YAML.load_file(cur_trash_dir.to_s + ".yaml")['paths'][0]
    ## if no candidate, last file is adopted.
    if trash_paths.empty?
      #results << '(empty)'
      results << []
    else
      additions << 'conflict' if candidates.empty?
      #candidates = candidates.map    {|path|
      #  tmp = path.sub(/^#{cur_trash_dir}/, '')
      #  tmp += '/' if FileTest.directory? path
      #  tmp
      #}
      #results << candidates[0]

      ## output '...' when multiple.
      candidates = candidates.select{|pa| ! pa.include? candidates[0]}
      results[-1] += ' ...' unless candidates.empty?
      #results[2] += ' (conflict)' if flag_conflict
      results[2] += ' (' + additions.join(',') + ')' unless additions.empty?
      results << results_long
    end
    results
  end

  # ls, yaml_list
  # return stocked yaml.
  def yaml_list
    Dir.glob("#{@trashdir}/*.yaml").map { |path|
      path.sub(/^#{@trashdir}\//, '').split[0]
    } . sort
  end

  # ls, dir_list
  # return stocked directories.
  def dir_list
    Dir.glob("#{@trashdir}/*").select { |path|
      FileTest.directory? path
    } .map { |path|
      path.sub(/^#{@trashdir}\//, '').split[0]
    } . sort
  end

  private

  def str2datetime(str)
    /(\d{4})(\d{2})(\d{2})-(\d{2})(\d{2})(\d{2})/ =~ str
    Time.new( $1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i)
  end

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
        FileUtils.mkdir(try_name)
        dirname = try_name
      rescue Errno::EEXIST
        i += 1
        next
      end
    end
    dirname
  end

  def ftype_str(path)
    if File.directory? path
      result = '/'
    elsif File.symlink? path
      result = '@'
    elsif File.file? path
      result = '.'
    else
      result = '?'
    end
    result
  end

  def path2id(path)
    path.sub(/^#{@trashdir}\//, '')
  end

end

