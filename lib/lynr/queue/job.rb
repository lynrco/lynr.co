require './lib/lynr/logging'
require './lib/lynr/queue/job_result'

module Lynr; class Queue;

  class Job

    include Lynr::Logging

    Success = JobResult.new

    attr_reader :delivery_info, :metadata, :payload

    def delivery(delivery_info, metadata, payload)
      @delivery_info = delivery_info
      @metadata = metadata
      @payload = payload
      self
    end

    def delivered?
      !(@delivery_info.nil? || @metadata.nil?)
    end

    def info
      "job.type=#{self.class.name} job.id=#{self.delivery_info.delivery_tag}"
    end

    def perform
      Success
    end

    protected

    def failure(message, requeue = :requeue)
      JobResult.new(message, false, requeue == :requeue)
    end

    def success
      JobResult.new
    end

  end

end; end;
