cd eth-node
rm -rf geth geth.log
sleep 1
./createGenesisBlock.sh
./start.sh
sleep 1
./attach.sh
cd ..
