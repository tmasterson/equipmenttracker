require 'rbcurse'
require 'rbcurse/core/widgets/rtree'
require_relative 'model/event'
require_relative 'model/specialty'
require_relative 'model/item'
require_relative 'model/event_specialty'
require_relative 'trackertreemodel'
require_relative 'utils'
require 'date'

class TrackerTree < Tree

    def initialize(form, config={}, &block)
        super
        @editable = true
    end

    def edit h, row, title
        _l = longest_in_list h
        _w = _l.size
        config = { :width => 70, :title => title }
        bw = get_color $datacolor, :black, :white
        $log.debug("editrow #{row.inspect}")
        mb = MessageBox.new config do
            h.each_with_index { |f, i| 
                add Field.new :label => "%*s:" % [_w, f], :text => row[i].chomp, :name => i.to_s, 
                    :bgcolor => :cyan,
                    :display_length => 50,
                    :label_color_pair => bw
            }
            button_type :ok_cancel
        end
        index = mb.run
        return nil if index != 0
        h.each_with_index { |e, i| 
            f = mb.widget(i.to_s)
            row[i] = f.text
        }
        row
    end


    def edit_event(node, key, id)
        event = Event.find(id)
        h = %w[Name Location Group Start_Date End_Date]
        row = [event.name, event.location, event.group, event.start_date.strftime("%m/%d/%Y"), event.end_date.strftime("%m/%d/%Y")]
        row = edit(h, row, " Edit Event #{event.name} ")
        updatehash = {}
        if !row.nil?
            if event.name != row[0]
                updatehash['name'] = row[0]
            end
            if event.location != row[1]
                updatehash['location'] = row[1]
            end
            if event.group != row[2]
                updatehash['group'] = row[2]
            end
            if event.start_date != Date.strptime(row[3], '%m/%d/%Y')
                updatehash['start_date'] = Date.strptime(row[3], '%m/%d/%Y')
            end
            if event.end_date != Date.strptime(row[4], '%m/%d/%Y')
                updatehash['end_date'] = Date.strptime(row[4], '%m/%d/%Y')
            end
            if !updatehash.empty?
                event.update(updatehash)
                @treemodel.updatemodel(node, key, "#{row[0]} #{Date.strptime(row[3], '%m/%d/%Y')}, #{Date.strptime(row[4], '%m/%d/%Y')}")
                @repaint_required = true
            end
        end
    end

    def edit_specialty(node, key, id)
        sp = Specialty.find(id)
        h = %w[Name chief]
        row = [sp.name, sp.chief]
        row = edit(h, row, " Edit Specialty #{sp.name} ")
        updatehash = {}
        if !row.nil?
            if sp.name != row[0]
                updatehash['name'] = row[0]
            end
            if sp.chief != row[1]
                updatehash['chief'] = row[1]
            end
            if !updatehash.empty?
                sp.update(updatehash)
                @treemodel.updatemodel(node, key, "#{row[0]} #{row[1]}")
                @repaint_required = true
            end
        end
    end

    def edit_item(node, key, id)
        item = Item.find(id)
        h = %w[Number serial type description]
        row = [item.item_no.to_s, item.serial, item.item_type, (item.description.nil? ? '' : item.description)]
        row = edit(h, row, " Edit Item #{item.item_type} ")
        updatehash = {}
        if !row.nil?
            if item.item_no != row[0].to_i
                updatehash['item_no'] = row[0].to_i
            end
            if item.serial != row[1]
                updatehash['serial'] = row[1]
            end
            if item.item_type != row[2]
                updatehash['item_type'] = row[2]
            end
            if item.description != row[3]
                updatehash['description'] = row[3]
            end
            if !updatehash.empty?
                $log.debug("update_item #{updatehash.inspect}")
                item.update(updatehash)
                @treemodel.updatemodel(node, key, "#{row[0]} #{row[2]}")
                @repaint_required = true
            end
        end
    end

    def editnode(node)
        if node.root?
            alert("Can't edit this node.")
            return
        end
        key = node.to_s
        table = @treemodel.getlinktable(key)
        id = @treemodel.getlinkid(key)
        case table
        when 'event'
            edit_event(node, key, id)
        when 'specialty'
            edit_specialty(node, key, id)
        when 'item'
            edit_item(node, key, id)
        else
            raise "Invalid table (#{table}), please contact the developer"
        end
    end

    def assign_to_node(node)
        if node.root?
            if confirm("Add new event?")
                h = %w[Name Location Group Start_Date End_Date]
                row = ['', '', '', Date.today.strftime("%m/%d/%Y"), Date.today.strftime("%m/%d/%Y")]
                row = edit(h, row, " New Event ")
                if !row.nil?
                    ev = Event.create(name: row[0], location: row[1], group: row[2], start_date: Date.strptime(row[3], "%m/%d/%Y"), end_date: Date.strptime(row[4], "%m/%d/%Y"))
                    key = "#{ev.name} #{ev.start_date} #{ev.end_date}"
                    evnode = TrackerNode.new(key)
                    @treemodel.addlink(key, 'event', ev.id)
                    node.add(evnode)
                    @repaint_required = true
                end
            end
            return
        end
        key = node.to_s
        table = @treemodel.getlinktable(key)
        id = @treemodel.getlinkid(key)
        case table
        when 'event'
            assign_specialty_to_event(node, id)
        when 'specialty'
            assign_items_to_specialty(node, id)
        when 'item'
            assign_items_to_item(node, id)
        else
            raise "Invalid table (#{table}), please contact the developer"
        end
        @repaint_required = true
    end

    def assign_specialty_to_event(node, id)
        event = Event.find(id)
        assigned = []
        event.specialties.each do |e|
            assigned.push(e.id)
        end
        unassigned = []
        sphash = {}  # hash used because the name chief needed by the list may contain spaces and this be unparsable
        specialties = Specialty.order(:name)
        specialties.each do |s|
            unless assigned.include?(s.id)
                unassigned.push("#{s.name} #{s.chief}") 
                sphash["#{s.name} #{s.chief}"] = s.id
            end
        end
        if unassigned.empty?
            alert("All specialties have already been selected for this event.")
            selected = []
        else
            selected = get_selections(unassigned, 'Select from unassigned Specialties')
        end
        if selected.empty?
            if confirm("Add new specialty and assign?")
                h = %w(Name Chief)
                row = ['', '']
                changed = edit(h, row, " New Specialty ")
                if changed
                    sp = Specialty.create(name: row[0], chief: row[1])
                    unassigned.push("#{row[0]} #{row[1]}")
                    sphash["#{row[0]} #{row[1]}"] = sp.id
                    selected.push(unassigned.length-1)
                end
            end
        end
        selected.each do |i|
            tmp = sphash[unassigned[i]]
            specialty = Specialty.find(tmp)
            event.specialties << specialty
            node.add(unassigned[i])
            @treemodel.addlink(unassigned[i], 'specialty', specialty.id)
        end
    end

    def assign_items_to_specialty(node, id)
        specialty = Specialty.find(id)
        assigned = []
        specialty.items.each do |e|
            assigned.push(e.id)
        end
        unassigned = []
        eqhash = {}  # hash used because the name chief needed by the list may contain spaces and this be unparsable
        items = Item.order(:item_type, :item_no)
        items.each do |s|
            unless assigned.include?(s.id)
                unassigned.push("#{s.item_no} #{s.item_type}") 
                eqhash["#{s.item_no} #{s.item_type}"] = s.id
            end
        end
        if unassigned.empty?
            alert("All equipment have already been selected for this specialty.")
            selected = []
        else
            selected = get_selections(unassigned, 'Select from unassigned equipment')
        end
        if selected.empty?
            if confirm("Add new item and assign?")
                h = %w(number serial type description)
                row = ['', '', '', '']
                changed = edit(h, row, " New Equipment ")
                if changed
                    eq = Item.create(item_no: row[0], serial: row[1], item_type: row[2], description: row[3])
                    unassigned.push("#{row[0]} #{row[2]}")
                    eqhash["#{row[0]} #{row[2]}"] = eq.id
                    selected.push(unassigned.length-1)
                end
            end
        end
        selected.each do |i|
            tmp = eqhash[unassigned[i]]
            item = Item.find(tmp)
            specialty.items << item
            node.add(unassigned[i])
            @treemodel.addlink(unassigned[i], 'item', item.id)
        end
    end

    def assign_items_to_item(node, id)
        item = Item.find(id)
        assigned = []
        assigned.push(item.id)
        item.subitems.each do |e|
            assigned.push(e.id)
        end
        unassigned = []
        eqhash = {}  # hash used because the name chief needed by the list may contain spaces and this be unparsable
        items = Item.order(:item_type, :item_no)
        items.each do |s|
            unless assigned.include?(s.id)
                unassigned.push("#{s.item_no} #{s.item_type}") 
                eqhash["#{s.item_no} #{s.item_type}"] = s.id
            end
        end
        if unassigned.empty?
            alert("All equipment have already been selected for this item.")
            selected = []
        else
            selected = get_selections(unassigned, 'Select from unassigned equipment')
        end
        if selected.empty?
            if confirm("Add new item and assign?")
                h = %w(number serial type description)
                row = ['', '', '', '']
                changed = edit(h, row, " New Equipment ")
                if changed
                    eq = Item.create(item_no: row[0].to_i, serial: row[1], item_type: row[2], description: row[3])
                    unassigned.push("#{row[0]} #{row[2]}")
                    eqhash["#{row[0]} #{row[2]}"] = sp.id
                    selected.push(unassigned.length-1)
                end
            end
        end
        selected.each do |i|
            tmp = eqhash[unassigned[i]]
            item = Item.find(tmp)
            item.subitems << item
            node.add(unassigned[i])
            @treemodel.addlink(unassigned[i], 'item', item.id)
        end
    end

end
