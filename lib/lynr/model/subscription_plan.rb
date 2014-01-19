require './lib/lynr/model/base'

module Lynr; module Model;

  # # `Lynr::Model::SubscriptionPlan`
  #
  # Intended to represent a String subscription plan. This way plans could be
  # specified in code or configuration and synced periodically to Stripe. This
  # idea has yet to be realized but `SubscriptionPlan` is an artifact of early
  # brain wanderings in that direction.
  #
  class SubscriptionPlan

    include Base

    attr_reader :id
    attr_reader :amount, :interval, :name, :currency, :trial_period_days

    def initialize(data, id)
      @id = id
      @amount = data[:amount].to_i if !data[:amount].nil?
      @interval = data[:interval] || 'month'
      @name = data[:name]
      @currency = data[:currency] || 'usd'
      @trial_period_days = data[:trial_period_days] || 30
      if (@amount.nil? || @amount <= 0)
        raise ArgumentError.new('`:amount` must be specified as an integer greater than zero')
      end
      if (@name.nil?)
        raise ArgumentError.new('`:name` must be specified')
      end
      if (@id.nil?)
        raise ArgumentError.new('SubscriptionPlan must have an id')
      end
    end

    def view
      {
        id: @id,
        amount: @amount,
        interval: @interval,
        name: @name,
        currency: @currency,
        trial_period_days: @trial_period_days
      }
    end

    def self.inflate(record)
      if (record)
        data = record.dup
        Lynr::Model::SubscriptionPlan.new(data, record[:id])
      else
        nil
      end
    end

  end

end; end;
