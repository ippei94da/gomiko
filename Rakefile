# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://guides.rubygems.org/specification-reference/ for more options
  gem.name = "gomiko"
  gem.homepage = "http://github.com/ippei94da/gomiko"
  #gem.homepage = "http://www.q-eng.imat.eng.osaka-cu.ac.jp/~ippei/html/gomiko/index.html"

  gem.license = "MIT"
  gem.summary = %Q{Trashbox with command line interface}
  gem.description = %Q{
    This Gem provides functionality similar to the Trash box in Windows OS.
    The name 'gomiko' was originated from Japanese "gomibako".
    If you think that it is "a shrine maiden(miko-san) who plays go", is it cute?
    Gomiko provides the gomiko command;
    it moves the file to ~/.trash with a change of rm.
    And the command also can display the history of deletion and can execute undo.
    Gomiko provides the Gomiko library.
    It is designed so that the trash box can be handled from the Ruby program as well.
   }
  #この Gem は Windows のゴミ箱のような機能を提供します。
  #gomiko という名前は日本語の「gomibako」を元につけられました。
  #「碁を打つ巫女さん」だと思えば可愛いでしょ？
  #gomiko は gomiko コマンドを提供します。
  #gomiko コマンドは rm の変わりに ~/.trash にファイルを移動します。
  #また削除履歴の表示や undo が備えられています。
  #gomiko は、 Gomiko ライブラリを提供します。
  #ゴミ箱が Ruby プログラム上からも扱えるように設計してあります。
  gem.email = "ippei94da@gmail.com"
  gem.authors = ["ippei94da"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

desc "Code coverage detail"
task :simplecov do
  ENV['COVERAGE'] = "true"
  Rake::Task['test'].execute
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "gomiko #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
