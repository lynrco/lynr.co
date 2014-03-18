require 'kramdown'

require './lib/lynr'
require './lib/lynr/queue/email_job'

module Lynr

  class Queue::MarkdownEmailJob < Queue::EmailJob

    def initialize(data={})
      super('none', data)
    end

    protected

    def html_result
      document = Kramdown::Document.new(text_result)
      document.to_html
    end

    def text_result
      tmpl(@template, :md).result
    end

  end

end
