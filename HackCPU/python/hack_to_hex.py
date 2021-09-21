from intelhex import IntelHex16bit
from pathlib import Path
import os

# This script converts assembled hack files (lines of 16 bits each) to intel hex format.

ROM_SIZE = 2**10
INSTR_WIDTH = 16  # change to match the setting in top.sv

CURR_DIR = os.path.dirname(os.path.realpath(__file__))
DIR_HACK = os.path.join(CURR_DIR, "../hack")
DIR_HEX = os.path.join(CURR_DIR, "../hex")


def main():
    for filename in os.listdir(DIR_HACK):
        filepath = os.path.join(DIR_HACK, filename)
        hack_to_hex(filepath)
    print("Done.")


def hack_to_hex(FILE_HACK):
    FILE_BIN = "rom.bin"  # temp file
    FILE_HEX_TEMP = "rom_temp.hex"  # temp file

    FILE_HEX = os.path.join(DIR_HEX, Path(FILE_HACK).stem)
    FILE_HEX += ".hex"

    # Correct the paths
    FILE_BIN = os.path.join(CURR_DIR, FILE_BIN)
    FILE_HEX_TEMP = os.path.join(CURR_DIR, FILE_HEX_TEMP)
    FILE_HEX = os.path.join(CURR_DIR, FILE_HEX)

    print(f"Converting file: {Path(FILE_HACK).stem}")

    with open(FILE_HACK) as file_hack, open(FILE_BIN, mode="wb") as file_bin:
        for line in file_hack:
            line = line[:-1]  # remove newline
            line = bytes([int(line[i:i+8], 2) for i in range(0, len(line), 8)])
            file_bin.write(line)

    ih = IntelHex16bit()
    ih.loadbin(FILE_BIN)
    ih.write_hex_file(FILE_HEX_TEMP, byte_count=INSTR_WIDTH//8)

    with open(FILE_HEX_TEMP, mode="r") as file_hex_temp, open(FILE_HEX, mode="w") as file_hex:
        for line in file_hex_temp:
            if line == ":00000001FF\n":  # eof
                break
            line = line[:3] + \
                format(int(line[3:7], 16)//(INSTR_WIDTH//8), 'X').zfill(4) + \
                line[7:]
            while len(line[7:-2]) < 2*INSTR_WIDTH//8:
                line = line[:-3] + "0000" + "00\n"  # pad
                # update byte count
                line = ":" + format(INSTR_WIDTH//8, "X").zfill(2) + line[3:]
            # calculate checksum
            checksum = calc_checksum(line)
            line = line[:-3] + checksum + "\n"
            file_hex.write(line)

    # pad with zeros
    file_size = file_len(FILE_HEX)  # also the next address to write
    pad_size = ROM_SIZE - file_size
    with open(FILE_HEX, mode="a") as file_hex:
        for i in range(file_size, file_size+pad_size):
            line = ":" + format(INSTR_WIDTH//8, "X").zfill(2) + format(i, "X").zfill(4) + \
                "00" + "0"*(2*INSTR_WIDTH//8)
            line = line + calc_checksum(line) + "\n"
            file_hex.write(line)

        file_hex.write(":00000001FF\n")  # eof

    os.remove(FILE_BIN)
    os.remove(FILE_HEX_TEMP)


def file_len(fname):
    with open(fname) as f:
        for i, l in enumerate(f):
            pass
    return i + 1


def calc_checksum(line):
    checksum = 0
    for i in range(1, len(line[1:len(line)-2]), 2):
        checksum += int(line[i:i+2], 16)
    checksum = format((~checksum + 1) % 256, 'X').zfill(2)
    return checksum


if __name__ == "__main__":
    main()
