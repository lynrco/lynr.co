namespace :lynr do

  namespace :db do

    def setup_logger(task)
      @logger = Log4r::Logger.new("rake:#{task}")
      @logger.outputters << Log4r::StdoutOutputter.new('console', OPTS)
    end

    task :update_images_preamble, :task_name, :source, :target do |t, args|
      require './lib/lynr/logging'

      include Lynr::Logging
      setup_logger('update_vehicle_image_urls')

      source = args[:source]
      target = args[:target]
      grace = 5

      log.info("Updating vehicle image paths. Changing:\n  #{source} ->\n  #{target}")
      log.info("You have #{grace} seconds to abort.")
      Kernel.sleep(1)
      (1..grace).each do |i|
        Kernel.sleep(1)
        log.info("You have #{grace -= 1} seconds to abort.")
      end
    end

    desc 'Replace `source` in dealership image URLs with `target`'
    task :update_dealership_image_urls, :source, :target do |t, args|
      source = args[:source]
      target = args[:target]
      Rake::Task['lynr:db:update_images_preamble'].invoke(t.name, source, target)
      dao = dealership_dao.instance_variable_get(:@dao)
      collection = dao.collection
      collection.find({}, fields: ['_id', 'image']).each do |record|
        id = record['_id']
        updated = record['image'].dup.tap do |img|
          image['full']['url'] = image['full']['url'].gsub(source, target)
          image['original']['url'] = image['original']['url'].gsub(source, target)
          image['thumb']['url'] = image['thumb']['url'].gsub(source, target)
        end
        collection.update({ '_id' => id}, { '$set' => { 'image' => updated } })
        log.info("Updated dealership:#{id.to_s}")
      end
    end

    desc 'Replace `source` in vehicle image URLs with `target`'
    task :update_vehicle_image_urls, :source, :target do |t, args|
      source = args[:source]
      target = args[:target]
      Rake::Task['lynr:db:update_images_preamble'].invoke(t.name, source, target)
      dao = vehicle_dao.instance_variable_get(:@dao)
      collection = dao.collection
      collection.find({}, fields: ['_id', 'images']).each do |record|
        id = record['_id']
        updated = record['images'].map do |image|
          image.dup.tap do |img|
            image['full']['url'] = image['full']['url'].gsub(source, target)
            image['original']['url'] = image['original']['url'].gsub(source, target)
            image['thumb']['url'] = image['thumb']['url'].gsub(source, target)
          end
        end
        collection.update({ '_id' => id}, { '$set' => { 'images' => updated } })
        log.info("Updated vehicle:#{id.to_s}")
      end
    end

  end

end
