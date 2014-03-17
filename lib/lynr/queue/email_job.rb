require 'premailer'
require 'rest-client'

require './lib/sly/view/erb'

require './lib/lynr'
require './lib/lynr/queue/job'

module Lynr; class Queue;

  # # `Lynr::Queue::EmailJob`
  #
  # Background task to send an email. Emails are constructed from a template name
  # combined with txt and html extensions. Templates are located in the views folder
  # and are expected to be ERB files. These ERB files are rendered with data passed
  # to `EmailJob`.
  #
  class EmailJob < Job

    # ## `EmailJob.new(template, data)`
    #
    # Constructs a background task to send an email based on files in the
    # `views/email` folder with the name `template`. `template` can be a path
    # and not simply a template name. The ERB files found based on `template`
    # are rendered in the context of `data`. `data` must include `:to` and
    # `:subject` or errors will be raised. `data` may include `:from`, if it does
    # `:from` will be used as the email address of the sender otherwise the sender
    # address is retrieved from app configuration.
    #
    def initialize(template, data = {})
      raise ArgumentError.new("`:to` data is required") if !data.include? :to
      raise ArgumentError.new("`:subject` data is required") if !data.include? :subject
      @template = template
      @mail_data = data
    end

    def config
      return @config unless @config.nil?
      @config = Lynr.config('app').mailgun
    end

    # ## `EmailJob#perform`
    #
    # Execute the task of sending the email by POSTing a request to Mailgun
    # using credentials found in app configuration. Returns `Success` if no errors
    # are raised in sending, otherwise a failure result is returned.
    #
    def perform
      data = {
        from: @mail_data.fetch(:from, config.from),
        html: html_result,
        text: text_result,
      }.merge(@mail_data)
      url = "https://api:#{config['key']}@#{config['url']}/#{config['domain']}/messages"
      RestClient.post url, data
      Success
    rescue RestClient::Exception => rce
      log.warn("Post to #{url} with #{data} failed... #{rce.to_s}")
      failure("Post to #{url} failed. #{rce.to_s}")
    end

    # ## `EmailJob#to_s`
    #
    # String representation including who the mail is being sent to as well as
    # the name of the template to be used.
    #
    def to_s
      "#<#{self.class.name}:#{object_id} to=#{@mail_data[:to]}, template=#{@template}>"
    end

    private

    def html_result
      Premailer.new(tmpl(@template, :html).result, {
        with_html_string: true,
        css_string: File.read("public/css/email.css")
      }).to_inline_css
    end

    def text_result
      tmpl(@template, :txt).result
    end

    # ## `EmailJob#tmpl(template, type)`
    #
    # *Private* Helper method to render `template` with the given `type`. `type`
    # is expected to be html or txt.
    #
    def tmpl(template, type)
      path = ::File.join(Lynr.root, 'views/email', "#{template}.#{type.to_s}")
      Sly::View::Erb.new(path, data: @mail_data)
    end

  end

end; end;
