require 'sinatra'
require 'sinatra/reloader'
require 'json'

enable :method_override

get '/' do
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
             end
  end

  def update_json(memo)
    File.open('memo.json', 'w') do |f|
      JSON.dump(memo, f)
    end
  end
end

before do
  find_json
end

post '/memos/create' do
  id = Time.now.strftime('%Y%m%d%H%M%S%L').to_i.to_s(36)
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

  if @memos
    @memos.merge!(memo)
    update_json(@memos)
  else
    update_json(memo)
  end
  redirect to("/memos/#{id}")
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
  memo = @memos[params[:id]]
  memo['title'] = params[:title]
  memo['content'] = params[:content]
  memo['updated_at'] = Time.now

  update_json(@memos)
  redirect to("/memos/#{params[:id]}")
end

delete '/memos/:id' do
  @memos.delete(params[:id])
  update_json(@memos)
  redirect to('/')
end
