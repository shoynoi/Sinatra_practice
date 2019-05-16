require 'sinatra'
require 'sinatra/reloader'
require 'json'

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
    File.open('memo.json', 'w') do |f|
      JSON.dump(@memos, f)
    end
  else
    File.open('memo.json', 'w') do |f|
      JSON.dump(memo, f)
    end
  end
  redirect to("/memos/#{id}")
end

get '/memos/:id' do
  @memo = @memos[params[:id]]
  erb :show
end
