# -*- encoding: UTF-8 -*-
require 'rubygems'
require 'twitter'
require 'fileutils'
require 'yaml'

# -- bilborc config sample --
#  :twitter => {
#    :username => 'name',
#    :password => 'pass',
#    :data_dir=> '__BILBO_ROOT__/data_sample/twitter_comment',
#    :home_url => 'http://dgames.jp/dan/',
#    :prefix => '[diary]',
#    :permatweet_text => 'permatweet',
#    :reply_text => 'reply',
#  },

def _twitter_base
  config[:twitter] or raise('not found config[:twitter]')
  httpauth = Twitter::HTTPAuth.new(config[:twitter][:username], config[:twitter][:password])
  Twitter::Base.new(httpauth)
end

def twitter_base
  @twitter_base ||= _twitter_base
end

def ch_tweet_dir
  Dir.chdir(config[:twitter][:data_dir]) { yield }
end

def label_of_entry(tweet)
  tweet.text[/\w+$/] or raise
end

def create_tweet_file(fname, tweet)
  ch_tweet_dir {
    unless File.exist?(fname)
      puts "create file `#{fname}'"
      #print '  <=', tweet.id, ' ', tweet.text, "\n"
      File.open(fname, 'w') {|f| f.puts tweet.to_yaml }
    else
      puts "file exist `#{fname}'"
    end
  }
end

def webget_permatweets
  base = twitter_base
  timelines = base.user_timeline(:name => config[:twitter][:username], :count => 50)
  timelines.select {|e| e.text.include?(config[:twitter][:prefix]) }.each do |tweet|
    fname = "diary_#{label_of_entry(tweet)}.tweet"
    create_tweet_file(fname, tweet)
  end
end

def webget_replies
  base = twitter_base
  timelines = base.replies(:count => 20)
  timelines.each do |tweet|
    fname = "reply_#{tweet.id}.tweet"
    create_tweet_file(fname, tweet)
  end
end

#-------------------------

def file_read_tweet(fname)
  YAML.load(File.read(fname))
end

def replies
  ch_tweet_dir { Dir.glob('reply_*.tweet').sort.map {|fname| file_read_tweet(fname) } }
end

def replies_of_entry(entry_label)
  tweet = ch_tweet_dir { file_read_tweet("diary_#{entry_label}.tweet") }
  replies.select {|e| e.in_reply_to_status_id == tweet.id }#.sort_by(&:created_at)
end

def tweet_user_url(tweet)
  "http://twitter.com/#{tweet.user.screen_name}"
end

def tweet_status_url(tweet)
  "#{tweet_user_url(tweet)}/status/#{tweet.id}"
end

def tweet_reply_to_url(tweet)
  "http://twitter.com/?status=@#{tweet.user.screen_name} &in_reply_to_status_id=#{tweet.id}&in_reply_to=#{tweet.user.screen_name}"
end

def tweet_html(c, tweet)
  <<-HTML
    <tr>
      <td><img src="#{tweet.user.profile_image_url}" /></td>
      <td>
        <div class="text">
        <span class="name">#{c.link_to c.h(tweet.user.screen_name), tweet_user_url(tweet)}</span>
        #{tweet.text}
        </div>
        <div class="time">#{c.link_to c.h(tweet.created_at), tweet_status_url(tweet)}<div>
      </td>
    </tr>
  HTML
end

def comment_html(c, entry)
  tweet = ch_tweet_dir { file_read_tweet("diary_#{entry.label}.tweet") }
  html = replies_of_entry(entry.label).map {|e| tweet_html(c, e) }.join("\n")
  <<-HTML
    <div class="twitter_comments">
      <h3><a name="r"></a>twitter replies</h3>
      <div class="tweet_link">
        #{c.link_to config[:twitter][:permatweet_text], tweet_status_url(tweet)}
        #{c.link_to config[:twitter][:reply_text], tweet_reply_to_url(tweet)}
      </div>
      <div class="replies">
        <table>#{html}</table>
      </div>
    </div>
  HTML
rescue
  'no tweet'
end

def comment_link(c, entry)
  tweet = ch_tweet_dir { file_read_tweet("diary_#{entry.label}.tweet") }
  str = "replies(#{replies_of_entry(entry.label).size})"
  <<-HTML
    <div class="_twitter_comments">
      <span>#{c.link_to config[:twitter][:reply_text], tweet_reply_to_url(tweet)}</span>
      <span class="link_to_comment">#{permalink(c, str, entry.label, '#r')}</span>
    </div>
  HTML
rescue
  'no tweet'
end

def post_permatweet
  Entry.find('20', :limit => 5).reverse.each do |entry|
    next if ch_tweet_dir { File.exist?("diary_#{entry.label}.tweet") }
    title = entry.to_html[/^.+$/].gsub(/<\/?\w+[^>]*>/, '').sub(/^\[.+\]/, '')
    message = "#{config[:twitter][:prefix]}#{title} #{config[:twitter][:home_url]}permalink/#{entry.label}"
    puts "post: #{message}"
    base = twitter_base
    base.update message
    break
  end
end

if __FILE__ == $0
  require 'rack' 
  def eval_hiki_plugin(a); a; end # todo:
  load ARGV.first # load bilborc
  setup_environment
  FileUtils.mkdir_p config[:twitter][:data_dir]
  post_permatweet
  webget_permatweets
  webget_replies
else
  add_plugin_hook(:after_entry) {|entry, c|
    if c.env['PATH_INFO'] =~ /^\/permalink\//
      comment_html(c, entry)
    else
      comment_link(c, entry)
    end
  }
end
