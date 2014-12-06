# Robot class to run under multiplexing infrastructure
module Robots       # Robot package
  module DorRepo    # Use DorRepo/SdrRepo to avoid name collision with Dor module
    module ItemRelease   # This is your workflow package name (using CamelCase)

      class ReleaseMembers # This is your robot name (using CamelCase)
        # Build off the base robot implementation which implements
        # features common to all robots
        include LyberCore::Robot 
        
        def initialize
          super('dor', Dor::Config.itemRelease.workflow_name, 'release-members', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "release-members working on #{druid}"
          
          item = Dor::ItemRelease::Item.new :druid => druid
          
          case item.object_type
            
            when "collection","set"  # this is a collection or set, fetch the members                   
            
              LyberCore::Log.debug "...fetching members of #{item.object_type}"
              if item.item_members # if there are any members, iterate through
            
                item.item_members.each {|member| Dor::ItemRelease::Item.add_workflow_for_item(member['druid'])}
            
              else # no members found
            
                LyberCore::Log.debug "...no members found in #{item.object_type}"            
            
              end # end check for any members
            
            else # this is not a collection of set
            
              LyberCore::Log.debug "...this is a #{item.object_type}, NOOP"            
            
            end # end case statement
          
        end # end peform method 
         
      end # end releaseMembers class
                
    end
  end
end
