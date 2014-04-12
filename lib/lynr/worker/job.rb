require './lib/lynr/worker'

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

    # ## `Worker::Job#process(job)`
    #
    # Perform the `job` provided by the `#consumer` while subscribed. This
    # method is the one that makes the action happen. If `perform` returns
    # a successful result send an `ack` message to the queue, otherwise
    # send a nack with the option to requeue based on the result.
    #
    def process(job)
      result = job.perform
      log.info("#{queue_info} #{job.info} job.result=#{result.info}")
      if result.success?
        consumer.ack(job.delivery_info.delivery_tag)
      else
        consumer.nack(job.delivery_info.delivery_tag, result.requeue?)
      end
    end

  end

end
