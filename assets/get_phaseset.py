#! /usr/bin/env python3

import argparse
import re
import vcfpy


def ParseVCF(input_vcf, region):
    chrom, start, stop = re.split(':|-', region)

    phasesets = []
    reader = vcfpy.Reader.from_path(input_vcf)
    for record in reader.fetch(chrom, begin=int(start), end=int(stop)):
        phaseset = record.calls[0].data.get('PS')  # Assuming single sample VCF
        if phaseset:
            phasesets.append(phaseset)

    if len(set(phasesets)) == 1:
        return list(set(phasesets))[0]
    else:  # if not unique phaseset is detected in roi, pick most prevelant
        count_dic = {}
        total_count = 0
        for ps_group in phasesets:
            if ps_group not in count_dic:
                count_dic[ps_group] = 0
            count_dic[ps_group] += 1
            total_count += 1
        for ps_group in count_dic:
            if count_dic[ps_group]/total_count > args.freq:
                return ps_group
    return 0


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('input_vcf', help='full path to input VCF')
    parser.add_argument('roi', help='region of interest [chr:start-stop]')
    parser.add_argument(
        '--freq',
        type=float,
        default=0.65,
        help='threshold to determine most likely PS if multiple are detected in roi [default = 0.65]'
    )
    args = parser.parse_args()
    phaseset = ParseVCF(args.input_vcf, args.roi)
    print(phaseset)
