
require_relative '../opendax/renderer'

namespace :render do
  desc 'Render configuration and compose files and keys'
  task :config do
    renderer = Opendax::Renderer.new
    renderer.render_keys
    renderer.render
  end
end
