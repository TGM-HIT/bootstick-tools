#!/bin/bash

for isoFile in isofiles/*.iso
do
    udisksctl loop-setup -f "$isoFile"
done

udisksctl mount -b /dev/loop[0-9]
