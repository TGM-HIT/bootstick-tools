#!/bin/bash

for isoFile in isofiles
do
    udisksctl loop-setup -f "$isoFile"
done

udisksctl mount -b /dev/loop*
