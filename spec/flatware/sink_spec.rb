require 'spec_helper'

describe Flatware::Sink do
  let(:job) { double 'job', id: 'int.feature' }
  let(:sink) { described_class.start_server [job], StringIO.new }
  context 'when I have work to do, but am interupted' do
    let! :pid do
      fork { sink }
    end

    it 'exits' do
      wait_until { child_pids.include? pid }
      Process.kill 'INT', pid
      Process.wait pid
      child_pids.should_not include pid
    end
  end

  context "When I'm all done" do
    let(:socket) { double 'socket', bind: nil, recv: nil, seppuku: nil }
    before do
      Flatware::Checkpoint.stub(:===) do |result|
        result == checkpoint
      end
      Flatware::Job.stub(:===) do |result|
        result == job
      end

      Flatware.verbose = true
      Flatware.stub socket: socket
      Marshal.stub(:load).and_return checkpoint, job
    end
    # subject { described_class.new [job], StringIO.new, StringIO.new }
    let(:checkpoint) { double 'checkpoint', steps: [], scenarios: [], passed?: passed? }
    subject { sink }

    context "and a test failed" do
      let(:passed?) { false }
      its(:all_passed?) { should be_false }
    end

    context "and all tests passed" do
      let(:passed?) { true }
      its(:all_passed?) { should be_true }
    end
  end
end
