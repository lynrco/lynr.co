require './lib/lynr/controller'

module Lynr::Controller

  # # `Lynr::Controller::Paginated`
  #
  # Define methods to compute an array of page numbers to display.
  #
  module Paginated

    # ## `Paginated::PER_PAGE`
    #
    # Number of items displayed per page.
    #
    PER_PAGE = 10
    # ## `Paginated::SPREAD`
    #
    # The spread of page numbers to display in the style of
    # `current page`-SPREAD..`current page`+SPREAD as long as the
    # computed page numbers do not exceed the minimum page (1) and
    # maximum page (#last_page).
    #
    SPREAD   =  2

    # ## `Paginated#last_page(count)`
    #
    # Compute the maximum page number which could be meaningfully
    # displayed.
    #
    def last_page(count)
      (count / PER_PAGE.to_f).ceil
    end

    # ## `Paginated#page(req)`
    #
    # Retrieve the current page out of the `req` instance.
    #
    def page(req)
      req.params.fetch('page', default='1').to_i
    end

    # ## `Paginated#page_nums(req, count)`
    #
    # Compute the range of page numbers to display based on the current
    # `req` and the total `count` of items contained in the paginated
    # collection.
    #
    def page_nums(req, count)
      first = page(req) - SPREAD
      last = bound_first(first) + (SPREAD * 2)
      first = bound_last(last, count) - (SPREAD * 2) if bound_last(last, count) == last_page(count)
      bound_first(first)..bound_last(last, count)
    end

    private

    # ## `Paginated#bound_first(first)`
    #
    # *Private* method to calculate the first page based on the current
    # value of `first` to display taking into account the lower display
    # bound or minimum page number (1).
    #
    def bound_first(first)
      if first < 1 then 1 else first end
    end

    # ## `Paginated#bound_last(last, count)`
    #
    # *Private* method to calculate the last page number to display
    # accounting for the maximum page number display bound represented
    # by `#last_page`. Returns a value less than or equal to `#last_page`
    # based on the current value of `last` and the total `count` of items
    # in the collection.
    #
    def bound_last(last, count)
      if last > last_page(count) then last_page(count) else last end
    end

  end

end
