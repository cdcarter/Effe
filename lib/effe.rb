require 'ext/sweph4ruby'
$:.unshift(File.dirname(__FILE__))
require 'effe/bodies'

class Effe
	S = Sweph.new
	ROOT = File.dirname(File.expand_path(__FILE__)) + '/../'
	S.swe_set_ephe_path(ROOT+'ephe/')
	
	attr_accessor :time
	
	def initialize(time)
		@time = time.gmtime
	end
	
	def julian
		@julian ||= S.swe_julday(time.year,time.month,time.day,(time.hour + (time.min/60.0)))
	end
	
	def body(body)
		S.swe_calc_ut(julian,body)
	end
end