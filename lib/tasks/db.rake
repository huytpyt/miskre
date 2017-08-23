# namespace :db do
# 
#   desc "Dumps the database to db/APP_NAME.dump"
#   task :dump => :environment do
#     cmd = nil
#     with_config do |app, host, db, user|
#       # cmd = "pg_dump --host #{host} --username #{user} --verbose --clean --no-owner --no-acl --format=c #{db} > #{Rails.root}/db/#{app}.dump"
#       cmd = "pg_dump -Fc #{db} > #{Rails.root}/db/#{app}.dump"
#     end
#     puts cmd
#     exec cmd
#   end
# 
#   desc "Restores the database dump at db/APP_NAME.dump."
#   task :restore => :environment do
#     cmd = nil
#     with_config do |app, host, db, user|
#       # cmd = "pg_restore --verbose --host #{host} --username #{user} --clean --no-owner --no-acl --dbname #{db} #{Rails.root}/db/#{app}.dump"
#       # pg_restore -C -d postgres db.dump
#       cmd = "pg_restore -C -d #{db} #{Rails.root}/db/#{app}.dump"
#     end
#     Rake::Task["db:drop"].invoke
#     Rake::Task["db:create"].invoke
#     puts cmd
#     exec cmd
#   end
# 
#   private
# 
#   def with_config
#     yield Rails.application.class.parent_name.underscore,
#       ActiveRecord::Base.connection_config[:host],
#       ActiveRecord::Base.connection_config[:database],
#       ActiveRecord::Base.connection_config[:username]
#   end
# 
# end

namespace :db do

  desc "Dumps the database to backups"
  task :dump => :environment do
    cmd = nil
    with_config do |app, host, db, user|
      # cmd = "pg_dump -F c -v -h #{host} -d #{db} -f #{Rails.root}/db/backups/#{Time.now.strftime("%Y%m%d%H%M%S")}_#{db}.psql"
      cmd = "pg_dump -Fc #{db} > #{Rails.root}/db/#{app}.dump"
    end
    puts cmd
    exec cmd
  end

  desc "Restores the database from backups"
  task :restore => :environment do
    cmd = nil
    with_config do |app, host, db, user|
      # cmd = "pg_restore --verbose --host #{host} --username #{user} --clean --no-owner --no-acl --dbname #{db} #{Rails.root}/db/#{app}.dump"
      # pg_restore -C -d postgres db.dump
      cmd = "pg_restore -C -d #{db} #{Rails.root}/db/#{app}.dump"
    end
    Rake::Task["db:drop"].invoke
    Rake::Task["db:create"].invoke
    Rake::Task["db:migrate"].invoke
    puts cmd
    exec cmd
  end
  # task :restore, [:date] => :environment do |task,args|
  #   if args.date.present?
  #     cmd = nil
  #     with_config do |app, host, db, user|
  #       # cmd = "pg_restore -F c -v -c -C #{Rails.root}/db/backups/#{args.date}_#{db}.psql"
  #       cmd = "pg_restore -d #{db} #{Rails.root}/db/#{app}.dump"
  #     end
  #     Rake::Task["db:drop"].invoke
  #     Rake::Task["db:create"].invoke
  #     puts cmd
  #     exec cmd
  #   else
  #     puts 'Please pass a date to the task'
  #   end
  # end

  private

  def with_config
    yield Rails.application.class.parent_name.underscore,
      ActiveRecord::Base.connection_config[:host],
      ActiveRecord::Base.connection_config[:database],
      ActiveRecord::Base.connection_config[:username]
  end

end
