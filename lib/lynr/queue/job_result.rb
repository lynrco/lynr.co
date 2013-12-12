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

    def as_str
      if @succeeded then 'Success' else "Failure message=#{@message}" end
    end

    def success?
      @succeeded
    end

    def to_s
      "#<#{self.class.name}:#{object_id} #{as_str}>"
    end

  end

end; end;
