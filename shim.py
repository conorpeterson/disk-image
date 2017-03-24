#!/bin/python
#
# take space-separated output of processing sketch 
# and turn strings into bits and bits into bytes

from bitarray import bitarray

filepath = "/home/arden/Dropbox/projects/python/disk-image/disk_image_processing/"
filename = "2017-3-23-15:39:50-output.img"
outfile = "test-image.img"

def bitstring_to_byte( string_ ):

	b = bitarray()

	return bitarray( string_, endian='little').tobytes()

if __name__ == "__main__":

	print "loading strings"

	bitstrings = []
	with open(filepath + filename) as f:
		bitstrings = f.read().split(" ")

	print "dumping bits... this might take a while"

	with open(filepath + outfile, "w") as f:
		for b in bitstrings:
			f.write( bitstring_to_byte(b))

	print "done!"