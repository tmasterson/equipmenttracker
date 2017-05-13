class TrackerConfig

    attr_reader :upload_dir

    def initialize
        @upload_dir = "#{File.expand_path(__dir__)}/../uploads"
    end

    def event_path
        return "#{@upload_dir}/events"
    end

    def equipment_path
        "#{@upload_dir}/equipment"
    end

    def specialty_path
        "#{@upload_dir}/specialties"
    end

end
