#!/usr/bin/bash

inotify-hookable \
    --watch-directories lib \
    --on-modify-command "prove -v t/test_class_tests.t"
