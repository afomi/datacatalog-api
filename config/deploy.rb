set :environment, (ENV['target'] || 'production')

set :user, 'datcat'
set :application, 'datacatalog-api'
set :domain, 'api.nationaldatacatalog.com'

set :scm, :git
set :repository, "git://github.com/sunlightlabs/#{application}.git"
set :branch, 'master'

set :use_sudo, false
set :deploy_to, "/home/#{user}/www/#{application}"
set :deploy_via, :remote_cache
set :runner, user
set :admin_runner, runner

role :app, domain
role :web, domain

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :migrate do; end
  
  desc "Restart the server"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join current_path, 'tmp', 'restart.txt'}"
  end
  
  desc "Get shared files into position"
  task :after_update_code, :roles => [:web, :app] do
    run "ln -nfs #{shared_path}/config.ru #{release_path}/config.ru"
    run "ln -nfs #{shared_path}/config/config.yml #{release_path}/config/config.yml"
    run "ln -nfs #{shared_path}/config/users.yml #{release_path}/config/users.yml"
    run "ln -nfs #{shared_path}/config/organizations.yml #{release_path}/config/organizations.yml"
    run "rm #{File.join release_path, 'tmp', 'pids'}"
    run "rm #{File.join release_path, 'public', 'system'}"
    run "rm #{File.join release_path, 'log'}"
  end
end