require 'bson'

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

    get  '/admin/:slug/search', :post

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
    def before_POST(req)
      super
      @title = "Search for #{req.params['q']}"
    end

    # ## `Admin::Search#get`
    #
    # Handle the GET requests for searching by pulling out the query and
    # passing it along to the get results from the search provider.
    #
    def post(req)
      results = search(dealership(req), req.params['q'])
      data = results['hits']
      count = data['total']
      documents = data['hits']
      req.session['back_uri'] = "/admin/#{@dealership.slug}/search?q=#{req.params['q']}"
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
      es = Lynr::Elasticsearch.new
      Lynr.metrics.time('time.service.elasticsearch.vehicles') do
        es.client.search({
          index: 'vehicles',
          body: {
            query: {
              filtered: {
                query: { match: { "_all" => query } },
                filter: {
                  and: [
                    { term: { "Lynr::Model::Vehicle.dealership" => dealership.id.to_s } },
                    { missing: { field: "Lynr::Model::Vehicle.deleted_at", null_value: true, } },
                  ],
                }
              }
            }
          }
        })
      end
    end

  end

end