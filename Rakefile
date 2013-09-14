task :setup do
  `dropdb #{ENV['DATABASE_NAME']}`
  `createdb #{ENV['DATABASE_NAME']}`
  `sequel -m ./db #{ENV['DATABASE_URL']}`
end
