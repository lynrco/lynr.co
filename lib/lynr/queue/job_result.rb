module Lynr; class Queue;

  class JobResult

    attr_reader :message

    def initialize(message = "", succeeded = true, requeue = :requeue)
      @message = message
      @succeeded = succeeded
      @requeue = requeue
    end

    def requeue?
      @requeue === true || @requeue === :requeue
    end

    def success?
      @succeeded
    end

    def to_s
      result = if @succeeded
        'Success'
      else
        "Failure message=#{@message}"
      end
      "#<#{self.class.name}:#{object_id} #{result}>"
    end

  end

end; end;
