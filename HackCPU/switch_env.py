import os.path
from shutil import copyfile

CURR_DIR = os.path.dirname(os.path.realpath(__file__))

QSF_FOLDER = os.path.join(CURR_DIR, "qsf")
DE10_LITE = os.path.join(QSF_FOLDER, "CPU_Garage_de10lite.qsf")
KIWI = os.path.join(QSF_FOLDER, "CPU_Garage_kiwi.qsf")
NEUTRAL = os.path.join(CURR_DIR, "CPU_Garage.qsf")
PLATFORM = os.path.join(CURR_DIR, "platform.sv")


print("This script generates the necessary configuration to compile the project.")
print("Select one of the platforms below:")
print("1 - μLab Kiwi")
print("2 - Terasic DE10-Lite")
choice = input("Your choice: ")

with open(PLATFORM, "w") as platform_file:
    if choice == "2":
        # switch to DE10_LITE
        copyfile(DE10_LITE, NEUTRAL)
        platform_file.write("`define DE10_LITE")
    elif choice == "1":
        # switch to kiwi
        copyfile(KIWI, NEUTRAL)
        platform_file.write("`define KIWI")

print("Done.")
