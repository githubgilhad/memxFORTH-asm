#!/usr/bin/env python3
import sys
import random
import math

MAX24 = 0xFFFFFF
MAXarg = math.isqrt(MAX24)

def hex24(n):
    return f"${n:06X}"

def main():
    if len(sys.argv) != 2:
        print(f"Pouziti: {sys.argv[0]} pocet_prikladu")
        sys.exit(1)

    print(": x / - .h ;")
    count = int(sys.argv[1])

    for _ in range(count):
        a = random.randint(0, MAXarg)
        b = random.randint(0, MAXarg)
        product = (a * b) & MAX24

        print(f"{hex24(a)} {hex24(product)} {hex24(b)} x")

if __name__ == "__main__":
    main()
