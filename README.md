# scout_agent [![Build Status](https://secure.travis-ci.org/miketheman/scout_agent.png?branch=master)](http://travis-ci.org/miketheman/scout_agent)

Description
===========
Installs the [Scout Agent](http://scoutapp.com) gem and schedules it to run the [Scout-recommended way (via Cron)](https://scoutapp.com/info/support#cron).

Requirements
============

Tested with Chef 0.10.10, Ubuntu 10.04 LTS, CentOS 6.2, Amazon Linux 2012.03.

Previously tested on Ubuntu 8.04 Server LTS, works well on others like CentOS/RHEL.

The Scout Agent requires a valid Scout account. You also need a unique server key which is displayed in your Scout accounts 'server settings' tab.

It looks like:

    6ecad322-0d17-4cb8-9b2c-a12c4541853f

Attributes
==========
* scout_agent['user'] - User to run Scout agent under.  Will be created if it does not exist.  Default is 'scout'.
* scout_agent['group'] - User group to run Scout agent under.  Will be created if it does not exist.  Default is 'scout'.
* scout_agent['uid'] - User ID for Scout user. Defaults to 999.
* scout_agent['gid'] - Group ID for Scout user. Defaults to 999.
* scout_agent['version'] - Gem version to install.  Default is 5.5.4.
* scout_agent['key'] - Used to validate your agent when it checks into the Scout server.
* scout_agent['rename'] - Rename server to Chef node name? Default is false.

USAGE
=====
Include the `scout_agent` recipe to install Scout Agent and configure a Cron job to run it.

Be sure to set the scout_agent['key'] attribute on every node where you want the agent to run. This is the default method for Scout - where each server has an individual key.

Since Scout has the ability to have a "cloud" instance key (so that all machines of the same role/type are monitored the same way), you can apply the `scout_agent['key']` attribute to a role as well. When the cookbook is run, all instances of a role will identify with the same key, but different hostnames, and Scout knows to create a new instance of the same type of monitoring (including plugins, notifications, etc).
See further explanation on [Scout cloud](http://blog.scoutapp.com/articles/2009/09/28/cloud-monitoring).

In Chef 0.10 with the introduction of environments, this allows one to apply a Scout Cloud Key to the Role level, and by only including the `scout_agent` recipe in the production environment, you can prevent non-prod instances from registering with Scout.

Including scout agent and a key for a role in production looks like this:

    roles/webserver.json:
    {
        "name": "webserver",
        "default_attributes": {
            "scout_agent": {
                "key": "insert_cloud_key_for_prod_datanode_here"
            }
        },
        "json_class": "Chef::Role",
        "env_run_lists": {
            "prod": [
            "recipe[apache2]",
            "recipe[scout_agent]"
            ]
        },
        "run_list": [
            "recipe[apache2]"
        ],
        "description": "Installs a webserver instance",
        "chef_type": "role",
        "override_attributes": {
        }
    }

A safer way to ensure that non-prod instances do not attempt to register with Scout is to use the Environment override attribute, and set it to nil.

This looks like:

    $ knife environment show dev -F json
    {
        "name": "dev",
        "default_attributes": {
        },
        "json_class": "Chef::Environment",
        "description": "Development environment",
        "cookbook_versions": {
        },
        "override_attributes": {
            "scout_agent": {
                "key": nil
            }
        },
        "chef_type": "environment"
    }

And as before, whatever key you specify on the node itself overrides anything else.


License and Author
==================

Author:: Mike Fiedler (<miketheman@gmail.com>)
Author:: Ryan Roemer (<ryan@loose-bits.com>)
Author:: Seth Chisamore (<schisamo@gmail.com>)
Copyright:: 2011-2012, Mike Fiedler
Copyright:: 2012, Ryan Roemer
Copyright:: 2010, Seth Chisamore

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.