
require_relative '../microkube/renderer'

namespace :render do
  desc 'Render configuration files'
  task :config do
    renderer = Microkube::Renderer.new
    renderer.render
  end
end
