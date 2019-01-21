namespace :terraform do
  desc 'Initialize the Terraform configuration'
  task :init do
    Dir.chdir('terraform') { sh 'terraform init' }
  end

  desc 'Apply the Terraform configuration'
  task :apply => ['render:config', :init] do
    Dir.chdir('terraform') { sh 'terraform apply' }
  end

  desc 'Destroy the Terraform infrastructure'
  task :destroy do
    Dir.chdir('terraform') { sh 'terraform destroy' }
  end
end
