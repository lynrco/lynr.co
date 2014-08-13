# Defines tasks to start all Workers
namespace :lynr do

  namespace :worker do

    desc 'Start each kind of Lynr worker'
    task :all do
      start_workers(queues_workers + events_workers)
    end

  end

end
