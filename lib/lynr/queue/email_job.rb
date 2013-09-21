require 'rest-client'
require 'sly/view/erb'

require 'lynr'
require 'lynr/queue/job'

module Lynr; class Queue;

  class EmailJob < Job

    def initialize(template, data = {})
      raise ArgumentError.new("`:to` data is required") if !data.include? :to
      raise ArgumentError.new("`:subject` data is required") if !data.include? :subject
      @template = template
      @mail_data = data
      @text_template = tmpl(template, :txt)
      @html_template = tmpl(template, :html)
      @config = Lynr.config('app').mailgun
      data[:from] = @config.from if !data.include? :from
    end

    def perform
      data = {
        text: @text_template.result,
        html: @html_template.result
      }.merge(@mail_data)
      url = "https://api:#{@config['key']}@#{@config['url']}/#{@config['domain']}/messages"
      RestClient.post url, data
      Success
    rescue RestClient::Exception => rce
      log.warn("Post to #{url} with #{data} failed... #{rce.to_s}")
      failure("Post to #{url} failed. #{rce.to_s}")
    end

    def to_s
      "#<#{self.class.name}:#{object_id} to=#{@mail_data[:to]}, template=#{@template}>"
    end

    private

    def tmpl(template, type)
      path = ::File.join(Lynr.root, 'views/email', "#{template}.#{type.to_s}")
      Sly::View::Erb.new(path, data: @mail_data)
    end

  end

end; end;
