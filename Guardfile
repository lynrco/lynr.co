# A sample Guardfile
# More info at https://github.com/guard/guard#readme
#
# on vagrant guard has to be started with `bundle exec guard -p` to use
# polling according to http://stackoverflow.com/a/12122612/1357024

guard 'bundler' do
  watch('Gemfile')
end

group :vagrant do

  guard 'shell' do

    def restart_unicorn(m)
      lockfile = "/home/vagrant/pids/unicorn.lock"
      pidfile = "/home/vagrant/pids/unicorn.pid"
      if (File.exist?(pidfile) && !File.exist?(lockfile))
        `touch #{lockfile}`
        oldpid = `cat #{pidfile}`.rstrip
        `kill -s USR2 #{oldpid}`
        sleep 0.1
        while (!File.exist?(pidfile) || oldpid == `cat #{pidfile}`.rstrip) do
          sleep 1
        end
        newpid = `cat #{pidfile}`.rstrip
        `kill #{oldpid}`
        `rm #{lockfile}`
        puts "Restarted Unicorn. PID #{newpid}"
      elsif (File.exist?(lockfile))
        puts "Unicorn locked."
      else
        puts "No Unicorn PID file."
      end
    end

    watch(/^(.*)\.rb$/) { |m|
      syntax_ok = true
      if File.exist? m[0]
        out = `ruby -c #{m[0]} 2>&1`
        syntax_ok = $? == 0
        puts "#{m[0]} -- #{out}" if !syntax_ok
      end
    }

    watch('Gemfile') { |m|
      restart_unicorn(m)
    }

    watch('app.rb') { |m|
      restart_unicorn(m)
    }

    watch(%r{^lib/(.+)\.rb$}) { |m|
      restart_unicorn(m)
    }

  end

end

group :local do

  guard 'rspec' do
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$}) { |m| "spec/lib/#{m[1]}_spec.rb" }
  end

  guard 'rake', :task => 'assets:nothing' do
    watch(%r{^public/less/(.+)\.less$})
  end

  guard 'rake', :task => 'assets:precompile' do
    watch(%r{^public/less/(.+)\.less$})
  end

#  guard 'shell' do
#    watch(%r{^public/less/(.+)\.less$}) do |m|
#      puts "Compiling #{m[0]} to public/css/#{m[1]}.css"
#      path = `npm bin -g`
#      `#{path}/lessc -x #{m[0]} public/css/#{m[1]}.css`
#    end
#  end

end

group :nitrous do

  guard 'rake', :task => 'assets:precompile' do
    watch(%r{^public/less/(.+)\.less$})
  end

end
