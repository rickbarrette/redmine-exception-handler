require 'redmine'

Redmine::Plugin.register :redmine_exception_handler do
  name 'Redmine Exception Handler plugin'
  author 'Rick Barrette <rickbarrette@gmail.com>'
  description 'An Exception Report Handler plugin for Redmine <= 1.4.x'
  version '0.1.0'
  url 'http://example.com/redmine/exceptionhandler'
  author_url 'http://rickbarrette.dyndns.org'
  menu :top_menu, :maps, { :controller => 'maps', :action => 'index' }, :caption => 'Maps', :before => :help, :if => Proc.new { User.current.logged? }
end
