require 'rbcurse'
require 'config/config'
require 'csv'
require_relative 'model/event'
require_relative 'model/specialty'
require_relative 'model/item'

def trackertree config={}, &block
    events = [:TREE_WILL_EXPAND_EVENT, :TREE_EXPANDED_EVENT, :TREE_SELECTION_EVENT, :PROPERTY_CHANGE, :LEAVE, :ENTER ]
    block_event = nil
    # if no width given, expand to flows width
    useform = nil
    w = TrackerTree.new useform, config, &block
    w.width ||= :expand 
    w.height ||= :expand # TODO This has to come before other in stack next one will overwrite.
    _position w
    return w
end

def db_connect
    db_config = YAML::load(File.open('config/database.yml'))
    ActiveRecord::Base.establish_connection(db_config)
end

def import(type)
    config = TrackerConfig.new
    case type
    when 'events'
        path = config.event_path
    when 'specialties'
        path = config.specialty_path
    when 'equipment'
        path = config.equipment_path
    else
        path = ''
    end
    alist = Dir.glob("#{path}/*.csv")
    if alist.empty?
        alert("no files found at #{path}")
        return
    end
    selections = get_selections(alist, 'Select file(s)')
    errors = ''
    selections.each do |i|
        file = alist[i]
        lines = CSV.read(file).reject(&:empty?)
        keys = lines.shift
        data = lines.map do |values|
            Hash[keys.zip(values)]
        end
        data.each do |row|
            case type
            when 'events'
                row['start_date'] = Date.strptime(row['start_date'], '%m/%d/%Y')
                row['end_date'] = Date.strptime(row['end_date'], '%m/%d/%Y')
                record = Event.create(row)
            when 'specialties'
                record = Specialty.create(row)
            when 'equipment'
                if row['serial'].nil?
                    row['serial'] = get_serial(row['item_type'].to_s)
                end
                record = Item.create(row)
            end
            record.errors.full_messages.each do |message|
                errors << "#{row.to_s}\n   #{message}\n"
            end
        end
    end
    if !errors.empty?
        textdialog(errors, :title => "Errors importing #{type}")
    end
end

def get_serial(itemtype)
    serial = Item.where("item_type = '#{itemtype}'").maximum('serial')
    if serial.nil?
        serial = '0000'
    end
    serial = serial[3..9].to_i+1
    serial = "#{itemtype[0..2]}#{serial.to_s.rjust(7, '0')}"
    return serial
end

def get_selections(alist, title)
    listconfig = {}
    listconfig[:selection_mode] = :multiple
    listconfig[:show_selector] = true
    listconfig[:title] = title
    selected = popuplist(alist, listconfig)
    return selected
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
