# Set load_path if needed

$LOAD_PATH.unshift(File.expand_path(__dir__)) unless $LOAD_PATH.include?(File.expand_path(__dir__))

# get required files
require 'rbcurse/core/util/app'
require 'date'
require 'lib/equipmenttracker'
require 'lib/model/event'
require 'lib/model/specialty'
require 'lib/model/item'
require 'lib/model/event_specialty'
require 'lib/trackertree'
require 'lib/trackertreemodel'
require 'lib/utils'

def help_text
    <<-eos
Enter as much help text
here as you want
    eos
end

App.new do 
    ## application code comes here
    @form.help_manager.help_text = help_text()

    @header = app_header "Equipment Tracker #{EquipmentTracker::VERSION}", :text_center => "Equipment Tracking System", :color => :white, :bgcolor => :black
    db_connect
    flow :margin_top => 1 do
        events = Event.order(:start_date, :end_date)
        @model = TrackerTreeModel.new('Events')
        events.each do |ev|
            key = "#{ev.name} #{ev.start_date} #{ev.end_date}"
            evnode = TrackerNode.new(key)
            @model.addlink(key, 'event', ev.id)
            @model.root.add(evnode)
            sps = ev.specialties.order(:name)
            sps.each do |sp|
                key = "#{sp.name} #{sp.chief}"
                spnode = TrackerNode.new(key)
                @model.addlink(key, 'specialty', sp.id)
                evnode.add(spnode)
                eq = sp.items.order(:item_type, :item_no)
                eq.each do |item|
                    key = "#{item.item_no} #{item.item_type}"
                    eqnode = TrackerNode.new(key)
                    @model.addlink(key, 'item', item.id)
                    spnode.add(eqnode)
                    subs = item.subitems.order(:item_type, :item_no)
                    subs.each do |sub|
                        eqnode.add(TrackerNode.new("#{sub.item_no} #{sub.item_type}"))
                        @model.addlink("#{sub.item_no} #{sub.item_type}", 'item', sub.id)
                    end
                end
            end
        end
        trackertree :data => @model, :title => "events", :show_selector => true do
            bind_key(?a, 'Assign') do
                assign_to_node(current_row)
            end
            bind_key(?u, 'Unassign') do
                unassign_from_node(current_row)
            end
            bind_key(?e, "Edit") do
                editnode(current_row)
            end
            bind_key(FFI::NCurses::KEY_F2, 'Import Events') do
                import('events')
            end
            bind_key(FFI::NCurses::KEY_F3, 'Import Specialties') do
                import('specialties')
            end
            bind_key(FFI::NCurses::KEY_F4, 'Import Equipment') do
                import('equipment')
            end
        end
    end

    #@status_line = status_line
    #@status_line.command {
    #
    #}
end # app
