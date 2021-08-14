import copy

ORIG_IDS = [3163, 9161]

ids = copy.deepcopy(ORIG_IDS)
start = 555
stages = 200
loop_count = 32767

for i in range(stages):
    res = (start + loop_count*ids[i % 2]) % (2**32)
    high_word = res >> 16
    low_word = res % (2**16)
    start = (high_word + low_word) % (2**16)
    ids[i % 2] = ids[i % 2]+1

print(hex(high_word), hex(start))
print(f"{hex(ORIG_IDS[0])}, {hex(ORIG_IDS[1])}")
