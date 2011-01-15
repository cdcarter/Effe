require 'rubygems'
require 'lib/sweph4ruby'
require 'test/unit'

class Rsweph_test < Test::Unit::TestCase


	def test_initialize()
		s = Rsweph.new()
		assert_equal($LOAD_PATH[1] , s.eph_path)
	end
	
	def test_swe_set_ephe_path()
		s = Rsweph.new()
		s.swe_set_ephe_path($LOAD_PATH[1])
		assert_equal($LOAD_PATH[1] , s.eph_path)
	end
	
	def test_swe_julday()
		s = Rsweph.new()
		assert_equal(2453577.0, s.swe_julday(2005, 7, 25, 12, 0))
	end
	
	def test_swe_calc()
				
		test_planet_values = []
		test_planet_values[0] = 122
		test_planet_values[1] = 359
		test_planet_values[2] = 140
		test_planet_values[3] = 152
		test_planet_values[4] = 28
		test_planet_values[5] = 192
		test_planet_values[6] = 121
		test_planet_values[7] = 340
		test_planet_values[8] = 316
		test_planet_values[9] = 262
		
		s = Rsweph.new()
		jul_day = s.swe_julday(2005, 7, 25, 12, 0)
		
		for i in 0..9
			assert_equal(test_planet_values[i], s.swe_calc(jul_day, i)[0].to_i())
		end
		
	end
	
	def test_swe_houses()
			
		test_houses_values = []
		test_houses_values[0] = 0
		test_houses_values[1] = 210
		test_houses_values[2] = 238
		test_houses_values[3] = 272
		test_houses_values[4] = 309
		test_houses_values[5] = 342
		test_houses_values[6] = 9
		test_houses_values[7] = 30
		test_houses_values[8] = 58
		test_houses_values[9] = 92
		test_houses_values[10] = 129
		test_houses_values[11] = 162
		
		s = Rsweph.new()
		jul_day = s.swe_julday(2005, 7, 25, 12, 0)
		houses = s.swe_houses(jul_day, 47.23, 8.33, "P")
		
		for i in 0..11
			assert_equal(test_houses_values[i], houses[i].to_i())
		end
	end
	
	def test_swe_get_planet_name()
		test_planet_values = []
		test_planet_values[0] = "Sun"
		test_planet_values[1] = "Moon"
		test_planet_values[2] = "Mercury"
		test_planet_values[3] = "Venus"
		test_planet_values[4] = "Mars"
		test_planet_values[5] = "Jupiter"
		test_planet_values[6] = "Saturn"
		test_planet_values[7] = "Uranus"
		test_planet_values[8] = "Neptune"
		test_planet_values[9] = "Pluto"
	
		s = Rsweph.new()
	
		for i in 0..9
			assert_equal(test_planet_values[i], s.swe_get_planet_name(i))
		end
	end
	
	def test_swe_house_pos()
		
		test_planet_house_values = []
		test_planet_house_values[0] = 9
		test_planet_house_values[1] =5
		test_planet_house_values[2] = 10
		test_planet_house_values[3] = 10
		test_planet_house_values[4] = 6
		test_planet_house_values[5] = 12
		test_planet_house_values[6] = 9
		test_planet_house_values[7] = 4
		test_planet_house_values[8] = 4
		test_planet_house_values[9] = 2
		
		s = Rsweph.new()
		
		jul_day = s.swe_julday(2005, 7, 25, 12, 0)
		
		houses = []
		houses = s.swe_houses(jul_day, 47.23, 8.33, "P")
		armc = houses[15]
		
		eps = s.swe_calc(jul_day, -1)[0]
		
		for i in 0..9
			body_data = []
			
			body_data = s.swe_calc(jul_day, i)
			house = s.swe_house_pos(armc, 47.23, eps, 'P', body_data[0], body_data[1])
			assert_equal(test_planet_house_values[i], house.to_i())
		end
		
	end
	
end



