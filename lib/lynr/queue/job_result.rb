module Lynr; class Queue;

  # # `Lynr::Queue::JobResult`
  #
  # Represents the success or failure of a background `Job`. When `JobResult` is
  # constructed with no arguments it is a successful result. `JobResult` can be used
  # as a rudimentary promise object by using the `#and` or `#then` methods. `#and`
  # allows two `JobResult` instances to be combined. `#then` allows a `JobResult` to
  # be combined with a block.
  #
  class JobResult

    attr_reader :message

    # ## `Lynr::Queue::JobResult.new(message, succeeded, requeue)`
    #
    # Create a new `JobResult` with the given `message`. `succeeded` must be true
    # if the `JobResult` is meant to indicate success. `requeue` must be either
    # `true` or `:requeue` in order to represent a the `Job` should be requeued.
    #
    def initialize(message = nil, succeeded = true, requeue = :requeue)
      @message = message
      @succeeded = succeeded
      @requeue = requeue
    end

    # ## `Lynr::Queue::JobResult#and(result)`
    #
    # Enable the current `JobResult` to be combined with another one to form a new
    # `JobResult` such that:
    #
    # 1. `message` is the first non-nil, non-empty messabe in `[self.message, result.message]`
    # 2. `succeeded` is the result of `#success?` anded for both `self` and `result`
    # 3. `requeue` is the `#requeue?` value of `self` if `self` succeeded, and the `#requeue?`
    #     value of `result` otherwise.
    #
    def and(result)
      return self unless result.is_a? JobResult
      msg = [self.message, result.message].delete_if { |m| m.nil? || m.empty? }
      requeue = if self.success? then result.requeue? else self.requeue? end
      JobResult.new(msg.first, self.success? && result.success?, requeue)
    end

    # ## `Lynr::Queue::JobResult#requeue?`
    #
    # `true` if this instance doesn't represent success and `requeue` provided to
    # constructor is `true` or `:requeue`
    #
    def requeue?
      !self.success? && (@requeue === true || @requeue === :requeue)
    end

    # ## `Lynr::Queue::JobResult#info`
    #
    # String information about this `JobResult` instance.
    #
    def info
      if @succeeded then 'Success' else "Failure message='#{@message}'" end
    end

    # ## `Lynr::Queue::JobResult#success?`
    #
    # Value of `succeeded` provided to constructor.
    #
    def success?
      @succeeded
    end

    # ## `Lynr::Queue::JobResult#then(&block)`
    #
    # Executes `block` if this instance succeeded and combines `self` and the result
    # of `block` using `#and`
    #
    def then(&block)
      result = block.call if self.success? && block_given?
      # result will be `nil` if this `JobResult` hasn't succeeded or a block wasn't given
      self.and(result)
    end

    # ## `Lynr::Queue::JobResult#to_s`
    #
    # String representation of this instance.
    #
    def to_s
      "#<#{self.class.name}:#{object_id} #{info}>"
    end

  end

end; end;
