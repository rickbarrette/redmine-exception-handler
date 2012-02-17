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
#    @bug_id = Tracker.find_by_name("Bug").id
#    @issues = Project.find_by_name(params[:app]).issues
#    @custom_fields = CustomField
    
    if params.size < 8
      @output = "<strong> not enough args </strong>"
    else
        issue_id = check_for_existing_report
      if issue_id > 0
        # TODO update report
        @output = issue_id
      else
        if file_new_report
          @output = "new report filed"
        else
          @output = "Failed to file report"
        end
      end
    end
    rescue RuntimeError
      @output = "ERROR"
  end
  
end #EOF