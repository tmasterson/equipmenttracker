require "spec_helper"
require 'specialty'
require 'equipment'

describe Specialty do

    it 'should return an error if name or chief is empty' do
        expect{Specialty.new('chief' => 'test') }.to raise_error('All the arguments must have valid data.')
        expect{Specialty.new('name' => 'test') }.to raise_error('All the arguments must have valid data.')
    end

    it "Should do nothing if you try to assign anything but equipment to it" do
        sp = Specialty.new('name' => "tech", 'chief' => "sky")
        sp.assign('test')
        expect(sp.equipment.length).to eq(0)
    end

    it "should assign equipment to the specialty" do
        eq1 = Equipment.new('type' => 'box')
        eq2 = Equipment.new('type' => 'ht')
        sp = Specialty.new('name' => 'test','chief' => 'test')
        sp.assign(eq1)
        sp.assign(eq2)
        expect(sp.equipment.length).to eq(2)
    end

    it "should return a valid hash" do
        sp = Specialty.new('name' => 'test','chief' => 'test1').to_hash
        expect(sp['name']).to eql('test')
        expect(sp['chief']).to eql('test1')
    end
end
