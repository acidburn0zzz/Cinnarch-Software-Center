bin_PROGRAMS = light-software-center

light_software_center_SOURCES = \
    Frontend.vala \
    Utils.vala \
    Widgets/Entries.vala \
    Widgets/GridView.vala \
    Widgets/PagesView.vala \
    Widgets/ProgressInfo.vala \
    Widgets/Toolbar.vala \
    Widgets/Boxes.vala \
    Widgets/InfoMessage.vala \
    Widgets/Notebook.vala \
    Widgets/ModeButton.vala \
    Widgets/Pages/AppsInfo.vala \
    Widgets/Pages/AppsView.vala \
    Widgets/Pages/CategoriesView.vala \
    Widgets/Pages/HomePage.vala \
    $(NULL)

light_software_center_VALAFLAGS = \
	--vapidir=$(srcdir)/../vapi \
    --pkg appstore \
    --pkg gtk+-3.0 \
	$(NULL)

light_software_center_CFLAGS = \
	-DPACKAGE_LOCALE_DIR=\""$(prefix)/$(DATADIRNAME)/locale"\" \
	-DPACKAGE_DATA_DIR="\"$(datadir)"\" \
	-DI_KNOW_THE_PACKAGEKIT_GLIB2_API_IS_SUBJECT_TO_CHANGE \
	$(GTK_CFLAGS) \
	$(GLIB_CFLAGS) \
	$(APPSTORE_CFLAGS) \
	$(ADDITIONAL_FLAGS) \
	-include config.h -w \
	$(NULL)

light_software_center_LDADD = \
	$(GTK_LIBS) \
	$(GLIB_LIBS) \
	$(X11_LIBS) \
	$(APPSTORE_LIBS) \
	$(NULL)

CLEANFILES = \
	$(NULL)
