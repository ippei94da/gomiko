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

  #def empty(before: 0, time: Time.now, verbose: true)
  def empty(dirs: [], before: 0, time: Time.now, verbose: true)
    dirs = []
    dirs += Dir.glob("#{@trashdir}/*").select do |path|
      time -  File.mtime(path) > 86400 * before
    end
    dirs.each {|path| FileUtils.rm_rf(path, :verbose => verbose)}
  end

  #def latest

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
  #236K 20170623-021233/home/ippei/private/ero/inbox/20170623-015917 ...
  #def info(id, long: false)
  def info(id)
    id = path2id id
    cur_trash_dir = Pathname.new(@trashdir) + id
    results = []
    results << `du --human-readable --max-depth=0 #{cur_trash_dir}`.split(' ')[0]
    results << id

    # 元のパスにファイルが存在しないものを抽出。
    trash_paths = Dir.glob("#{cur_trash_dir}/**/*", File::FNM_DOTMATCH).sort

    # '/.', で終わるのを除外
    trash_paths = trash_paths.select { |t_path| ! /\/\.$/.match t_path }

    #memo: ディレクトリのタイムスタンプ
    #・atime … 最終アクセス時刻 (access time)
    #・mtime … 最終変更時刻 (modify time)
    #・ctime … 最終ステータス変更時刻 (change time)
    #これらは作成日時じゃない。birthtime があるファイルシステムもあるが、Linux の ext4 とかはムリ。
    # 存在しなければ、移動してきた
    # 存在するならば、
    #   ゴミパスがディレクトリならば、
    #     元パスがディレクトリならば
    #       元パスの更新時刻が新しければ、新たに作られた
    #       元パスの更新時刻が古ければ、削除次に作られたものなので無視
    #     元パスがファイルならば、新たに作られた
    #   ゴミパスがファイルならば、
    #     元パスがディレクトリならば、新たに作られた
    #     元パスがファイルならば新たに作られ、重複。
    #title_long = ['Exist']
    #
    #rm_target_candidates = []
    candidates = [] # fo rm target
    results_long = []
    trash_paths.each do |trash_path|
      #pp trash_path
      orig_path = trash_path.sub(/^#{cur_trash_dir}/, '')

      trash_type = ftype_str(trash_path)

      if FileTest.exist? orig_path
        #exist_str = 'E'
        orig_type = ftype_str(orig_path)
        
        unless File.ftype(trash_path) == File.ftype(orig_path)
          candidates << trash_path
        end

        ## waiting for implementing 'birthtime' on every system...
        #if File.ctime(orig_path) < File.ctime(trash_path)
        #  compare_str = '<'
        #elsif File.ctime(orig_path) > File.ctime(trash_path)
        #  # create after 'rm'
        #  compare_str = '>'
        #  candidates << trash_path
        #else
        #  # create at the same time of 'rm'. rare event.
        #  compare_str = '='
        #  candidates << trash_path
        #end
      else
        candidates << trash_path
        #exist_str   = ' '
        orig_type   = ' '
      end

      #results_long << [ exist_str, orig_type, trash_type,
      results_long << [ trash_type, orig_type,
                        trash_path.sub(/^#{cur_trash_dir}/, '')
      ]
    end

    ## if no candidate, last file is adopted.
    candidates = [trash_paths[-1] + ' (exist in original path)'] if candidates.empty?

    candidates = candidates.map    {|path|
      tmp = path.sub(/^#{cur_trash_dir}/, '')
      tmp += '/' if FileTest.directory? path
      tmp
    }
    candidates = candidates.select {|path| ! FileTest.exist? path }
    results << candidates[0]

    ## output '...' when multiple.
    candidates = candidates.select{|pa| ! pa.include? candidates[0]}
    #pp candidates; exit
    results[-1] += ' ...' unless candidates.empty?
    results << results_long
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
      #pp src_root + path
      #pp dst_path
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

