#!/bin/bash
sudo growpart /dev/nvme0n1 1
sudo resize2fs /dev/nvme0n1p1
