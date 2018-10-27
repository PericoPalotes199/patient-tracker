describe EncounterPolicy do
  setup do
    @resident = users(:resident)
    @another_resident = users(:resident_1)
  end

  describe 'for resident' do
    it "new?" do
      assert_equal EncounterPolicy.new(@resident, nil).new?, true
      assert_equal EncounterPolicy.new(@resident, @another_resident.encounters).new?, true
    end

    it "create?" do
      assert_equal EncounterPolicy.new(@resident, Encounter).create?, true
    end

    it "show?" do
      assert_equal EncounterPolicy.new(@resident, @resident.encounters.first).show?, true
      assert_equal EncounterPolicy.new(@resident, @another_resident.encounters.first).show?, false
    end

    it "edit?" do
      assert_equal EncounterPolicy.new(@resident, @resident.encounters.first).edit?, true
      assert_equal EncounterPolicy.new(@resident, @another_resident.encounters.first).edit?, false
    end

    it "update?" do
      assert_equal EncounterPolicy.new(@resident, @resident.encounters.first).update?, true
      assert_equal EncounterPolicy.new(@resident, @another_resident.encounters.first).update?, false
    end

    it "destroy?" do
      assert_equal EncounterPolicy.new(@resident, @resident.encounters.first).destroy?, true
      assert_equal EncounterPolicy.new(@resident, @another_resident.encounters.first).destroy?, false
    end
  end
end
