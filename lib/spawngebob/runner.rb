module Spawngebob
  class Runner
    def self.boot(args)
      self.new(args)
    end

    def initialize(args)
      @options[:verbose] = false

      optparse = OptionParser.new do |opts|
        opts.banner = "Spawngebob and Patrick!"
        opts.separator "Options:"

        opts.on('-v', '--verbose', 'Verbose') do
          @options[:verbose] = true
        end

        opts.on('-V', '--version', 'Version') do
          puts Popo::VERSION
          exit
        end

        opts.on('-h', '--help', 'Display this screen') do
          puts opts
          exit
        end
      end

      optparse.parse!

      if args.length == 0
        Utils.say optparse.help
      else
        self.run(args)
      end
    end

    def run(args)
      case args.shift
      when
      else
        puts "I don't know what to do."
      end
    end
  end
end
