namespace :assets do

  desc 'Compiles LESS assets'
  task :precompile do
    require 'bundler/setup'
    require 'less'

    compress = true
    yuicompress = false
    sheets = [
      ['public/less/main.less']
    ]

    options = {
      :paths => [],
      :strictImports => false,
      :silent => false,
      :optimization => 1
    }

    sheets.each do |paths|
      opts = options.dup

      paths.each do |path|
        opts[:paths].unshift File.dirname(path)
      end

      opts[:paths].uniq!

      to_parse = paths.reduce("") { |memo, path| memo + File.read(path) }
      name = File.basename(paths[0]).gsub(%r(less$), 'css')

      begin
        parser = Less::Parser.new(options)
        tree = parser.parse(to_parse)
        css = tree.to_css(:compress => compress, :yuicompress => yuicompress)
        File.open("public/css/#{name}", 'w') do |file|
          file.write(css)
        end
        puts "Successfully processed #{paths[0]}"
      rescue StandardError => e
        puts "Error processing #{paths[0]} -- #{e.message}"
      end
    end
  end

  task :nothing do
  end

end
