require 'bundler'
Bundler.require
require 'json'

DB = Sequel.connect(ENV['DATABASE_URL'])
Sequel::Model.plugin(:json_serializer)
Sequel::Model.plugin(:timestamps, update_on_create: true)

class Message < Sequel::Model
  many_to_one :original_message, key: :original_message_id, class: self
  def to_json(options = nil)
    options ||= {}
    options[:methods] = [options[:methods]].compact unless Array === options[:methods]
    options[:methods] << :original_message
    super(options)
  end
end

before do
  response.headers["Access-Control-Allow-Origin"] = "*"
  if request.request_method == 'OPTIONS'
    response.headers["Access-Control-Allow-Methods"] = "POST,GET,PATCH"
    halt 200
  end
end

helpers do
  def random_message(*fields)
    fields << :id unless fields.count
    Message.select(*fields).all.sample
  end

  def json(arg)
    headers 'Content-Type' => 'text/json'
    JSON.dump(arg)
  end
end

get '/' do
  json Message.all
end

post '/' do
  content = params.keys.select { |k| String === k }.first
  message = Message.create(content: content)
  json message
end

get '/path-of-zen' do
  redirect "/#{random_message.id}"
end

get '/zen' do
  json random_message.reload
end

get '/zen.txt' do
  headers 'Content-Type' => 'text/plain'
  random_message(:id, :content).reload.content
end

get '/:id' do
  json Message.find(id: params.delete('id'))
end

patch '/:id' do
  original_message = Message.find(id: params.delete('id'))
  content = params.keys.select { |k| String === k }.first
  json Message.create(content: content, original_message_id: original_message.id)
end
