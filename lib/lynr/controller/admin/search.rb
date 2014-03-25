require 'bson'
require 'cgi'

require './lib/lynr/controller/admin'
require './lib/lynr/elasticsearch'

module Lynr::Controller

  # # `Lynr::Controller::Admin::Search`
  #
  # Controller to handle vehicle searches within the context of the
  # admin pages. Searches performed from this controller are restricted
  # to vehicles owned by the currently viewed dealership.
  #
  class Admin::Search < Lynr::Controller::Admin

    get  '/admin/:slug/search', :get

    # ## `Admin::Search.new`
    #
    # Setup the subsection name for the search results page.
    #
    def initialize
      super
      @subsection = 'vehicle-list vehicle-search'
    end

    # ## `Admin::Search#before_POST(req)`
    #
    # Setup the page title based on the string being searched for.
    #
    def before_GET(req)
      super
      @term = term(req)
      @title = "Search for #{term(req)}"
    end

    # ## `Admin::Search#get`
    #
    # Handle the GET requests for searching by pulling out the query and
    # passing it along to the get results from the search provider.
    #
    def get(req)
      results = search(dealership(req), term(req))
      data = results['hits']
      count = data['total']
      documents = data['hits']
      req.session['back_uri'] = "/admin/#{@dealership.slug}/search?q=#{term(req)}"
      @vehicles = documents.map do |doc|
        vehicle_dao.get(BSON::ObjectId.from_string(doc['_id']))
      end
      render 'admin/search_results.erb'
    end

    # ## `Admin::Search#search(dealership, query)`
    #
    # Perform the search and return data from search as a `Hash`. Search
    # is filtered by `dealership` (specifically `dealerhsip.id`) and
    # `query` is the term to be searched for. Documents returned will also
    # have been filtered by their lack of a `deleted_at` date.
    #
    def search(dealership, query)
      search = Lynr::Elasticsearch.new
      search.vehicles({
        filtered: {
          query: { match: { "_all" => query } },
          filter: {
            and: [
              { term: { "Lynr::Model::Vehicle.dealership" => dealership.id.to_s } },
              { missing: { field: "Lynr::Model::Vehicle.deleted_at", null_value: true, } },
            ],
          }
        }
      })
    end

    # ## `Admin::Search#term(req)`
    #
    # Extract the query term out of `req` and HTML encode it. Encoding
    # it makes it safe for display in HTML source of the page and safe
    # to pass along as part of a search query.
    #
    def term(req)
      CGI.escapeHTML(req.params['q'])
    end

  end

end
