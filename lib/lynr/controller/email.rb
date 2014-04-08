require 'premailer'

require './lib/lynr'
require './lib/lynr/controller/base'

module Lynr::Controller

  # # `Lynr::Controller::Email`
  #
  # Controller to enable previews of HTML emails. Data can be passed to
  # the email templates by passing query parameters to the URL. The path
  # after `/email/` is used as the path to the email template.
  #
  # For example, hitting `/email/email_updated?support_email=butts@cloud.com`
  # would render the email template `views/email/email_updated.html.erb`
  # with `{ support_email: 'butts@cloud.com' }` provided as data to the
  # email template. This solution is not perfect for testing all email
  # templates because it can only pass `String` data as parameters to
  # email templates but it is good enough for most of them.
  #
  class Email < Lynr::Controller::Base

    get  '/email/*', :get

    # ## `Email#before_GET(req)`
    #
    # Return a 404 if there is no email template parameter. Ultimately
    # this should be a 404 if the template doesn't exist either but
    # because this should only be used in development that has not been
    # implemented.
    #
    def before_GET(req)
      super
      return not_found unless template(req)
    end

    # ## `Email#get(req)`
    #
    # Process `req` into a `Rack::Response` by processing the email
    # template the same way `Lynr::Queue::EmailJob` processes emails
    # before sending them out and using the processed markup as the
    # body of the respons.
    #
    def get(req)
      markup = Premailer.new(tmpl(req).result, {
        with_html_string: true,
        css_string: File.read("public/css/email.css")
      }).to_inline_css
      Rack::Response.new(markup)
    end

    # ## `Email#template(req)`
    #
    # Get the template parameter from the request defaulting to nil.
    #
    def template(req)
      req.params.fetch('_tail_', default=nil)
    end

    # ## `Email#tmpl(template, type)`
    #
    # Turn the `#template(req)` result into a `Sly::View::Erb` instance
    # which can be used by `#get(req)` for rendering.
    #
    def tmpl(req)
      type = :html
      template = template(req)
      view_data = {
        base_url: req.base_url,
        support_email: Lynr.config('app').support_email,
      }.merge(req.params)
      path = ::File.join(Lynr.root, 'views/email', "#{template}.#{type.to_s}")
      Sly::View::Erb.new(path, data: view_data)
    end

  end

end
