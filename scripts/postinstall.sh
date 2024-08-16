#!/bin/bash

# Enable the Bluetooth service
sudo systemctl enable bluetooth
# Start the Bluetooth service
sudo systemctl start bluetooth

sudo systemctl enable ly.service

