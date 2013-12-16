module Lynr; class Queue;

  class JobResult

    attr_reader :message

    def initialize(message = nil, succeeded = true, requeue = :requeue)
      @message = message
      @succeeded = succeeded
      @requeue = requeue
    end

    def and(result)
      return self unless result.is_a? JobResult
      msg = [self.message, result.message].delete_if { |m| m.nil? || m.empty? }
      requeue = if self.success? then result.requeue? else self.requeue? end
      JobResult.new(msg.first, self.success? && result.success?, requeue)
    end

    def requeue?
      !self.success? && (@requeue === true || @requeue === :requeue)
    end

    def info
      if @succeeded then 'Success' else "Failure message='#{@message}'" end
    end

    def success?
      @succeeded
    end

    def then(&block)
      result = block.call if self.success? && block_given?
      # result will be `nil` if this `JobResult` hasn't succeeded or a block wasn't given
      result || self
    end

    def to_s
      "#<#{self.class.name}:#{object_id} #{info}>"
    end

  end

end; end;
