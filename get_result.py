#!/usr/bin/env	python3
import argparse
import os

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', type=str, required=True, help='result folder')
    args = parser.parse_args()
    dir = args.d

    folder = './' + dir + '/'
    files = os.listdir(folder)
    ans = 0
    denominator = 0
    for F in files:
        f = open(folder + F)
        if F.startswith('mem'):
            continue
        if F.startswith('cpu') or F.startswith('cache'):
            for li in f.readlines():
                print(li)
            print('////////////////////////')
        else:
            ans += float(f.readline()) 
            denominator+=1
        f.close()

    print(ans/denominator)
