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
        let(:_request) { post '/', attrs[:content] }
        specify do
          expect { subject }.to change(Message, :count).by(1)
        end
        its(['content']) { should == attrs[:content] }
        its(['id']) { should be }
      end
    end
    describe '/:id' do
      context 'when HTTP verb is get' do
        let(:_request) { get "/#{message.id}" }
        its(['id']) { should == message.id }
      end
      context 'when HTTP verb is patch' do
        before { message }
        let(:message_content) { "Yo yo" }
        let(:_request) { patch "/#{message.id}", message_content }
        specify { _request.should be_ok }
        it 'creates a new record' do
          expect { subject }.to change(Message, :count).by(1)
        end
        its(['original_message_id']) { should == message.id }
        its(['content']) { should == message_content }
      end
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
