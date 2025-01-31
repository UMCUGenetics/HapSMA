#! /usr/bin/env python3

import argparse
import vcfpy


def get_phaseset_from_vcf(input_vcf, region):
    phasesets = []
    reader = vcfpy.Reader.from_path(input_vcf)
    for record in reader.fetch(region):
        phaseset = record.calls[0].data.get('PS')  # Assuming single sample VCF
        if phaseset:
            phasesets.append(phaseset)

    if len(set(phasesets)) == 0:
        raise ValueError(
                f"No PhaseSet was detected within region {region}. Please increase this region"
            )

    elif len(set(phasesets)) == 1:
        return list(set(phasesets))[0]

    else:  # if no unique phaseset is detected in roi, pick most prevelant
        count_dic = {}
        total_count = 0
        for ps_group in phasesets:
            if ps_group not in count_dic:
                count_dic[ps_group] = 0
            count_dic[ps_group] += 1
            total_count += 1
        max_count = max(count_dic.values())
        if max_count/total_count > args.freq:
            max_keys = [key for key in count_dic if count_dic[key] == max_count]
            if len(max_keys) == 1:  # return only if a single unique phaseset is detected
                return max_keys[0]
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
    phaseset = get_phaseset_from_vcf(args.input_vcf, args.roi)
    print(phaseset)
