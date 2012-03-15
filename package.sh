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

package_gem() {
    log "Package GEM $name - $version"
    cd "$work"
    mkdir "$name"
    gem1.9.1 install --no-ri --no-rdoc --install-dir "$work/$name" $name
    find "$work/$name" -name '*.gem' | xargs -rn1 fpm -s gem -t deb --gem-gem /usr/bin/gem1.9.1 --gem-package-prefix=rubygem19 --depends "rubygems1.9.1"
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

cd "$base"
cat testing-gems.txt | while read line; do
name=$(echo "$line" | awk '{ print $1 }')
    version=$(echo "$line" | awk '{ print $2 }')
    echo "Will do $name at $version"
    package_gem
done
