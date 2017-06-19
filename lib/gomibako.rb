#! /usr/bin/env ruby
# coding: utf-8

require 'fileutils'
require 'pathname'

#
#
#
class Gomibako

  def initialize(dir: nil, root_dir: '/', verbose: true)
    if dir
      @trashdir = dir
    else
      if ENV['UID'] == 0 # this is needed for 'su -m'
        @trashdir ='/root/.trash' 
      else
        @trashdir = ENV['HOME'] + "/.trash"
      end
    end
    FileUtils.mkdir_p(@trashdir, :verbose => verbose)
    @root_dir = root_dir
  end

  #def throw(paths: , time: Time.new, dry_run: false)
  def throw(paths: , time: Time.new, verbose: true)
    trash_subdir = @trashdir + time.strftime('/%Y%m%d-%H%M%S')
    FileUtils.mkdir_p(trash_subdir, :verbose => verbose)
    paths.each do |path|
      dst = trash_subdir + File.expand_path(path)
      dst_dir = File.dirname dst
      FileUtils.mkdir_p(dst_dir, :verbose => verbose)
      FileUtils.mv(path, dst_dir + '/', :verbose => verbose)
    end
  end

  #def empty(dry_run: false)
  def empty(verbose: true)
    Dir.glob("#{@trashdir}/*").each do |path|
      FileUtils.rm_rf(path, :verbose => verbose)
    end
  end

  def undo(verbose: true)
    tgt_dir = Dir.glob("#{@trashdir}/*").sort_by { |path| File.ctime path }[-1]
    Dir.glob("#{tgt_dir}/*").sort.each do |path|
      rel_path = path.sub(tgt_dir, '')
      graft(@root_dir + tgt_dir, '/')
      #rsync は良いアイデアだが、パーミッションがないところをルートにしてマージできない。
    end
    puts "rm -rf #{tgt_dir}"

    #最後が空ディレクトリのとき
    #既にファイルがあるとき
    #残骸を rmdir -p
  end

  #unless [ -d $trashdir ]; then
  #  /bin/rm $@
  #fi
  #unset trashdir dstdir

  #alias cleartrash="/bin/rm -rf ~/.trash/*"

#  def show
#    dirs = Dir.glob(@trashdir).sort
#    dirs.each_with_index do |dir, i|
#      printf("%02d : %s\n", i, dir )
#    end
#  end

  #private

  # e.g., root_path = ~/.trash/20170123-012345
  #       path      = home/ippei/foo
  def graft(src_root, path)
    src_root = Pathname.new(src_root)
    path     = Pathname.new(path)
    tgt_path = Pathname.new('/') + path

    if FileTest.directory? (tgt_path)
      Dir.glob("#{tgt_path}/*") do |subdir|
        next_path = src_root + subdir
        graft(src_root, subdir)
      end
    elsif FileTest.exist? (tgt_path)
      puts "normal file already exist: #{tgt_path}"
    else
      FileUtils.mv(src_root + path, tgt_path, :noop => true, :verbose => true )
    end
    return
  end

end

