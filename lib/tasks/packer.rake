PACKER_VARS = "config/environments/#{ENV.fetch('KITE_ENV')}/packer.json"
IMAGE_LIST  = %w(vagrant workbench)

def build(app)
  puts "Building #{app} Packer image"
  sh "packer build images/#{app}.json"
end

namespace :packer do

  desc "Build packer images"
  task :build, [:image] do |task, args|
    abort 'Error: Argument missing' if args[:image].nil?
    abort 'Error: Wrong argument' unless IMAGE_LIST.include? args[:image]
    build(args[:image])
  end

  namespace :build do
    desc "Build all packer images"
    task :all do
      IMAGE_LIST.each do |app|
        build(app)
      end
    end
  end

end
