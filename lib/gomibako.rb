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
      graft(path, '/')
    end

    最後が空ディレクトリのとき
    既にファイルがあるとき
    残骸を rmdir -p
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

  private

  def graft(path, root_path)
    path = Pathname.new(path)
    root_path = Pathname.new(root_path)





  end

end

