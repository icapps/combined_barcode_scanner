CURRENT=`pwd`
DIR_NAME=`basename "$CURRENT"`
if [ $DIR_NAME == 'tool' ]
then
  cd ..
fi

echo "flutter clean"
fvm flutter clean

cd pkgs/blue_bird_scanner
echo "flutter clean blue_bird_scanner"
fvm flutter clean
cd ..
cd ..

cd pkgs/fast_barcode_scanner
echo "flutter clean fast_barcode_scanner"
fvm flutter clean
cd ..
cd ..

cd pkgs/honeywell
echo "flutter clean honeywell"
fvm flutter clean
cd ..
cd ..

cd pkgs/unitech
echo "flutter clean unitech"
fvm flutter clean
cd ..
cd ..

cd pkgs/usb_keyboard_scanner
echo "flutter clean usb_keyboard_scanner"
fvm flutter clean
cd ..
cd ..

cd pkgs/zebra_datawedge
echo "flutter clean zebra_datawedge"
fvm flutter clean
cd ..
cd ..
