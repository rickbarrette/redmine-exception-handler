ActionController::Routing::Routes.draw do |map|
  map.connect '/exceptionhandler', :controller => 'exceptionhandler', :action => 'index'
end
