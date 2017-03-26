# disk-image.py
## a means of writing images to the surface of a disk
### (if we had magnetic vision)


the core concept here is to take a typical .jpg or .png or whatever,
convert it to a black-and-white bitmap image, and use that pixel array to 
flip bits on the surface of a disk so the disk "displays" that same image,
if only we had magnetic vision. 

-------

### dependency hell

requires processing <=3.0, python 2.7, and the python package scipy and 
bitarray.

i'm going to tighten up this pipeline now that i've confirmed that 
everything is working and hopefully get everything ported into one 
relatively large python script.

### usage

#### 1. preprocess your images. 

load disk_image_preprocess.pde in processing, 
change the filename and filepath variables to point to your image. run 
the thing. bracket keys [] change the black-and-white threshold, arrow 
keys position the image in the target area, and comma and period keys 
change the scale of the image. hit f to save to disk.

#### 2. create a disk image. 

load disk-image.py in your favorite text editor 
and change the filepath and filename variables to point to your 
preprocessed image. optionally change the outfile and outpath variables 
to point to a yet-uncreated disk image file. save and close. run `python 
disk-image.py` and wait a few moments.

#### 3. write to disk. 

dust off your floppy disks, make sure you know where 
they are in the filesystem (/dev/sdc on my computer), and run `sudo dd 
if=/disk-image.img of=/dev/sdc`. this should take a couple of minutes.

#### 4. verify data on disk. 

since we're writing a valid fat16 filetable to 
track 0, most operating systems will show your disk as a perfectly 
normal, blank floppy. you'll (likely!) be able to write things to it 
because neither the floppy controller nor operating system cares if bits 
are up or down on the disk when the space is considered uninhabited by 
the filetable, so wait what we went to all that effort just to not see 
the results??

not to worry. `sudo dd if=/dev/sdc of=./image-on-disk.img` will give you 
a bit-for-bit copy of the disk you just created (try diffing it against 
disk-image.img!!). then just open up disk_to_image.pde in processing, 
change the filename variable to `image-on-disk.img` and hit run and you will 
generate a very. VERY. large PDF filled with vector art of the contents 
of your disk.

### current status 

everything is done and works. all of it, top to bottom. 

- images preprocessed
- disk images created
- disk images visualized

### future talk

better docs
further refine pipeline
pygame GUI 
do we /really/ need scipy for this? 
package for PyPy
