
require_relative '../microkube/renderer'

namespace :render do
  desc 'Render configuration and compose files and keys'
  task :config do
    renderer = Microkube::Renderer.new
    renderer.render_keys
    renderer.render
  end
end
