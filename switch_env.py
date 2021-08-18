import os.path
import os

DE10_LITE = "CPU_Garage_de10lite.qsf"
KIWI = "CPU_Garage_kiwi.qsf"
NEUTRAL = "CPU_Garage.qsf"

platform_file = open("platform.sv", "w")

if os.path.isfile(DE10_LITE):
    # switch to DE10_LITE
    os.rename(NEUTRAL, KIWI)
    os.rename(DE10_LITE, NEUTRAL)
    platform_file.write("`define DE10_LITE")
else:
    # switch to kiwi
    os.rename(NEUTRAL, DE10_LITE)
    os.rename(KIWI, NEUTRAL)
    platform_file.write("`define KIWI")

platform_file.close()
