require 'lynr/logging'
require 'lynr/queue/job_result'

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
