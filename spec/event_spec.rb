require "spec_helper"
require 'event'
require 'date'

describe Event do

    it "should error if given invalid arguments" do
        expect { Event.new() }.to raise_error('All the arguments must have valid data.')
    end

    it "should error if enddate is greater than start date" do
        sdate = (Date.today+10).strftime('%m/%d/%Y')
        edate = (Date.today+8).strftime('%m/%d/%Y')
        expect { Event.new('name' => 'test', 'location' => 'test', 'start_date' => sdate, 'end_date' => edate) }.to raise_error('Start date must be >= today and end date must be > start date')
    end

    it "should fail if start date < than today" do
        sdate = (Date.today-1).strftime('%m/%d/%Y')
        edate = (Date.today+8).strftime('%m/%d/%Y')
        expect { Event.new('name' => 'test', 'location' => 'test', 'start_date' => sdate, 'end_date' => edate) }.to raise_error('Start date must be >= today and end date must be > start date')
    end

    it "should do nothing if you try to assign anything but a specialty" do
        sdate = (Date.today+10).strftime('%m/%d/%Y')
        edate = (Date.today+12).strftime('%m/%d/%Y')
        e = Event.new('name' => 'test', 'location' => 'test', 'start_date' => sdate, 'end_date' => edate)
        e.assign('test1')
        expect(e.specialties.length).to eq(0)
    end

    it "should assign specialties" do
        sp = Specialty.new('name' => 'test', 'chief' => 'test')
        sdate = (Date.today+10).strftime('%m/%d/%Y')
        edate = (Date.today+12).strftime('%m/%d/%Y')
        e = Event.new('name' => 'test', 'location' => 'test', 'start_date' => sdate, 'end_date' => edate)
        e.assign(sp)
        expect(e.specialties.length).to eq(1)
    end

    it "should return a valid hash with to_hash" do
        sdate = (Date.today+10).strftime('%m/%d/%Y')
        edate = (Date.today+12).strftime('%m/%d/%Y')
        e = Event.new('name' => 'test', 'location' => 'test', 'start_date' => sdate, 'end_date' => edate)
        expect(e.to_hash).to be_instance_of(Hash)
    end
end
