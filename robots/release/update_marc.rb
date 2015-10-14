module Robots
  module DorRepo
    module Release
      class UpdateMarc
        include LyberCore::Robot

        def initialize
          super('dor', Dor::Config.release.workflow_name, 'update-marc', check_queued_status: true) # init LyberCore::Robot
        end

        # `perform` is the main entry point for the robot. This is where
        # all of the robot's work is done.
        #
        # @param [String] druid -- the Druid identifier for the object to process
        def perform(druid)
          LyberCore::Log.debug "update_marc working on #{druid}"
          item = Dor::Item.find druid
          update_marc_record = Dor::UpdateMarcRecordService.new item
          update_marc_record.push_symphony_record unless update_marc_record.ckey(item).nil?
        end
      end
    end
  end
end
