import os
from shutil import copyfile

FILE_NAME = "../memory/rom.txt"
FILE_NAME_BACKUP = "../memory/rom.bak"
ROM_SIZE = 2**12
# =========


def main():
    script_dir = os.path.dirname(__file__)  # <-- absolute dir the script is in
    abs_file_path = os.path.join(script_dir, FILE_NAME)
    file_size = file_len(abs_file_path)
    pad_size = ROM_SIZE - file_size - 3
    copyfile(abs_file_path, os.path.join(script_dir, FILE_NAME_BACKUP))

    rom_file = open(abs_file_path, mode="a")
    if pad_size > 0:
        rom_file.write("0000111111111111\n1110101010000111\n")  # jump to end
        rom_file.write((("0"*16)+"\n")*pad_size)  # pad with zeros
        rom_file.write("1110101010000111")  # jump to self (infinite loop)

    rom_file.close()

    print("file padded")


def file_len(fname):
    with open(fname) as f:
        for i, l in enumerate(f):
            pass
    return i + 1


if __name__ == "__main__":
    main()
