import copy

orig_ids = [3163, 9161]

ids = copy.deepcopy(orig_ids)
start = 555
stages = 200
loop_count = 32767

for i in range(stages):
    res = (start + loop_count*ids[i % 2]) % (2**32)
    high_word = res >> 16
    low_word = res % (2**16)
    start = (high_word + low_word) % (2**16)
    ids[i % 2] = ids[i % 2]+1

print(hex(start))
print(hex(high_word))
print(f"Id in hex: {hex(orig_ids[0])}, {hex(orig_ids[1])}")
