# exceptionhandler_helper.rb
# @date Feb. 15, 2012
# @author ricky barrette <rickbarrette@gmail.com>
# @authro twenty codes <twentycodes@gmail.com>
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

module ExceptionhandlerHelper

  # Checks the database for exisiting reports
  # @return id report is existing else 0
  def check_for_existing_report
    bug_id = tracker.id
    issues = Project.find_by_name(params[:app]).issues
    issues.each do |issue|
      if issue.tracker_id == bug_id
        id = check_issue(issue)
        if id > 0
          return id
        end
      end
    end
    return 0;
  end
  
  # checks a specific issue agains params
  # @return id of report if matching, else 0
  def check_issue(issue)
    if issue.subject == params[:msg]
      if check_issue_custom_values(issue)
        return issue.id
      else
        return 0
      end
    else
      return 0
    end
  end
  
  #checks if this issue is a match for params based on it's custom values'
  # @return true if matching
  def check_issue_custom_values (issue)
    count = 0
    custom_fields = CustomField
    issue.custom_field_values.each do |value|
      case custom_fields.find_by_id(value.custom_field_id).name
        when "Version"
          if value.value == params[:version]
            count += 1
          end
        when "StackTrace"
          if value.value == params[:stackTrace]
            count += 1
          end
        when "Cause"
          if value.value == params[:cause]
            count += 1
          end
      end
    end
    if count == 3
      return true
    else
      return false
    end
  end
  
  # files a new exception report in redmine
  # @return true if new report was filed
  def create_new_report
    issue = Issue.new
    issue.tracker = tracker
    issue.subject = params[:msg]
    issue.description = params[:description]
    issue.project = Project.find_by_name(params[:app])
    issue.start_date = Time.now.localtime.strftime("%Y-%m-%d %T")
    issue.priority = IssuePriority.find_by_name("Normal")
    issue.author = User.anonymous
    issue.status = IssueStatus.find_by_name("New")

    issue.custom_values = [
      create_custom_value(CustomField.find_by_name("StackTrace").id, params[:stackTrace]),
      create_custom_value(CustomField.find_by_name("Cause").id, params[:cause]),
      create_custom_value(CustomField.find_by_name("Count").id, "1"),
      create_custom_value(CustomField.find_by_name("Device").id, params[:device]),
      create_custom_value(CustomField.find_by_name("Version").id, value = params[:version]),
      create_custom_value(CustomField.find_by_name("Date").id, value = params[:date])
      ]
    return issue
  end
  
  # returns a new custom value
  def create_custom_value(field_id, value)
    custom_value = CustomValue.new
    custom_value.custom_field_id = field_id
    custom_value.value = value
    custom_value.customized_type = "Issue"
    return custom_value
  end
  
  # retrives an issue by it's id and updates it
  # @returns updated issue
  def update_report(issue_id)
    issue = Issue.find_by_id(issue_id)
    if params[:description].length > 0
      description = issue.description
      description += "\n\n--- New Description --- \n"
      description += params[:description]
      issue.description = description
    end
    
    custom_fields = CustomField
    issue.custom_field_values.each do |value|
      case custom_fields.find_by_id(value.custom_field_id).name
        when "Device"
          value.value = value.value += "\n"
          value.value = value.value += params[:device]
        when "Date"
          value.value = value.value += "\n"
          value.value = value.value += params[:date]
        when "Count"
          value.value = (value.value.to_i + 1).to_s
      end
      value.save
    end
    issue.init_journal(User.anonymous, "Issue updated")
    issue.save
  end
  
  # gets the prodived tracker
  # if it doesnt exist, defualt to Bug
  def tracker
    if(params[:tracker]!= nil)
      if params[:tracker].length > 0
        t = Tracker.find_by_name(params[:tracker])
        if(t != nil)
          return t
        end
      end
    end
    return Tracker.find_by_name("Bug")
  end
  
end #EOF
