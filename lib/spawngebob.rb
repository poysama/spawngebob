require 'yaml'
require 'erb'
require 'fileutils'
require 'spawngebob/version'

module Spawngebob

  autoload :CLI, 'spawngebob/cli'
  autoload :Compilers, 'spawngebob/compilers'
  autoload :Constants, 'spawngebob/constants'
  autoload :Runner, 'spawngebob/runner'
  autoload :Utils, 'spawngebob/utils'
end
