valac --pkg sqlheavy-0.1 --pkg gio-2.0 --pkg gee-1.0 --pkg gtk+-3.0  --pkg packagekit-glib2 --vapidir=../vapi -X -DI_KNOW_THE_PACKAGEKIT_GLIB2_API_IS_SUBJECT_TO_CHANGE *.vala -o dbbuild
