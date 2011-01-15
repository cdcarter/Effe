require 'ext/sweph4ruby'

# Encapsulates the functionality provided by sweph4ruby extension in a ruby class
class Rsweph
	
	# Body number constants
	SE_ECL_NUT = -1
	SE_SUN = 0
	SE_MOON = 1
	SE_MERCURY = 2
	SE_VENUS = 3
	SE_MARS = 4
	SE_JUPITER = 5
	SE_SATURN = 6
	SE_URANUS = 7
	SE_NEPTUNE = 8
	SE_PLUTO = 9
	SE_MEAN_NODE = 10
	SE_TRUE_NODE = 11
	SE_MEAN_APOG = 12
	SE_OSCU_APOG = 13
	SE_EARTH = 14
	SE_CHIRON = 15
	SE_PHOLUS = 16
	SE_CERES = 17
	SE_PALLAS = 18
	SE_JUNO = 19
	SE_VESTA = 20
	SE_NPLANETS = 21

	attr_reader :eph_path

	# Sets a default path for the ephemeris directory $LOAD_PATH[1]
	def initialize
		@eph_path = $LOAD_PATH[1]
		@s = Sweph.new()
		@s.swe_set_ephe_path(@eph_path)
	end
	
	# Sets the path for the ephemeris directory.
	#
	# For more information on the underlying Swiss Ephemeris library function:
	# http://www.astro.com/swisseph/swephprg.htm?lang=f#_Toc100044341
	def swe_set_ephe_path(path)
		self.initialize() if @s == nil
		@eph_path = path
		@s.swe_set_ephe_path(@eph_path)
	end
	
	# Returns the julian day as a float, for a given date and time.
	#
	# For more information on the underlying Swiss Ephemeris library function: 
	# http://www.astro.com/swisseph/swephprg.htm?lang=f#_Toc100044332
	def swe_julday(year, month, day, hour, minute)
		self.initialize() if @s == nil
		
		@s.swe_julday(year, month, day, hour + minute / 60)
	end
	
	# Calculates the position of a body (Planet, moon node, asteroid) given a julian day and a body number.
	#
	# Returns an array of 6 floats containing:
	# * [0] = longitude
	# * [1] = latitude
	# * [2] = distance
	# * [3] = speed in longitude
	# * [4] = speed in latitude
	# * [5] = speed in dist
	#
	# For more information on the underlying Swiss Ephemeris library function: 
	# http://www.astro.com/swisseph/swephprg.htm?lang=f#_Toc100044303
	def swe_calc(julian_day, body_number)
		self.initialize() if @s == nil
		
		raise "Invalid body number #{body_number}" if body_number >= SE_NPLANETS || body_number < SE_ECL_NUT
		
		@s.swe_calc(julian_day, body_number)
	end

	# Calculates the position of houses given a julian day, location (longitude, latitude) and the house system "PKORCAEVXHTBG".
	#
	# * house system allowed values and meanings are:
	# * ‘P’               Placidus
	# * ‘K’               Koch
	# * ‘O’              Porphyrius
	# * ‘R’               Regiomontanus
	# * ‘C’              Campanus
	# * ‘A’ or ‘E’      Equal (cusp 1 is Ascendant)
	# * ‘V’               Vehlow equal (Asc. in middle of house 1)
	# * ‘X’               axial rotation system
	# * ‘H’              azimuthal or horizontal system
	# * ‘T’               Polich/Page (“topocentric” system)
	# * ‘B’               Alcabitus
	# * ‘G’              Gauquelin sectors
	# * ‘M’              Morinus
	#
	# Returns an array of 21 floats containing:
	# *	[0] = 0
	# *	[1] = House 1
	# *	[2] = House 2
	# *	[3] = House 3
	# *	[4] = House 4
	# *	[5] = House 5
	# *	[6] = House 6
	# *	[7] = House 7
	# *	[8] = House 8
	# *	[9] = House 9
	# *	[10] = House 10
	# *	[11] = House 11
	# *	[12] = House 12
	# *	[13] = Ascendant
	# *	[14] = MC
	# *	[15] = ARMC
	# *	[16] = Vertex
	# *	[17] = equatorial ascendant
	# *	[18] = co-ascendant
	# *	[19] = co-ascendant
	# *	[20] = polar ascendant
	#
	# For more information on the underlying Swiss Ephemeris library function: 
	# http://www.astro.com/swisseph/swephprg.htm?lang=f#_Toc100044344
	def swe_houses(julian_day, latitude, longitude, house_system)
		self.initialize() if @s == nil
		
		@s.swe_houses(julian_day, latitude, longitude, house_system)
	end
	
	# Gets the name of a planet in English,  given its body number.
	#
	# For more information on the underlying Swiss Ephemeris library function: 
	# http://www.astro.com/swisseph/swephprg.htm?lang=f#_Toc100044309
	def swe_get_planet_name(body_number)
		self.initialize() if @s == nil
		
		raise "Invalid body number #{body_number}" if body_number >= SE_NPLANETS || body_number < SE_ECL_NUT
		
		@s.swe_get_planet_name(body_number)
	end
	
	# Calculate the house position of a body (Planet, moon node, asteroid).
	#
	# For more information on the underlying Swiss Ephemeris library function: 
	# http://www.astro.com/swisseph/swephprg.htm?lang=f#_Toc100044349
	def swe_house_pos(armc, geolat, eps, house_system, lon, lat)
		self.initialize() if @s == nil
		
		@s.swe_house_pos(armc, geolat, eps, house_system, lon, lat)
	end
	
	# For percision fanatics.
	#
	# For more information on the underlying Swiss Ephemeris library function: 
	# http://www.astro.com/swisseph/swephprg.htm?lang=f#_Toc100044334
	def swe_deltat(julian_day)
		self.initialize() if @s == nil
		
		@s.swe_deltat(julian_day)
	end
end

#puts File::PATH_SEPARATOR