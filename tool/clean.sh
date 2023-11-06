CURRENT=`pwd`
DIR_NAME=`basename "$CURRENT"`
if [ $DIR_NAME == 'tool' ]
then
  cd ..
fi

echo "flutter clean"
fvm flutter clean

cd packages/blue_bird_scanner
echo "flutter clean blue_bird_scanner"
fvm flutter clean
cd ..
cd ..

cd packages/fast_barcode_scanner
echo "flutter clean fast_barcode_scanner"
fvm flutter clean
cd ..
cd ..

cd packages/honeywell
echo "flutter clean honeywell"
fvm flutter clean
cd ..
cd ..

cd packages/unitech
echo "flutter clean unitech"
fvm flutter clean
cd ..
cd ..

cd packages/usb_keyboard_scanner
echo "flutter clean usb_keyboard_scanner"
fvm flutter clean
cd ..
cd ..

cd packages/zebra_datawedge
echo "flutter clean zebra_datawedge"
fvm flutter clean
cd ..
cd ..
