#!/bin/bash

git add -A
git commit -m "$1"
git push origin master
ssh lifelessboring@lessboringhosting.com 'cd /home/lifelessboring/public_html/ludumdare25; git pull origin master;'
