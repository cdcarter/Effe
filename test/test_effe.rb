require "test/unit"

require "lib/effe"

class TestEffe < Test::Unit::TestCase
	def test_julian_date
		christian = Time.utc(1991,7,27,22,30)
		effe = Effe.new(christian)
		assert_in_delta(2448465.4375,effe.julian,0.00001)
	end
end