#!/usr/bin/env bash

sudo chmod -R a+r /sys/class/powercap/intel-rapl

sudo chgrp users /sys/class/powercap/intel-rapl/subsystem/intel-rapl-mmio:*/energy_uj
sudo chmod g+r /sys/class/powercap/intel-rapl/subsystem/intel-rapl-mmio:*/energy_uj