
def for_each_submodule &block
  status = %x{git submodule status}
  status.each {|line| yield line.split()[1] }
end

def for_each_submodule_dir &block
  for_each_submodule { |dir| Dir.chdir(dir) { yield dir } }
end

def get_branch(status = `git status`)
  branch = nil
  if match = Regexp.new("^# On branch (.*)").match(status)
    branch = match[1]
  end
end

namespace :git do

  desc "Update submodules"
  task :update do
    for_each_submodule_dir do
      sh 'git submodule update'
    end
  end

end
