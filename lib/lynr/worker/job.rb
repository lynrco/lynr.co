require './lib/lynr/worker'
require './lib/lynr/queue/job_result'

module Lynr

  # # `Lynr::Worker::Job`
  #
  # Process `Lynr::Queue::Job` instances produced to a
  # `Lynr::Queue::JobQueue`.
  #
  class Worker::Job < Lynr::Worker

    # ## `Worker::Job#consumer`
    #
    # Defines the type of `Lynr::Queue::JobQue` to for which this `Worker`
    # consumes messages.
    #
    def consumer
      @consumer ||= Lynr::Queue::JobQueue.new(queue_name, config.amqp.consumer)
    end

    # ## `Worker::Job#perform(job)`
    #
    # Internal: Invoke `job.perform` and return the `JobResult` it
    # returns. If `job.perform` raises a `StandardError` then wrap the
    # error in a failed `JobResult` instance, marked to not requeue.
    #
    # Returns a `JobResult` instance with message attributes depending
    # on the result of `job.perform`.
    #
    def perform(job)
      job.perform
    rescue StandardError => err
      JobResult.new(err.to_s, succeeded=false, :norequeue)
    end

    # ## `Worker::Job#process(job)`
    #
    # Pass `job`s from `#consumer` to `#perform` while subscribed. This
    # method is the one that makes the action happen. If `#perform` returns
    # a successful result send an `ack` message to the queue, otherwise
    # send a `nack` with the option to requeue based on the result.
    #
    # Return value is unspecified.
    #
    def process(job)
      result = perform(job)
      log.info("#{queue_info} #{job.info} job.result=#{result.info}")
      if result.success?
        consumer.ack(job.delivery_info.delivery_tag)
      else
        consumer.nack(job.delivery_info.delivery_tag, result.requeue?)
      end
    end

  end

end
