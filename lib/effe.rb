require 'ext/sweph4ruby'
class Effe
	S = Sweph.new
	ROOT = File.dirname(File.expand_path(__FILE__)) + '/../'
	S.swe_set_ephe_path(ROOT+'ephe/')
	
	attr_accessor :time
	
	def initialize(time)
		@time = time.gmtime
	end
	
	def julian
		S.swe_julday(time.year,time.month,time.day,(time.hour + (time.min/60.0)))
	end
end