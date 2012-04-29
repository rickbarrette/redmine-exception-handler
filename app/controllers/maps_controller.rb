# maps_controller.rb
# @date Apr 25, 2012
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

# This controller class will handle map management
class MapsController < ApplicationController
  unloadable
  
  include AuthHelper

  before_filter :require_user
  
  def index
    
  end
  
  def uploadFile
    post = Map.save(params)
    session[:uploadSuccess] = post
    redirect_to(:back)
  end

  def deleteMap
    map = Map.find_by_map(params[:map])
    if map != nil
      map.destroy
      directory = "public/maps"
      File.delete("#{RAILS_ROOT}/public/maps/#{params[:map]}")
      flash.now[:notice] = "Map deleted successfully"
    else
      flash.now[:error] = "No Map Found"
    end
  end

  def new
    if session[:uploadSuccess]
      flash.now[:notice] = "File has been uploaded successfully"
      session[:uploadSuccess] = false
    end
  end
  
end #EOF
