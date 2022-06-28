CURRENT=`pwd`
DIR_NAME=`basename "$CURRENT"`
if [ $DIR_NAME == 'tool' ]
then
  cd ..
fi

cd pkgs/blue_bird_scanner
echo "flutter pub get blue_bird_scanner"
fvm flutter packages get
cd ..
cd ..

cd pkgs/fast_barcode_scanner
echo "flutter pub get fast_barcode_scanner"
fvm flutter packages get
cd ..
cd ..

cd pkgs/honeywell
echo "flutter pub get honeywell"
fvm flutter packages get
cd ..
cd ..

cd pkgs/unitech
echo "flutter pub get unitech"
fvm flutter packages get
cd ..
cd ..

cd pkgs/usb_keyboard_scanner
echo "flutter pub get usb_keyboard_scanner"
fvm flutter packages get
cd ..
cd ..

cd pkgs/zebra_datawedge
echo "flutter pub get zebra_datawedge"
fvm flutter packages get
cd ..
cd ..

echo "flutter pub get"
fvm flutter packages get