#!/bin/sh

# watches rtf files in this directory and creates/updates txt copies

../../bin/wach -o *.rtf, textutil -convert txt {}
