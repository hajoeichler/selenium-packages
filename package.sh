#! /bin/bash

log() {
    echo "$@"
}

clean() {
    log "Clean workdir"
    rm -rf "$work"
}

get() {
    log "Get source $name - $version"
    if [ -e "$download/$version/$name-$version.jar" ]; then
	log "Already downloaded."
	return
    fi
    mkdir -p "$download/$version"
    cd "$download/$version"
    wget --output-document="${name}-${version}.jar" http://selenium.googlecode.com/files/"${name}-${version}.jar"
}

package_jar() {
    log "Package JAR $name - $version"
    mkdir -p "$work/$version/usr/lib/selenium"
    cd "$work"
    cp "$download/$version/$name-${version}.jar" "$work/$version/usr/lib/selenium"
    fpm -s dir -t deb --name "$name" --version "$version" -a all -C "$work/$version" .
}

base=$(dirname $(readlink -f "$0"))
work="$base/work"
download="$base/download"

set -e

clean
name=selenium-server-standalone
version=2.20.0
get
package_jar
