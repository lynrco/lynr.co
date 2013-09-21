require 'lynr/worker/job'

module Lynr; class Queue;

  class JobQueue < Lynr::Queue

    def publish(job, opts = {})
      raise ArgumentError.new("Must be given a `Lynr::Worker::Job` subclass") if !job.is_a? Lynr::Worker::Job
      opts[:content_type] = 'application/yaml' if !opts.include? :content_type
      super(serialize(job), opts)
    end

    def reject(delivery_info, metadata, payload)
      log.warn("Unknown message type: #{metadata.content_type} -- #{payload}")
      super(delivery_info.delivery_tag)
    end

    def subscribe(opts = {})
      queue(@name).subscribe(@subscribe_opts.merge(opts)) do |delivery_info, metadata, payload|
        job = deserialize(metadata, payload)
        return reject(delivery_info, metadata, payload) if job.nil?
        result = job.perform
        if result.success?
          ack(delivery_info.delivery_tag)
        else
          nack(delivery_info.delivery_tag)
        end
      end
      self
    end

    private

    def content_type
      'application/yaml'
    end

    def deserialize(metadata, payload)
      return nil if metadata.content_type != content_type
      job = YAML::load(payload)
      return nil if !job.is_a? Lynr::Worker::Job
      job
    end

    def serialize(job)
      return job if job.is_a? String
      YAML.dump(job)
    end

  end

end; end;
