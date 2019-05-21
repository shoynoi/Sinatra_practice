require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'securerandom'

get '/' do
  @sorted_memos = @memos.sort_by { |_id, memo| memo['updated_at'] }.reverse
  erb :index
end

get '/memos/new' do
  erb :new
end

helpers do
  def find_json
    @memos = if File.exist?('memo.json')
               File.open('memo.json') do |f|
                 JSON.parse(f.read)
               end
             else
               {}
             end
  end

  def update_json(memo)
    File.open('memo.json', 'w') do |f|
      JSON.dump(memo, f)
    end
  end

  def validate_empty
    @error_messages = []
    params.each do |key, value|
      next unless value.match?(/\A[[:space:]]*\z/)

      @error_messages << "#{key}を入力してください"
    end
    @error_messages
  end

  def unique_id
    id = SecureRandom.uuid
    id = SecureRandom.uuid while @memos.key?(id)
    id
  end
end

before do
  find_json
end

post '/memos/' do
  id = unique_id
  title = params[:title]
  content = params[:content]
  created_at = Time.now
  updated_at = Time.now

  memo = {
    id => {
      title: title,
      content: content,
      created_at: created_at,
      updated_at: updated_at
    }
  }

  validate_empty
  if @error_messages.any?
    @memo = memo[id.to_s]
    erb :new
  else
    @memos.merge!(memo)
    update_json(@memos)
    redirect to("/memos/#{id}")
  end
end

get '/memos/:id' do
  @memo = @memos[params[:id]]
  erb :show
end

get '/memos/:id/edit' do
  @memo = @memos[params[:id]]
  erb :edit
end

patch '/memos/:id' do
  @memo = @memos[params[:id]]
  validate_empty
  if @error_messages.any?
    erb :edit
  else
    @memo['title'] = params[:title]
    @memo['content'] = params[:content]
    @memo['updated_at'] = Time.now

    update_json(@memos)
    redirect to("/memos/#{params[:id]}")
  end
end

delete '/memos/:id' do
  @memos.delete(params[:id])
  update_json(@memos)
  redirect to('/')
end
