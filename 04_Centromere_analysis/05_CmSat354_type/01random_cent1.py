#!/usr/bin/env python3
from Bio import SeqIO
import math
import sys

if len(sys.argv) != 3:
    print("用法: python script.py input.fasta output.fasta")
    sys.exit(1)

input_file = sys.argv[1]
output_file = sys.argv[2]

REPEAT_LEN = 354
START_SEQ = "AGCATTGGCC"
NUM_SAMPLES = 500

def find_all_windows(seq, repeat_length=354, start_pattern="AGCATTGGCC"):
    """
    滑动搜索整个序列中所有以 start_pattern 开头的窗口（不强制步长）
    """
    windows = []
    pattern_len = len(start_pattern)
    i = 0
    while i < len(seq) - repeat_length:
        if seq[i:i+pattern_len] == start_pattern:
            window = seq[i:i+repeat_length]
            if len(window) == repeat_length:
                windows.append((i, window))
            i += 1  # 只移动1位以寻找下一个可能窗口（更密集）
        else:
            i += 1
    return windows

def evenly_sample(windows, desired_count=500):
    """
    从所有窗口中尽量均匀地抽取 desired_count 个
    """
    total = len(windows)
    if total == 0:
        return []

    if total <= desired_count:
        return windows

    step = total / desired_count
    sampled = [windows[math.floor(i * step)] for i in range(desired_count)]
    return sampled

# 读取序列
record = SeqIO.read(input_file, "fasta")
seq = str(record.seq)

# 查找窗口
windows = find_all_windows(seq, repeat_length=REPEAT_LEN, start_pattern=START_SEQ)
print(f"找到 {len(windows)} 个以 {START_SEQ} 开头的窗口")

# 采样
sampled = evenly_sample(windows, desired_count=NUM_SAMPLES)
print(f"采样了 {len(sampled)} 个窗口")

# 写入
with open(output_file, 'w') as f2:
    for idx, (pos, subseq) in enumerate(sampled):
        f2.write(f">window_{idx}_pos_{pos}\n{subseq}\n")

print(f"已保存到 {output_file}")

