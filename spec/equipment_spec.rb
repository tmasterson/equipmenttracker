require "spec_helper"
require 'equipment'

describe 'Equipment' do
    it "should error if no type given" do
        expect{Equipment.new}.to raise_error('There must be a type.')
    end

    it "should error if there is a duplicate serial number" do
        eq = Equipment.new('serial' => '12345','type' => 'radio')
        expect{Equipment.new('serial' => '12345','type' => 'radio')}.to raise_error('Duplicate serial numbers are not allowed.')
    end
end

