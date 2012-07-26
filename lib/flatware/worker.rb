require 'benchmark'
module Flatware
  class Worker

    def self.listen!
      new.listen
    end

    def self.spawn(worker_count)
      @pids = worker_count.times.map do |i|
        fork do
          $0 = "flatware worker #{i}"
          ENV['TEST_ENV_NUMBER'] = i.to_s
          listen!
        end
      end
    end

    def self.waitall
      @pids.each { |pid| Process.wait pid, Process::WNOHANG | Process::WUNTRACED }
    end

    def listen
      time = Benchmark.realtime do
        report_for_duty
        while work = task.recv
          job = Marshal.load work
          log 'working!'
          next if job == 'seppuku'
          Cucumber.run job.id, job.args
          Sink.finished job
          report_for_duty
          log 'waiting'
        end
        Flatware.close
      end
      log time
    end

    private

    def log(*args)
      Flatware.log *args
    end

    def task
      @task ||= Flatware.socket(ZMQ::REQ).tap do |task|
        task.connect Dispatcher::DISPATCH_PORT
      end
    end

    def report_for_duty
      task.send 'ready'
    end
  end
end
