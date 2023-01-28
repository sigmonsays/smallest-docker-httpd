
# This no longer works on 64bit

Compiling this code and making it runnable was only possible on 32bit

The 64bit wrappers in ld bloat it to approx 4k

# smallest-docker-httpd

A challenge from /r/docker on reddit

This is a 436 byte container which provides a functional HTTP server!

assemble the httpd.asm file and add the httpd file to the container

    echo httpd > manifest.txt
    tar cv --files-from manifest.txt | docker import - httpd


credit for the httpd assembly server goes to https://gist.github.com/xenomuta/4450368
