#
# Cookbook Name:: scout_agent
# Attributes:: default
#
# Copyright 2011-2012, Michael A. Fiedler
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
default['scout_agent']['user'] = "scout"
default['scout_agent']['group'] = "scout"
default['scout_agent']['uid'] = 999
default['scout_agent']['gid'] = 999
default['scout_agent']['version'] = "5.5.10"
default['scout_agent']['rename'] = false
