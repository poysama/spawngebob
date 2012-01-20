require 'yaml'
require 'erb'
require 'fileutils'
require "spawngebob/version"

module Spawngebob
  SPAWNGEBOB_LIB_ROOT = File.join(File.dirname(__FILE__), 'spawngegbob')

  autoload :Runner, (File.join(POPO_LIB_ROOT, 'runner'))
  autoload :Compiler, (File.join(POPO_LIB_ROOT, 'compiler'))
end
