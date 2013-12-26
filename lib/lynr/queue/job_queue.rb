require './lib/lynr/queue'
require './lib/lynr/queue/job'

module Lynr; class Queue;

  class JobQueue < Lynr::Queue

    def initialize(name, uri, opts = {})
      super(name, uri, opts)
    end

    def publish(job, opts = {})
      if !job.is_a? Lynr::Queue::Job
        raise ArgumentError.new("Must be given a `Lynr::Queue::Job` subclass")
      end
      opts[:content_type] = content_type if !opts.include? :content_type
      super(serialize(job), opts)
    end

    def reject(delivery_info, metadata, payload)
      log.warn("Unknown message type: #{metadata.content_type} -- #{payload}")
      super(delivery_info.delivery_tag)
    end

    def subscribe(opts = {})
      raise ArgumentError.new("`subscribe` needs a block") if !block_given?
      queue(@name).subscribe(@subscribe_opts.merge(opts)) do |delivery_info, metadata, payload|
        job = deserialize(delivery_info, metadata, payload)
        return reject(delivery_info, metadata, payload) if job.nil?
        job.delivery(delivery_info, metadata, payload)
        yield job
      end
      self
    end

    private

    def content_type
      'application/binary'
    end

    def deserialize(delivery_info, metadata, payload)
      return nil if metadata.content_type != content_type
      job = Marshal::load(payload)
      return nil if !job.is_a? Lynr::Queue::Job
      job
    end

    def serialize(job)
      return job if job.is_a? String
      Marshal.dump(job)
    end

  end

end; end;
