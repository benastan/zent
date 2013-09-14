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
    methods = options[:methods]
    options[:methods] = (
      if Array === methods
        methods
      else
        [methods].compact
      end
    )
    options[:methods] << :original_message
    super(options)
  end
end

before do
  if request.request_method == 'OPTIONS'
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "POST,GET,PUT"
    halt 200
  else
    response.headers["Access-Control-Allow-Origin"] = "*"
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
  headers 'Content-Type' => 'text/json'
  json Message.all
end

post '/' do
  attrs = params.delete('message')
  message = Message.create(content: attrs.delete('content'))
  original_message_id = attrs.delete('original_message_id').to_i
  if original_message_id && original_message = Message.find(id: original_message_id)
    message.original_message = original_message
  end
  status 422 unless message.save
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
  message = Message.find(id: params.delete('id'))
  json message
end
