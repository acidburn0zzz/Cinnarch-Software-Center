bin_PROGRAMS = dbbuild

dbbuild_SOURCES = \
    dbbuild.vala \
    libmenu.vala \
    $(NULL)

dbbuild_VALAFLAGS = \
	--vapidir=$(srcdir)/../vapi \
    --pkg gio-2.0 \
    --pkg packagekit-glib2 \
    --pkg gee-1.0 \
    --pkg sqlheavy-0.1 \
    --pkg gtk+-3.0 \
	$(NULL)

dbbuild_CFLAGS = \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	-DPACKAGE_DATA_DIR="\"$(datadir)"\" \
	-DI_KNOW_THE_PACKAGEKIT_GLIB2_API_IS_SUBJECT_TO_CHANGE \
	$(GTK_CFLAGS) \
	$(GEE_CFLAGS) \
	$(GIO_CFLAGS) \
	$(PKGLIB_CFLAGS) \
	$(SQLH_CFLAGS) \
	$(ADDITIONAL_FLAGS) \
	-include config.h -w \
	$(NULL)

dbbuild_LDADD = \
	$(GTK_LIBS) \
	$(GEE_LIBS) \
	$(GIO_LIBS) \
	$(PKGLIB_LIBS) \
	$(SQLH_LIBS) \
	$(NULL)

CLEANFILES = \
	$(NULL)
