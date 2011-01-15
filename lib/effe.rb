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
				if idx == 23
					idxr = 10
				elsif idx == 24
					idxr = 11
				else
					idxr = idx
				end
				result = self.body(idxr)
				degree = result[0]
				retrograde = !!(result[3] < 0)
				
				Signs.each_with_index do |sign,sidx|
					deg_low = (sidx * 30).to_f
					deg_high = ((sidx+1) * 30).to_f
					if (degree >= deg_low and degree <= deg_high)
						@chart_bodies << {
						  :id => idx,
							:name => body,
							:sign => sign,
							:sign_id => sidx,
							:degree => degree - deg_low,
							:degree_ut => degree,
							:retrograde => retrograde
						}
					end
				end
			end
			
			old_deg = -1000
			dist = 0
			@chart_bodies.each {|body|
				deg = body[:degree_ut] - chart_ascmcs[0][:degree_ut] + 180
				if (old_deg-deg).abs < 5
					dist = dist+1
				else
					dist = 0
				end
				body[:dist] = dist
				old_deg = deg
			}
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
	
	def test_aspect(body1, body2, deg1, deg2, delta, orb, type)
		if ((deg1 > (deg2 + delta - orb) and deg1 < (deg2 + delta + orb)) or 
		    (deg1 > (deg2 - delta - orb) and deg1 < (deg2 - delta + orb)) or
		    (deg1 > (deg2 + 360 + delta - orb) and deg1 < (deg2 + 360 + delta + orb)) or 
		    (deg1 > (deg2 - 360 + delta - orb) and deg1 < (deg2 - 360 + delta + orb)) or 
		    (deg1 > (deg2 + 360 - delta - orb) and deg1 < (deg2 + 360 - delta + orb)) or  
		    (deg1 > (deg2 - 360 - delta - orb) and deg1 < (deg2 - 360 - delta + orb)))
					if (deg1 > deg2)
						@chart_aspects << {
							:name => type,
							:body1 => body1[:name],
							:body2 => body2[:name],
							:degree1 => deg1,
							:degree2 => deg2
						}
					end
		end
	end
	
	def chart_aspects
		if @chart_aspects.empty?
			self.chart_bodies.each do |body1|
				deg1 = body1[:degree_ut] - self.chart_ascmcs[0][:degree_ut] + 180
				self.chart_bodies.each do |body2|
					deg2 = body2[:degree_ut] - self.chart_ascmcs[0][:degree_ut] + 180
					test_aspect(body1, body2, deg1, deg2, 180, 10, "Opposition")
					test_aspect(body1, body2, deg1, deg2, 150,  2, "Quincunx")
					test_aspect(body1, body2, deg1, deg2, 120,  8, "Trine")
					test_aspect(body1, body2, deg1, deg2,  90,  6, "Square")
					test_aspect(body1, body2, deg1, deg2,  60,  4, "Sextile")
					test_aspect(body1, body2, deg1, deg2,  30,  1, "Semi-sextile")
					test_aspect(body1, body2, deg1, deg2,   0, 10, "Conjunction")
				end
			end
		end
		return @chart_aspects
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