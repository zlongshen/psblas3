include ../../Make.inc

LIBDIR=../../lib
INCDIR=../../include
HERE=..
OBJS=psb_s_prec_type_impl.o psb_d_prec_type_impl.o \
     psb_c_prec_type_impl.o psb_z_prec_type_impl.o \
     psb_d_diagprec_impl.o psb_d_bjacprec_impl.o psb_d_nullprec_impl.o \
     psb_dilu_fct.o\
     psb_dprecbld.o psb_dprecset.o psb_dprecinit.o \
     psb_s_diagprec_impl.o psb_s_bjacprec_impl.o psb_s_nullprec_impl.o \
     psb_silu_fct.o\
     psb_sprecbld.o psb_sprecset.o psb_sprecinit.o \
     psb_c_diagprec_impl.o psb_c_bjacprec_impl.o psb_c_nullprec_impl.o \
     psb_cilu_fct.o\
     psb_cprecbld.o psb_cprecset.o psb_cprecinit.o \
     psb_z_diagprec_impl.o psb_z_bjacprec_impl.o psb_z_nullprec_impl.o \
     psb_zilu_fct.o\
     psb_zprecbld.o psb_zprecset.o psb_zprecinit.o 

LIBNAME=$(PRECLIBNAME)
COBJS=
FINCLUDES=$(FMFLAG).. $(FMFLAG)$(INCDIR) 

lib:  $(OBJS) 
	$(AR) $(HERE)/$(LIBNAME) $(OBJS)
	$(RANLIB) $(HERE)/$(LIBNAME)

veryclean: clean

clean:
	/bin/rm -f $(OBJS) $(LOCAL_MODS)

