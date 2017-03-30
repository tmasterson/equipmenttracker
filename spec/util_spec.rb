require "spec_helper"
require 'util'
require 'json'
require 'fileutils'

describe 'utility functions' do

    @jsonstr = '{"equipment": [{"equipment_no": "1", "serial": "1234", "type": "ht", "description": "", "assignments": {}}], "events": [{"name": "ss", "location": "pr", "start_date": "04/04/2017", "end_date": "04/05/2017", "specialties": []}], "specialties": [{"name": "tech", "chief": "keebler", "equipment": []}]}'

    it 'should load the data from a json file' do
        eq = [{'equipment_no' => '1', 'serial' => '123456789', 'type' => 'ht', 'description' => '', 'assignments' => {}}]
        ev = [{'name' => 'ss', 'location' => 'pr', 'start_date' => '04/04/2017', 'end_date' => '04/05/2017', 'specialties' => []}]
        sp = [{'name' => 'tech', 'chief' => 'keebler', 'equipment' => []}]
        jsonstr = {'equipment' => eq, 'events' => ev, 'specialties' => sp}
        File.open('test.json', 'w') do |f|
            f.puts JSON.generate(jsonstr)
        end
        data = loadJSON('test.json')
        expect(data['equipment'].length()).to eq(1)
        expect(data['lookup'].length()).to eq(1)
        expect(data['events'].length()).to eq(1)
        expect(data['specialties'].length()).to eq(1)
        FileUtils.rm('test.json')
    end

    it 'Should write the data to a json file' do
        data = {}
        data['equipment'] = []
        data['events'] = []
        data['specialties'] = []
        data['equipment'].push(Equipment.new('equipment_no' => '1','serial' => '1234','type' => 'ht'))
        data['events'].push(Event.new('name' => 'ss','location' => 'pr','start_date' => '04/04/2017','end_date' => '04/05/2017'))
        data['specialties'].push(Specialty.new('name' => 'tech','chief' => 'keebler'))
        writeJSON('test2.json', data)
        jsonFile = File.read('test2.json')
        jsonData = JSON.parse(jsonFile)
        expect(jsonData['equipment'].length).to eq(1)
        FileUtils.rm('test2.json')
    end
end

