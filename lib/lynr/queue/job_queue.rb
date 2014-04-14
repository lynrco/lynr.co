require './lib/lynr/queue'
require './lib/lynr/queue/job'

module Lynr

  # # `Lynr::Queue::JobQueue`
  #
  # Specialized `Queue` to publish and subscribe to messages which represent
  # `Lynr::Queue::Job`s. The `JobQueue` knows how to serliaze and deserialze
  # objects of the type `Job` and so accepts instances of those objects for
  # publishing and performs the processing of them when subscribing. `JobQueue`
  # instances are started by `Lynr::Worker`.
  #
  class Queue::JobQueue < Lynr::Queue

    # ## `JobQueue.new(name, uri, opts)`
    #
    # Create a new instance which connects to a `Queue` with `name` at `uri` and
    # passes along `opts`.
    #
    def initialize(name, uri, opts = {})
      super(name, uri, opts)
    end

    # ## `JobQueue#publish(job, opts)`
    #
    # Publish a new `job` to the message broker after serializing it.
    #
    def publish(job, opts = {})
      if !job.is_a? Lynr::Queue::Job
        raise ArgumentError.new("Must be given a `Lynr::Queue::Job` subclass")
      end
      opts[:content_type] = content_type if !opts.include? :content_type
      super(serialize(job), opts)
    end

    # ## `JobQueue#subscribe(opts, &block)`
    #
    # Subscribe to `Queue` with `opts` by deserializing `Job` data and rejecting
    # delivery if the type is incorrect, otherwise yield the `Job` to `block`.
    # Raises an `ArgumentError` if `block` is not provided.
    #
    def subscribe(opts = {}, &handler)
      if !handler.respond_to?(:call)
        raise ArgumentError.new("`#subscribe`'s handler must respond to `:call`")
      end
      queue(@name).subscribe(@subscribe_opts.merge(opts)) do |delivery_info, metadata, payload|
        job = deserialize(delivery_info, metadata, payload)
        return unknown_type(delivery_info, metadata, payload) if job.nil?
        handler.call(job)
      end
      self
    end

    private

    # ## `JobQueue#content_type`
    #
    # Content type with which to publish messages and to expect delivered
    # messages to have.
    #
    def content_type
      'application/binary'
    end

    # ## `JobQueue#deserialize(delivery_info, metadata, payload)`
    #
    # Reconstitute a serialized `Job` instance and return it. Returns `nil` if
    # `metadata.content_type` and `#content_type` don't match. Returns `nil` if
    # reconstituted object is not of type `Lynr::Queue::Job`.
    #
    def deserialize(delivery_info, metadata, payload)
      return nil if metadata.content_type != content_type
      job = Marshal.load(payload)
      return nil if !job.is_a? Lynr::Queue::Job
      job.delivery(delivery_info, metadata, payload)
    end

    # ## `JobQueue#serialize(job)`
    #
    # Take `job` and convert it into something which can be published to the
    # message broker backing this `Queue` instance.
    #
    def serialize(job)
      return job if job.is_a? String
      Marshal.dump(job)
    end

    # ## `JobQueue#unknown_type(delivery_info, metadata, payload)`
    #
    # Reject a `Job` with `delivery_info` and `metadata` because the
    # `metadata.content_type` didn't match `#content_type`.
    #
    def unknown_type(delivery_info, metadata, payload)
      log.warn("Unknown message type: #{metadata.content_type} -- #{payload}")
      reject(delivery_info.delivery_tag)
    end

  end

end
