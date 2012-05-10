require 'benchmark'

module Spawngebob
  module Utils
    include Constants

    def self.say(message, subitem = false)
      puts "#{subitem ? "   ->" : "--"} #{message}"
    end

    def self.say_with_time(message)
      say(message)
      result = nil
      time = Benchmark.measure { result = yield }
      say "%.4fs" % time.real, :subitem
      say("#{result} rows", :subitem) if result.is_a?(Integer)
      result
    end

    def self.error(message, code=-1)
      say("\033[31merror: #{message}")
      exit(code)
    end
  end
end

