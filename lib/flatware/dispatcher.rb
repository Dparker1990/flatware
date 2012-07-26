module Flatware
  class Dispatcher
    DISPATCH_PORT = 'ipc://dispatch'

    def self.start(jobs=Cucumber.jobs)
      new(jobs).dispatch!
    end

    def initialize(jobs)
      @jobs = jobs
    end

    def dispatch!
      return Flatware.close if jobs.empty?
      fireable.until_fired dispatch do |request|
        job = jobs.pop || 'seppuku'
        dispatch.send Marshal.dump job
      end
    end

    private

    attr_reader :jobs

    def fireable
      @fireable ||= Fireable.new
    end

    def dispatch
      @dispatch ||= Flatware.socket(ZMQ::REP).tap do |socket|
        socket.bind DISPATCH_PORT
      end
    end
  end
end
