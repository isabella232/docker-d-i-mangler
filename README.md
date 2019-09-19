This repo builds a Moby image which has a single purpose: to make it (relatively)
easy to regenerate a modified Debian Installer ISO image.  For instance, if you
need to add udebs, include a preseed file, or modify the default boot configuration,
the Docker image this repo generates makes that just a little bit easier.

# Using the image

The existing, pre-built image should be sufficient for ordinary use.  To use it,
you just have to run a new container, including a volume which contains the
existing d-i ISO you wish to modify, and using environment variables to specify
the filename of the ISO to read, and the filename of the new ISO to write.

For example:

    mkdir /tmp/d-i-mangler
    wget -O /tmp/d-i-mangler/debian.iso \
        https://cdimage.debian.org/cdimage/archive/9.9.0/amd64/iso-cd/debian-9.9.0-amd64-netinst.iso
    docker run --rm -it -v /tmp/d-i-mangler:/mangler \
        -e ISO_FILE=/mangler/debian.iso \
        -e OUTPUT_FILE=/mangler/new-debian.iso \
        discourse/d-i-mangler

Note that the file paths specified in the environment variables are paths *within*
the container; the paths you use will need to reference the guest-side of the
volume in order for your new ISO to continue to exist after the container terminates.

Once you run the above set of commands, you'll be dropped into a shell inside the
container, whose working directory is the root directory of the ISO filesystem.

At this time, you can make any changes you like to the files in this directory --
add files, remove files, edit them, whatever you like.  Only changes within the
initial working directory will be reflected in the final image, so you can install
new packages in the container itself if you need to or otherwise write temporary files.

Once you've finished making changes, to build the new ISO image containing your
changes all you have to do is exit the shell.  Well... almost.  If the shell exits
with a non-zero status, then the process will be aborted and no new ISO will be
generated.  However, as long as the shell exits successfully (ie `exit 0`), a
new ISO image will be generated in the location you specify.


## Automated Operation

While fiddling around with a shell is fun and all, it isn't very scalable or
reproducible.  That's why you can specify a `SCRIPT` environment variable, which
points to an executable script to run.  Its working directory will be the root
of the ISO filesystem.  As with interactive mode, as long as the script exits successfully,
the new ISO image will be generated.


# Caveats

This image has only been tested on netinst amd64 Debian Stretch and Buster images.
Given that building installer ISOs is *very* arch-specific, it's unlikely that
this image will work for other Debian architectures, although it should be able to
handle other Debian releases without too much struggle.


# Development

If you need to build a new Docker image, simply run `make`.  As long as you have
the appropriate permissions, this will build the new image and push it to Docker
Hub.  Otherwise, specify an alternate location to push to with `make REPO=<whatever>`,
or else just build a local image with `make build`.
