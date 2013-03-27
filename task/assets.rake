namespace :assets do

  desc 'Compiles LESS assets'
  task :precompile do
    require 'bundler/setup'
    require 'less'

    compress = true
    yuicompress = false
    paths = ['public/less/main.less']

    options = {
      :paths => [],
      :strictImports => false,
      :silent => false,
      :optimization => 1
    }

    paths.each do |path|
      options[:paths].unshift File.dirname(path)
    end
    options[:paths].uniq!

    to_parse = paths.reduce("") { |memo, path| memo + File.read(path) }

    parser = Less::Parser.new(options)
    tree = parser.parse(to_parse)
    css = tree.to_css(:compress => compress, :yuicompress => yuicompress)
    File.open('public/css/main.css', 'w') do |file|
      file.write(css)
    end
  end

end
