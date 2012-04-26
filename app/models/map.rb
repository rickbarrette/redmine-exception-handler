# map.rb
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
#
# This controller class will handler incomming http requests containing new exception reports.
# When a new exception report is recieved, it will be compared to existing bug issues.
# If there is a match, the existing issue will be updated
# if not a new bug issue will be generated.
class Map < ActiveRecord::Base
  unloadable
  
  require 'digest/sha1'

  validates_uniqueness_of :map
  validates_presence_of :map, :build, :package

  def self.save(p)
    map = Map.new
    if !p[:package].to_s.empty?
      map.package = p[:package]
    end
    
    if !p[:build].to_s.empty?
      map.build = p[:build]
    end

    upload = p[:upload]
    name =  upload['datafile'].original_filename
    directory = "public/maps"

    if !File.directory? directory
      Dir.mkdir(directory, 0700)
    end

    sha1 = Digest::SHA1.new

    # create the file path
    path = File.join(directory, name)
    # write the file
    File.open(path, "wb") { |f| 
      data = upload['datafile'].read
      f.write(data)
      sha1.update(data)
    } 

    File.rename(directory+'/'+name, directory +'/'+ sha1.hexdigest)

    map.map = sha1.hexdigest
    map.save
  end

  def getMap()

  end
end
