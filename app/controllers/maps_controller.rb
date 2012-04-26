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
    if session[:uploadSuccess] 
      flash.now[:notice] = "File has been uploaded successfully"
      session[:uploadSuccess] = false
    end
  end
  
  def uploadFile
    post = Map.save(params[:upload])
    session[:uploadSuccess] = true
    redirect_to(:back)
  end
  
end #EOF
