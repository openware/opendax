PACKER_VARS = "config/packer.json".freeze
IMAGE_LIST  = %w(parity bitcoind).freeze

def build(app)
  puts "Building #{app} Packer image"
  sh "packer build -var-file=#{PACKER_VARS} packer/#{app}/image.json"
end

namespace :packer do
  desc 'Build a Packer image'
  task :build, [:image] do |task, args|
    abort 'Error: Argument missing' if args[:image].nil?
    abort 'Error: Wrong argument' unless IMAGE_LIST.include? args[:image]
    build(args[:image])
  end

  namespace :build do
    desc 'Build all Packer images'
    task :all do
      IMAGE_LIST.each do |app|
        build(app)
      end
    end
  end
end
