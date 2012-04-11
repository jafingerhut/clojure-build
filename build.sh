#!/bin/bash

set -e

# Latest as of April 10, 2012.
CLOJURE_SHA="0ef92ba7731f8cd9ec7c6125f83ff8262c52932b"

[ ! -e clojure ] && git clone http://github.com/clojure/clojure

cd clojure

git fetch origin

git reset --hard $CLOJURE_SHA

for i in `git status --porcelain|cut -d \  -f 2`; do rm -rf $i; done

git reset --hard $CLOJURE_SHA

for i in `cat ../patches/patch-order.txt`; do
    echo "    applying" $i
    git am --keep-cr -s < ../patches/$i
done

MAVEN_OPTS="-Djava.awt.headless=true"

mvn package > ../build.log

if [ ! 0 -eq $? ]; then
    echo "build failed, see build.log"
else
    TAG=`date +%Y-%m-%d'T'%H%M%z`
    cd ..
    echo $TAG
    git tag -am $TAG $TAG
fi
