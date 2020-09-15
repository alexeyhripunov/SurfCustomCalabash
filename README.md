# SurfCustomCalabash


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'SurfCustomCalabash'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install SurfCustomCalabash

## Usage

This gem provides methods for easier use Calabash.

Install gem in your exist project, add in your ios or android ruby files.

    $require 'SurfCustomCalabash/IosCommon' 
    
    $require 'SurfCustomCalabash/DroidCommon' 

**IosCommon** contains custom swipe methods for ios.
 
**DroidCommon** contains custom swipe methods for android.

**CommonMethods** contains different methods (taps, swipes, waits and other) for both platforms.

### Create new project
You should move to the directory which would contains folder with your tests. 
surf-calabash will create it by itself with the name **Change_it_to_your_own_project_name**: 
    
    $ SurfCustomCalabash gen
    
After that you'll see many folders inside them. Each of them will be describe below. 

#### ci 

It is used for all scripts for continuous integration. In Surfstudio we have .groovy files for them.
 
 
#### config

Contains only cucumber.yml file. It named arguments are called profiles - e.g. iOS or Android for run.


#### features 

Main folder of all project. Every feature, step definition, support files and page objects are here. You can read about it more in each file of this folder.


#### irbrcs

Our own shtick. We change calabash-android console and calabash-ios console a little, so you can write your own complex functions, which you'll implement in the step_definitions or in page objects. So for the correct work we had to change irbrc-files of gems too. 

#### reports 

Folder with screenshots of errors.


#### test_servers

Standard calabash-android folder with signed apk-files. 

#### TestFolder 

Contains some additional files, e.g. jpg-pictures or other data which can be used in tests. 

#### Backdoors list

We use backdoors for our applications for get around the limit of nativity of calabash.

#### Gemfile 

All required gems for surf-calabash. You should run installing all gems by bundle after initializing project when you rename **Change_it_to_your_own_project_name** to your own name.

    $bundle install

#### Scripts 

Some shell scripts which can help to start tests faster because of typing smaller count of symbols. :) 
Also it shows some integration with Xray Jira plugin. 

#### start.sh

Shell script for useful launch all helpful scripts of folder above.

 