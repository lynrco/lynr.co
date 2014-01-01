require './lib/lynr/queue/job_result'

module Lynr; class Queue;

  # # `Lynr::Queue::Job`
  #
  # `Job` represents a unit of work to be performed as soon as possible. It provides a
  # way to represent some task to execute later. A `Job` can be delivered by providing
  # delivery informatin, metadata and a payload. The payload is usually the serialized
  # version of `Job`. Once delivered a `Job` is `#perform`-ed to get the result of
  # executing the work. `Job`s are intended to be serialized and deserialized by the
  # Queue used to process them therefore storing `proc`s or `lambda`s or blocks in
  # a `Job`'s attributes should not be attempted.
  #
  class Job

    # Easy reference to a successful `JobResult`
    Success = JobResult.new

    attr_reader :delivery_info, :metadata, :payload

    # ## `Lynr::Queue::Job#delivery(delivery_info, metadata, payload)`
    #
    # Store the information provided when this `Job` is delivered as a message by
    # the `Queue`.
    #
    def delivery(delivery_info, metadata, payload)
      @delivery_info = delivery_info
      @metadata = metadata
      @payload = payload
      self
    end

    # ## `Lynr::Queue::Job#delivered?`
    #
    # True if `#delivery` was provided delivery information and metadata, false
    # otherwise.
    #
    def delivered?
      !(@delivery_info.nil? || @metadata.nil?)
    end

    # ## `Lynr::Queue::Job#info`
    #
    # Provide String information about this `Job` instance.
    #
    def info
      tag = "job.id=#{self.delivery_info.delivery_tag}" if delivered?
      "job.type=#{self.class.name} #{tag}".chomp(' ')
    end

    # ## `Lynr::Queue::Job#perform`
    #
    # Method called when the work represented by this `Job` instance is to occur.
    # The `#perform` method is meant to be overriden by subclasses of `Job` in order
    # to do something useful. `#perform` must return an instance of `JobResult` to
    # indicate successful or failed completion of the task.
    #
    def perform
      Success
    end

    # ## `Lynr::Queue::Job#to_s`
    #
    # String representation of this `Job`
    #
    def to_s
      "#<#{self.class.name}:#{object_id} #{info}>"
    end

    protected

    # ## `Lynr::Queue::Job#failure(message, requeue)`
    #
    # Convenience method to enable a semantic construction of a faiure `JobResult`
    # within the `Job` subclass. `message` is provided to the `JobResult` constructor
    # while `requeue` is expected to be either `:requeue` or `:norequeue`.
    #
    def failure(message, requeue = :requeue)
      JobResult.new(message, false, requeue == :requeue)
    end

    # ## `Lynr::Queue::Job#success`
    #
    # Convenience method to enable a semantic construction of a success `JobResult`
    # within the `Job` subclass.
    #
    def success
      Success
    end

  end

end; end;
