
require_relative '../microkube/renderer'

namespace :render do
  desc 'Render configuration files'
  task :config do
    renderer = MicroKube::Renderer.new
    renderer.render
  end
end
