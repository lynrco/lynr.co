require 'lynr/logging'
require 'lynr/worker/job_result'

module Lynr; class Worker;

  class Job

    include Lynr::Logging

    Success = JobResult.new

    def perform
      Success
    end

    protected

    def failure(message)
      JobResult.new(message, false)
    end

    def success
      JobResult.new
    end

  end

end; end;
