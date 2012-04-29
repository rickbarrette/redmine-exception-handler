# routes.rb
# @date Apr 19, 2012
# @author ricky barrette <rickbarrette@gmail.com>
#
# Copyright 2012 Rick Barrette
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This controller class will handler incomming http requests containing new exception reports.
# When a new exception report is recieved, it will be compared to existing bug issues.
# If there is a match, the existing issue will be updated
# if not a new bug issue will be generated.
ActionController::Routing::Routes.draw do |map|  
  map.connect '/exceptionhandler', :controller => 'exceptionhandler', :action => 'index'
  map.connect '/exceptionhandler/maps', :controller => 'maps', :action => 'index'
  map.connect '/uploadFile', :controller => 'maps', :action => 'uploadFile'
  map.connect '/exceptionhandler/maps/delete/:map', :controller => 'maps', :action => 'deleteMap'
  map.connect '/exceptionhandler/maps/new', :controller => 'maps', :action => 'new'
end
