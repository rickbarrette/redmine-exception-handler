require 'redmine'

::Rails.logger.info 'Starting Exception Report Handler for Redmine'

if Rails::VERSION::MAJOR >= 3

	ActionDispatch::Callbacks.to_prepare do
		require_dependency 'issue'
		require_dependency 'project'
		#require_dependency 'customfield'
		require_dependency 'time'
		#require_dependency 'issuepriority'
		require_dependency 'user'
		#require_dependency 'issuestatus'
		require_dependency 'tracker'
		require_dependency 'tempfile'
		require_dependency 'open3'
	end
end

Redmine::Plugin.register :redmine_exception_handler do
  name 'Redmine Exception Handler plugin'
  author 'Rick Barrette <rickbarrette@gmail.com>'
  description 'An Exception Report Handler plugin for Redmine <= 1.4.x'
  version '0.1.0'
  url 'http://example.com/redmine/exceptionhandler'
  author_url 'http://rickbarrette.dyndns.org'
  menu :top_menu, :maps, { :controller => 'maps', :action => 'index' }, :caption => 'Maps', :before => :help, :if => Proc.new { User.current.logged? }
end
