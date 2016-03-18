#! /usr/bin/env ruby
# coding: utf-8

#
#
#
class Gomibako
  DEFAULT_TRASH_DIR = ENV['HOME'] + "/.trash"

  #
  def initialize(trashdir = DEFAULT_TRASH_DIR)
    @trashdir = trashdir
  end

  def throw(paths)
    pwd = ENV['PWD']
    time_str = Date.now.strtime('%Y%m%x-%H%M%S')

    renamer = FileRenamer::Commander.new({no: true}, paths)

    renamer.execute do |path|
      new_name = "#{@trashdir}/#{time_str}/#{path}"
      new_name
    end
  end

  def show
    dirs = Dir.glob(@trashdir).sort
    dirs.each_with_index do |dir, i|
      printf("%02d : %s\n", i, dir )
    end
  end

  def recover(index)
    tgt_dir = Dir.glob(@trashdir).sort[index]
    Dir.glob(tgt_dir).each do |file|
    end


    dir.sub(@trashdir, ふっきぽいんと) path)
    


  end

end


