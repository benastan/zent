ENV['DATABASE_URL'].gsub('development', 'test')
ENV['RACK_ENV'] = 'test'
require './zent'
require 'rack/test'
require 'pry'

describe 'Zent' do
  around do |example|
    DB.transaction do
      example.run
      raise Sequel::Rollback
    end
  end
  describe 'api' do
    include Rack::Test::Methods
    def app; Sinatra::Application; end
    let(:attrs) { { content: 'Hello, world' } }
    let(:message) { Message.create(attrs) }
    subject { JSON.parse(_request.body) }
    describe '/' do
      describe 'when HTTP verb is get' do
        before { message }
        let(:_request) { get '/' }
        its(:count) { should == Message.count }
      end
      context 'when HTTP verb is post' do
        let(:_request) { post '/', message: attrs }
        specify do
          expect { subject }.to change(Message, :count).by(1)
        end
        its(['id']) { should be }
        context 'when original_message_id is given' do
          before { attrs[:original_message_id] = message.id }
          specify { _request.should be_ok }
          its(['original_message']) { should == JSON.parse(message.to_json) }
        end
      end
    end
    describe '/:id' do
      let(:_request) { get "/#{message.id}" }
      its(['id']) { should == message.id }
    end
    describe '/zen' do
      before do
        Message.create(content: "Hello, World")
        Message.create(content: "Some zen for you.")
      end
      let(:_request) { get '/zen' }
      subject { JSON.parse(_request.body) }
      specify { Message.select(:id).all.collect(&:id).should include subject['id'] }
    end
  end
end
