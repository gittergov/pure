#!/bin/bash

# Script to Refresh a clone of an ASM Database on a secondary host. 

echo ""
echo ""
echo "*****************************************************************************************"
echo "* Insert Demo record into the source database for validation of the refresh process."
echo "*****************************************************************************************"
echo ""
./insert_demo_rec.sh
echo ""
echo ""


echo ""
echo "*****************************************************************************************"
echo "* Shut down Clone database"
echo "*****************************************************************************************"
echo ""
./shutdown.sh
echo ""
echo ""


echo ""
echo "*****************************************************************************************"
echo "* Dismount ASM Disk Groups"
echo "*****************************************************************************************"
echo ""
./dismount_asm.sh
echo ""
echo ""


echo ""
echo "*****************************************************************************************"
echo "* Take a snapshot of the Source protection group. "
echo "* Copy volumes from the snapshot to corresponding volumes of the Clone database"
echo "*****************************************************************************************"
echo ""
./pure_snap.sh
echo ""
echo ""


echo ""
echo "*****************************************************************************************"
echo "* Mount ASM Disk Groups"
echo "*****************************************************************************************"
echo ""
./mount_asm.sh
echo ""
echo ""


echo ""
echo "*****************************************************************************************"
echo "* Startup the Clone Database"
echo "*****************************************************************************************"
echo ""
./startup.sh
echo ""
echo ""


echo ""
echo "*****************************************************************************************"
echo "* Verify validation record on Clone DB matches with the record inserted in the first step."
echo "*****************************************************************************************"
echo ""
./show_demo_rec.sh
echo ""
