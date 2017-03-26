#!/bin/python
#
# python reimplementation of image -> bits 
# as originally derived in processing (slow!)

import scipy.misc, math
from bitarray import bitarray

filepath = "./disk_image_preprocess/"
filename = "2017-3-24-16:21:10-output.jpg"
outpath = "./"
outfile = "padded-test.img"

#source image
image = scipy.misc.imread(filepath + filename, flatten=False, mode='RGB')
print "image is ", image.shape

#data geometry
bits_per_byte = 8
bytes_per_sector = 512
sectors_per_track = 18
tracks_per_disk = 160
tracks_per_side = 80
bits_per_track = bits_per_byte * bytes_per_sector * sectors_per_track

#disk geometry in inches
inner_radius = 0.5
outer_radius = 3.5

#disk geometry in pixels
width = len(image[1])
height = width
inner_rad_len = inner_radius * width / outer_radius
track_height = (width / 2 - inner_rad_len) / tracks_per_disk;

print "w",width,"h",height,"innerrad",inner_rad_len,"trackheight",track_height

def bit_at(x,y):

	# we don't need precision for pixel pulling
	x = int(x)
	y = int(y)

	r,g,b = image[x][y]
	# print r,g,b
	# exit()

	if r == 0:
		return "1"
	else:
		return "0"

def bitstring_to_byte( string_ ):
	# b_ = bitarray()
	return bitarray( string_, endian='little').tobytes()

def map(value, s_low, s_hi, o_low, o_hi):
    return float(o_low + (o_hi - o_low) * ((value - s_low)) / float((s_hi - s_low)))

def radialX(seg_len, angle):
	return seg_len * math.cos( math.radians(angle) )

def radialY(seg_len, angle):
	return seg_len * math.sin( math.radians(angle) )

if __name__ == "__main__":

	track_order = []
	bitstring = ""
	b = bitarray() 

	for track_index in range(0, tracks_per_side):
		track_order = [track_index] + track_order

	print "Stepping through pixels."
	print "This may take a while..."
	for track_index in range(0, len(track_order)):

		print "track ",track_index
		track_step = track_order[track_index]

		angle = -90.

		#calculate length of segment
		segment = track_step * track_height;


		for step in range(0, bits_per_track):
			angle = map(step, 0., float(bits_per_track), float(-90), float(270))

			#calculate location relative to 0,0
			x = float(radialX(segment, angle))
			y = float(radialY(segment, angle))

			#offset location relative to center
			x += float(width / 2);
			y += float(height / 2);

			#offset again by inner radius
			offx = float(radialX(inner_rad_len, angle));
			offy = float(radialY(inner_rad_len, angle));	 
			
			x += offx;
			y += offy;

			bit = bit_at(x,y)
			bitstring += bit

			# if step % 3000 == 0:
			# 	print "x",x,"y",y,"angle",angle,"length",segment

			if step % 8 == 0:
				bitstring += " "

	#legit half of real working disk
	realdisk = open("./fat12.img")
	realdisk.seek(0)
	#read includes byte 0, so read forward 737279 more.
	preamble = realdisk.read(737279)

	bitstrings = bitstring.split(" ")

	#write everything to file
	with open(outpath + outfile, "w") as f:

		print "writing fat12 preamble"
		f.write(preamble)
		
		print "writing significant bytes"
		for b in bitstrings:
			f.write( bitstring_to_byte(b))

	print "done!"