#!/bin/bash
set -x
rm -f httpd.o
nasm -felf32 httpd.asm
ld -m elf_i386 -s -o httpd httpd.o

echo httpd > manifest.txt
tar cv --files-from manifest.txt | docker import - httpd
