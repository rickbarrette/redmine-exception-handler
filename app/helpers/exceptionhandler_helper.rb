# exceptionhandler_helper.rb
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

module ExceptionhandlerHelper
  
  require 'tempfile'

  # Checks the database for existing reports
  # @return existing issue report if existing
  def check_for_existing_report
    bug_id = tracker.id
    issues = Project.find_by_name(params[:app]).issues
    issues.each do |issue|
      if issue.tracker_id == bug_id
        if check_issue(issue)
          return issue
        end
      end
    end
    return nil;
  end
  
  # checks a specific issue against parameters
  # @return true if the supplied issue matches new report args
  def check_issue(issue)
    if issue.subject == params[:msg]
      if check_issue_custom_values(issue)
        return true
      end
    end
    return false
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
        when "Package"
          if value.value == params[:package]
            count += 1
          end
        when "Cause"
          if value.value == params[:cause]
            count += 1
          end
      end
    end
    if count == 4
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
      create_custom_value(CustomField.find_by_name("Package").id, value = params[:package]),
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
  
  # updates the provided issue with the incoming report
  # @returns true if save is successful
  def update_report(issue)
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
    end
    issue.init_journal(User.anonymous, "Issue updated")
    return issue.save
  end
  
  # gets the provided tracker
  # if it doesn't exist, default to Bug
  def tracker
    if(params[:tracker]!= nil)
      if params[:tracker].length > 0
        Tracker.verify_active_connections!
        t = Tracker.find_by_name(params[:tracker])
        if(t != nil)
          return t
        end
      end
    end
    return Tracker.find_by_name("Bug")
  end
 
  # de obfuscates a trace of there is a map available
  def deobfuscate (stacktrace, package, build)
    map = find_map(package, build)
      
    if map != nil
    
      # Save the stack trace to a temp file
      # might need to add ruby path
      tf = Tempfile.open('stacktrace')
      path = tf.path
      tf.print(stacktrace)
      tf.flush
      output = ""
      #retrace
      Open3.popen3("#{RAILS_ROOT}/vendor/plugins/redmine-exception-handler/public/proguard/bin/retrace.sh #{RAILS_ROOT}/public/maps/#{map.map} #{path}") do |stdrin, stdout, stderr|
        output += stdout.read
        output += stderr.read
      end
      tf.close
      return output
    else
      return stacktrace
    end
  end

  # find a proguard map if it exists
  def find_map (package, build)
    Map.all.each do |map|
      if(map.package == package)
        if map.build == build
          return map
        end
      end
    end
    return nil
  end
end
