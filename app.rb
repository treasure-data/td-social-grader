require 'sinatra'
require 'open-uri'
require 'json'
require 'nokogiri'
require 'set'

get '/' do
  erb :index
end

get '/stats' do
  url = URI.decode params[:u]
  if url =~ /\A#{URI::regexp}\z/
    @links = fetch_links(url)
    raise Sinatra::NotFound if not @links
    erb :stats
  else
    [400, { 'Content-Type' => 'text/plain' }, 'error']
  end
end

get '/jsonp' do
  url = URI.decode params[:u]
  callback = params[:c] || 'td_social_grader'
  if url =~ /\A#{URI::regexp}\z/
    data = get_social_counts(url)
    if data
      return [200, { 'Content-Type' => 'text/javascript' }, "#{callback}(#{data.to_json});"]
    end
  end
  [400, { 'Content-Type' => 'text/plain' }, 'error']
end

get '/json' do
  url = URI.decode params[:u]
  if url =~ /\A#{URI::regexp}\z/
    data = get_social_counts(url)
    title = get_title(url)
    if data && title
      data["title"] = title
      return [200, { 'Content-Type' => 'text/javascript' }, data.to_json]
    end
  end
  [400, { 'Content-Type' => 'text/plain' }, 'error']
end

helpers do

def get_title(url)
  Nokogiri::HTML(open(url).read).title
rescue => e
  nil
end

def get_social_counts(url)
  url.chomp!
  begin
    tweets = open("http://urls.api.twitter.com/1/urls/count.json?url=#{URI.encode url}").read
    tweets = JSON.parse(tweets)
    tweet_count = tweets['count'].to_i
    
    likes = open("http://graph.facebook.com/fql?q=select%20like_count%20from%20link_stat%20where%20url=%27#{URI.encode url}%27&format=json").read
    likes = JSON.parse(likes)
    like_count = likes['data'][0]['like_count'].to_i

    hatebu = open("http://api.b.st-hatena.com/entry.count?url=#{URI.encode url}").read
    hatebu = hatebu.to_i
    
    linkedin = open("https://www.linkedin.com/countserv/count/share?url=#{URI.encode url}&callback=XXX&format=jsonp").read
    m = /^XXX\((?<json>[^\)]+)\);$/.match(linkedin)
    linkedin = JSON.parse(m["json"])["count"]
 
    return { url: url, facebook: like_count, twitter: tweet_count, hatebu: hatebu, linkedin: linkedin }

  rescue => e
    STDERR.puts "failed to get data for #{url}: #{e.message}"
    return nil
  end
end

def fetch_links(url)
  html = open(url).read 
  data = Nokogiri::HTML(html)
  url_parsed = URI.parse(url)
  url_domain = url_parsed.scheme+"://"+url_parsed.host + '/'
  links = Set.new
  data.css('a').each do |a|
    href = a.attr('href')
    if URI.parse(href).relative?
      href = url_domain + href
    end
    links.add(href) if href.start_with?(url_domain)
  end

  links
rescue => e
  STDERR.puts "failed to get data for #{url}: #{e.message}"
  return nil
end

end
