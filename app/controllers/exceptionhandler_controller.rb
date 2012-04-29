# exceptionhandler_controller.rb
# @date Feb. 15, 2012
# @author ricky barrette <rickbarrette@gmail.com>
# @author twenty codes <twentycodes@gmail.com>
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
class ExceptionhandlerController < ApplicationController
  unloadable
    
  helper :exceptionhandler
  include ExceptionhandlerHelper
  
  def index
    
    #check the incomming report for completeness
    if params.size < 9
      if params.size != 2 
        flash.now[:alert] = "Not enough args"
      end
      
    # check to see if the reported project exists
    elsif Project.find_by_name(params[:app]) == nil
      flash.now[:error] = "Project Not Found"
      @output = params[:app] + " is not a valid project"

    else
    #if we get to this point, then we can try file the incomming report
      
      #lets deobfuscate the traces
      params[:stackTrace] = deobfuscate(params[:stackTrace], params[:package], params[:version])
      params[:cause] = deobfuscate(params[:cause], params[:package], params[:version])

      #check to see if the report exists
      # if we get a report back, then let update it
      issue = check_for_existing_report
      if issue != nil
        if update_report(issue)
          flash.now[:notice] = "Updated report: ##{issue.id}"
        end

      else
        #if we get to this point, the report doesn't exist.
        #lets file a new one
        issue = create_new_report
        if issue.valid?
           issue.save
           flash.now[:notice] = "New report filed: ##{issue.id}"
        else
          flash.now[:error] = "There was an error with filing this report"
          @output = issue.errors.full_messages
        end

        #TODO generate link to issue
#	link_to("My Link", {
#                    :controller =&gt; 'issue',
#                    :action =&gt; issue_id,
#                    :host =&gt; Setting.host_name,
#                    :protocol =&gt; Setting.protocol
#                   })
#	link_to(issue)
    #rescue RuntimeError
    #  @output = "ERROR"
      end
    end
  end
  
end #EOF
