import os.path
from shutil import copyfile

QSF_FOLDER = "qsf"
DE10_LITE = "CPU_Garage_de10lite.qsf"
KIWI = "CPU_Garage_kiwi.qsf"
NEUTRAL = "CPU_Garage.qsf"

print("This script generates the necessary configuration to compile the project.")
print("Select one of the platforms below:")
print("1 - μLab Kiwi")
print("2 - Terasic DE10-Lite")
choice = input("Your choice: ")

with open("platform.sv", "w") as platform_file:
    if choice == "2":
        # switch to DE10_LITE
        copyfile(os.path.join(QSF_FOLDER, DE10_LITE), NEUTRAL)
        platform_file.write("`define DE10_LITE")
    elif choice == "1":
        # switch to kiwi
        copyfile(os.path.join(QSF_FOLDER, KIWI), NEUTRAL)
        platform_file.write("`define KIWI")
