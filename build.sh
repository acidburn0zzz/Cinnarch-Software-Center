echo "To compile the following packages are needed:"
echo -e "\t * valac"
echo -e "\t * libglib2.0-dev"
echo -e "\t * libpackagekit-glib2-dev"
echo -e "\t * libsqlheavy-dev"


VALAC_PKGS="--pkg appstore --pkg gtk+-3.0 --pkg appstore"
VALAC_FLAGS="--vapidir=vapi/  -X 
-DI_KNOW_THE_PACKAGEKIT_GLIB2_API_IS_SUBJECT_TO_CHANGE"
BIN="light-software-center"
FILES=$(find src/ -type f -name "*.vala")

echo "Building $BIN"
valac $VALAC_PKGS $VALAC_FLAGS $FILES -o $BIN 
