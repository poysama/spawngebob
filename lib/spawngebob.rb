require 'yaml'
require 'erb'
require 'fileutils'
require File.join(File.expand_path('../spawngebob/version', __FILE__))

SPAWNGEBOB_LIB_ROOT = File.join(File.dirname(__FILE__), 'spawngebob')

module Spawngebob

  autoload :Runner, (File.join(SPAWNGEBOB_LIB_ROOT, 'runner'))
  autoload :Compilers, (File.join(SPAWNGEBOB_LIB_ROOT, 'compilers'))
  autoload :Spawner, (File.join(SPAWNGEBOB_LIB_ROOT, 'spawner'))
  autoload :Constants, (File.join(SPAWNGEBOB_LIB_ROOT, 'constants'))
  autoload :Utils, (File.join(SPAWNGEBOB_LIB_ROOT, 'utils'))
end
