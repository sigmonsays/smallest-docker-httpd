# smallest-docker-httpd

A challenge from /r/docker on reddit


assemble the httpd.asm file and add the httpd file to the container

    echo httpd > manifest.txt
    tar cv --files-from manifest.txt | docker import - httpd


