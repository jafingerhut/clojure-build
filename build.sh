#!/bin/bash

set -e

# Latest as of May 18, 2012.
CLOJURE_SHA="eccde24c7fb63679f00c64b3c70c03956f0ce2c3"

[ ! -e clojure ] && git clone git://github.com/clojure/clojure.git

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
