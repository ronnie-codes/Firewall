#!/bin/bash

while true; do
    pfctl -f ./config/pf.rules
    sleep 1
done
