import os.path
import os

DE10_LITE = "VGA_de10lite.qsf"
KIWI = "VGA_kiwi.qsf"
NEUTRAL = "VGA.qsf"

if os.path.isfile(DE10_LITE):
    # switch to DE10_LITE
    os.rename(NEUTRAL, KIWI)
    os.rename(DE10_LITE, NEUTRAL)
else:
    # switch to kiwi
    os.rename(NEUTRAL, DE10_LITE)
    os.rename(KIWI, NEUTRAL)
