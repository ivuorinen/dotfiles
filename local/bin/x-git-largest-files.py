#!/usr/bin/env python

# Python script to find the largest files in a git repository.
# The general method is based on the script in this blog post:
# http://stubbisms.wordpress.com/2009/07/10/git-script-to-show-largest-pack-objects-and-trim-your-waist-line/
#
# The above script worked for me, but was very slow on my 11GB repository.
# This version has a bunch of changes to speed things up to a more
# reasonable time. It takes less than a minute on repos with 250K objects.
#
# The MIT License (MIT)
# Copyright (c) 2015 Nick Kocharhook
# Copyright (c) 2023 Ismo Vuorinen
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies
# or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
# INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
# PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
# HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
# CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE
# OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

# vim:tw=120:ts=4:ft=python:norl:

import argparse
import signal
import sys
from subprocess import PIPE, Popen, check_output

sortByOnDiskSize = False


class Blob:
    sha1 = ""
    size = 0
    packed_size = 0
    path = ""

    def __init__(self, line):
        cols = line.split()
        self.sha1, self.size, self.packed_size = cols[0], int(cols[2]), int(cols[3])

    def __repr__(self):
        return f"{self.sha1} - {self.size} - {self.packed_size} - {self.path}"

    def __lt__(self, other):
        if sortByOnDiskSize:
            return self.size < other.size
        else:
            return self.packed_size < other.packed_size

    def csv_line(self):
        return f"{self.size / 1024},{self.packed_size / 1024},{self.sha1},{self.path}"


def main():
    global sortByOnDiskSize

    signal.signal(signal.SIGINT, signal_handler)

    args = parse_arguments()
    sortByOnDiskSize = args.sortByOnDiskSize
    size_limit = 1024 * args.filesExceeding

    if args.filesExceeding > 0:
        print(f"Finding objects larger than {args.filesExceeding}kB…")
    else:
        print(f"Finding the {args.matchCount} largest objects…")

    blobs = get_top_blobs(args.matchCount, size_limit)

    populate_blob_paths(blobs)
    print_out_blobs(blobs)


def get_top_blobs(count, size_limit):
    """Get top blobs from git repository

    Args:
        count (int): How many items to return
        size_limit (int): What is the size limit

    Returns:
        dict: Dictionary of Blobs
    """
    sort_column = 4

    if sortByOnDiskSize:
        sort_column = 3

    verify_pack = (
        f"git verify-pack -v `git rev-parse --git-dir`/objects/pack/pack-*.idx | grep blob | sort -k{sort_column}nr"
    )
    output = check_output(verify_pack, shell=True).decode("utf-8").strip().split("\n")[:-1]

    blobs = {}
    # use __lt__ to do the appropriate comparison
    compare_blob = Blob(f"a b {size_limit} {size_limit} c")
    for obj_line in output:
        blob = Blob(obj_line)

        if size_limit > 0:
            if compare_blob < blob:
                blobs[blob.sha1] = blob
            else:
                break
        else:
            blobs[blob.sha1] = blob

            if len(blobs) == count:
                break

    return blobs


def populate_blob_paths(blobs):
    """Populate blob paths that only have a path

    Args:
      blobs (Blob, dict): Dictionary of Blobs
    """
    if len(blobs):
        print("Finding object paths…")

        # Only include revs which have a path. Other revs aren't blobs.
        rev_list = "git rev-list --all --objects | awk '$2 {print}'"
        all_object_lines = check_output(rev_list, shell=True).decode("utf-8").strip().split("\n")[:-1]
        outstanding_keys = list(blobs.keys())

        for line in all_object_lines:
            cols = line.split()
            sha1, path = cols[0], " ".join(cols[1:])

            if sha1 in outstanding_keys:
                outstanding_keys.remove(sha1)
                blobs[sha1].path = path

                # short-circuit the search if we're done
                if not len(outstanding_keys):
                    break


def print_out_blobs(blobs):
    if len(blobs):
        csv_lines = ["size,pack,hash,path"]

        for blob in sorted(blobs.values(), reverse=True):
            csv_lines.append(blob.csv_line())

        command = ["column", "-t", "-s", ","]
        p = Popen(command, stdin=PIPE, stdout=PIPE, stderr=PIPE)

        # Encode the input as bytes
        input_data = ("\n".join(csv_lines) + "\n").encode()

        stdout, _ = p.communicate(input_data)

        print("\nAll sizes in kB. The pack column is the compressed size of the object inside the pack file.\n")

        print(stdout.decode("utf-8").rstrip("\n"))
    else:
        print("No files found which match those criteria.")


def parse_arguments():
    parser = argparse.ArgumentParser(description="List the largest files in a git repository")
    parser.add_argument(
        "-c",
        "--match-count",
        dest="matchCount",
        type=int,
        default=10,
        help="Files to return. Default is 10. Ignored if --files-exceeding is used.",
    )
    parser.add_argument(
        "--files-exceeding",
        dest="filesExceeding",
        type=int,
        default=0,
        help=(
            "The cutoff amount, in KB. Files with a pack size"
            " (or physical size, with -p) larger than this will be printed."
        ),
    )
    parser.add_argument(
        "-p",
        "--physical-sort",
        dest="sortByOnDiskSize",
        action="store_true",
        default=False,
        help="Sort by the on-disk size. Default is to sort by the pack size.",
    )

    return parser.parse_args()


def signal_handler(signal, frame):
    print("Caught Ctrl-C. Exiting.")
    sys.exit(0)


# Default function is main()
if __name__ == "__main__":
    main()
