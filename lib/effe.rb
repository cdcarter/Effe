require 'ext/sweph4ruby'
$:.unshift(File.dirname(__FILE__))
require 'effe/bodies'

class Effe
	ROOT = File.dirname(File.expand_path(__FILE__)) + '/../'
	attr_accessor :time
	attr_accessor :lat, :long
	
	def initialize(time,lat,long)
		@s = Sweph.new
		@s.swe_set_ephe_path(ROOT+'ephe/')
		@s.swe_set_topo(long,lat,0)
		
		@time = time.gmtime
		
		@lat = lat
		@long = long
		
		@chart_bodies  = []
		@chart_houses  = []
		@chart_ascmcs  = []
		@chart_aspects = []
	end
	
	def julian
		@julian ||= @s.swe_julday(time.year,time.month,time.day,(time.hour + (time.min/60.0)))
	end
	
	def body(body)
		@s.swe_calc_ut(julian,body)
	end
	
	def houses(sys="P")
		@houses ||= @s.swe_houses(julian,lat,long,sys)[1..12]
	end
	
	def ascmcs(sys="P")
		@ascmcs ||= @s.swe_houses(julian,lat,long,sys)[13..20]
	end
	
	def chart_bodies
		if @chart_bodies.empty?
			Bodies.each_with_index do |body,idx|
				return if idx == 23 or idx == 24
				result = self.body(idx)
				degree = result[0]
				retrograde = !!(result[3] < 0)
				
				Signs.each_with_index do |sign,sidx|
					deg_low = (sidx * 30).to_f
					deg_high = ((sidx+1) * 30).to_f
					if (degree >= deg_low and degree <= deg_high)
						@chart_bodies << {
						  :id => idx,
							:body => body,
							:sign => sign,
							:sign_id => sidx,
							:degree => degree - deg_low,
							:degree_ut => degree,
							:retrograde => retrograde
						}
					end
				end
			end
		end
		return @chart_bodies
	end
	
	def chart_houses
		if @chart_houses.empty?
			self.houses.each_with_index do |degree_ut,idx|
				Signs.each_with_index do |sign,sidx|
					deg_low = (sidx * 30).to_f
					deg_high = ((sidx+1) * 30).to_f
					if (degree_ut >= deg_low and degree_ut <= deg_high)
						@chart_houses << {
							:id => idx+1,
							:house => Houses[idx],
							:sign => sign,
							:sign_id => sidx,
							:degree => degree_ut - deg_low,
							:degree_ut => degree_ut
						}
					end
				end
			end
		end
		return @chart_houses
	end
	
	def chart_ascmcs
		if @chart_ascmcs.empty?
			self.ascmcs.each_with_index do |degree_ut,idx|
				Signs.each_with_index do |sign,sidx|
					deg_low = (sidx * 30).to_f
					deg_high = ((sidx+1) * 30).to_f
					if (degree_ut >= deg_low and degree_ut <= deg_high)
						@chart_ascmcs << {
							:id => idx+1,
							:name => Ascendants[idx],
							:sign => sign,
							:sign_id => sidx,
							:degree => degree_ut - deg_low,
							:degree_ut => degree_ut
						}
					end
				end
			end
		end
		return @chart_ascmcs
	end
	
	private
	def sanitize(deg)
		if deg > 360
			deg - 360
		elsif deg < 360
			deg + 360
		else
			deg
		end
	end
end