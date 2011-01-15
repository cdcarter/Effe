#include "ruby.h"
#include "swephexp.h"

static VALUE t_init(VALUE self)
{
	return self;
}

static VALUE t_swe_set_ephe_path(VALUE self, VALUE path)
{
	swe_set_ephe_path(StringValuePtr(path));
	return self;
}

static VALUE t_swe_set_topo(VALUE self, VALUE lon, VALUE lat, VALUE alt) {
	swe_set_topo(NUM2DBL(lon),NUM2DBL(lat),NUM2DBL(alt));
	return self;
}

static VALUE t_swe_julday(VALUE self, VALUE year, VALUE month, VALUE day, VALUE hour)
{
	double julday = swe_julday( NUM2INT(year), NUM2INT(month), NUM2INT(day), NUM2DBL(hour), SE_GREG_CAL );
	return rb_float_new(julday);
}


// this is great but it requires delta_t_bullshit
static VALUE t_swe_calc(VALUE self, VALUE julian_day, VALUE body)
{
	double results[6];
	char serr[AS_MAXCH];
	VALUE arr = rb_ary_new();
	int id_push = rb_intern("push");
	int i =0;
	
	if ( swe_calc(NUM2DBL(julian_day), NUM2INT(body), SEFLG_SPEED, results,  serr) < 0 )
		rb_raise (rb_eRuntimeError, serr);
	
	for ( i = 0; i < 6; i++)
		rb_funcall(arr, id_push, 1, rb_float_new(results[i]));
	
	return arr;
}

//so we use swe_calc_ut yaaay
static VALUE t_swe_calc_ut(VALUE self, VALUE julian_ut, VALUE body) {
	double results[6];
	char serr[AS_MAXCH];
	VALUE arr = rb_ary_new();
	int id_push = rb_intern("push");
	int i=0;
	
	if ( swe_calc_ut(NUM2DBL(julian_ut), NUM2INT(body), SEFLG_SPEED, results,  serr) < 0 )
		rb_raise (rb_eRuntimeError, serr);
	
	for ( i = 0; i < 6; i++)
		rb_funcall(arr, id_push, 1, rb_float_new(results[i]));
	
	return arr;
}

static VALUE t_swe_houses(VALUE self, VALUE julian_day, VALUE latitude, VALUE longitude, VALUE house_system)
{
	double cusps[13];
	double ascmc[10];
	char serr[AS_MAXCH];
	VALUE arr = rb_ary_new();
	int id_push = rb_intern("push");
	int i =0;
	
	if ( swe_houses(NUM2DBL(julian_day), NUM2DBL(latitude), NUM2DBL(longitude), NUM2CHR(house_system), cusps, ascmc) < 0 )
		rb_raise (rb_eRuntimeError, serr);
	
	for ( i = 0; i < 13; i++)
		rb_funcall(arr, id_push, 1, rb_float_new(cusps[i]));
	
	for ( i = 0; i < 10; i++)
		rb_funcall(arr, id_push, 1, rb_float_new(ascmc[i]));
	
	return arr;
}

static VALUE t_swe_get_planet_name(VALUE self, VALUE body_number)
{
	char snam[40];
	
	swe_get_planet_name(NUM2INT(body_number), snam);
	return rb_str_new2(snam);
}

static VALUE t_swe_house_pos(VALUE self, VALUE armc, VALUE geolat, VALUE eps, VALUE house_system, VALUE lon, VALUE lat)
{
	double xpin[2];
	char serr[AS_MAXCH];
	VALUE house;
	
	xpin[0] = NUM2DBL(lon);
	xpin[1] = NUM2DBL(lat);
	
	house = swe_house_pos(NUM2DBL(armc), NUM2DBL(geolat),  NUM2DBL(eps), NUM2CHR(house_system),   xpin, serr); 
	return rb_float_new(house);
}

static VALUE t_swe_deltat(VALUE self, VALUE tjd)
{
	VALUE ret;
	
	ret = swe_deltat(NUM2DBL(tjd));
	return rb_float_new(ret);
}

VALUE cSweph;

void Init_sweph4ruby()
{
	cSweph = rb_define_class("Sweph", rb_cObject);
	//pedro originals
	rb_define_method(cSweph, "initialize", t_init, 0);
	rb_define_method(cSweph, "swe_set_ephe_path", t_swe_set_ephe_path, 1);
	rb_define_method(cSweph, "swe_julday", t_swe_julday, 4);
	rb_define_method(cSweph, "swe_calc", t_swe_calc, 2);
	rb_define_method(cSweph, "swe_houses", t_swe_houses, 4);
	rb_define_method(cSweph, "swe_get_planet_name", t_swe_get_planet_name, 1);
	rb_define_method(cSweph, "swe_house_pos", t_swe_house_pos, 6);
	rb_define_method(cSweph, "swe_deltat", t_swe_deltat, 1);
	
	//cdcarter methods
	rb_define_method(cSweph, "swe_calc_ut", t_swe_calc_ut, 2);
	rb_define_method(cSweph, "swe_set_topo", t_swe_set_topo, 3);
	
}
