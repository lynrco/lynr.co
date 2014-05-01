# A sample Guardfile
# More info at https://github.com/guard/guard#readme
#
# on vagrant guard has to be started with `bundle exec guard -p` to use
# polling according to http://stackoverflow.com/a/12122612/1357024

notification :tmux, color_location: 'status-left-fg', display_message: true

guard 'bundler' do
  watch('Gemfile')
end

def check_syntax(m)
  syntax_ok = true
  if File.exist? m[0]
    out = `ruby -c #{m[0]} 2>&1`
    syntax_ok = $? == 0
    puts "#{m[0]} -- #{out}" if !syntax_ok
  end
end

group :unicorn do

  guard 'shell' do

    def restart_unicorn(m)
      lockfile = "/tmp/lynr.unicorn.lock"
      pidfile = "/tmp/lynr.unicorn.pid"
      if (File.exist?(pidfile) && !File.exist?(lockfile))
        `touch #{lockfile}`
        oldpid = `cat #{pidfile}`.rstrip
        `kill -s HUP #{oldpid}`
        `rm #{lockfile}`
        ::Guard::UI.info "Restarted Unicorn. PID #{oldpid}"
      elsif (File.exist?(lockfile))
        ::Guard::UI.info "Unicorn locked."
      else
        ::Guard::UI.info "No Unicorn PID file."
      end
    end

#   watch(/^(.*)\.rb$/) { |m| check_syntax(m) }
#   watch('Gemfile') { |m| restart_unicorn(m) }
#   watch('web.rb') { |m| restart_unicorn(m) }
#   watch(%r{^lib/(.+)\.rb$}) { |m| restart_unicorn(m) }

  end

end

group :rspec do

  guard 'rspec', cmd: 'bundle exec rspec' do
    watch(/^(.*)\.rb$/) { |m| check_syntax(m) }
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch(%r{^spec/.+_helper.rb})  { "spec" }
    watch(%r{^views/}) { "spec/lib/lynr/controller" }
    watch('spec/lib/lynr/cache_spec.rb') { 'spec/lib/lynr/cache' }
  end

end
