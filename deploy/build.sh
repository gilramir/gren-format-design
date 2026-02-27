#!/bin/bash
set -e

THIS_SCRIPT_DIR=$(realpath $(dirname $0))

function setup_venv() {
    if [ ! -e "venv" ] ; then
        python3 -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt
    else
        source venv/bin/activate
    fi
}

function prep() {
    builddir="$1"
    installdir="$2"
    if [ -e "$builddir" ] ; then
        # Need the -f for .git objects
        rm -rf "$builddir"
    fi
    if [ -e "$installdir" ] ; then
        rm -r "$installdir"
    fi

    git clone ../.git "$builddir"
}

function record_build_id() {
    builddir="$1"
    cd "$builddir"/src

    git_short_hash=$(git describe --all --long | cut -d'-' -f3)
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    cat > BuildId.gren <<END
module BuildId exposing (..)

sha = "$git_short_hash"
timestamp = "$timestamp"
END
    cd ../..
}

function build_fe() {
    builddir="$1"
    cd "$builddir"
    if [ "$buildtype" = "staging" ] ; then
        make dev
    else
        make prod
        mv static/js/main.prod.js static/js/main.js
    fi
    cd ..
}

function munge_static() {
    builddir="$1"
    cd "$builddir"

    "$THIS_SCRIPT_DIR"/hash-assets

    cd ..
}

function munge_static_prod() {
    builddir="$1"

    mountpoint='gren-format-design'
    cd "$builddir"
    sed -i -e 's|mountPoint: ""|mountPoint: "'"$mountpoint"'"|' index.html
#    sed -i -e 's|"/static/|"/'"$mountpoint"'/static/|' index.html
    cd ..
}

function munge_static_staging() {
    builddir="$1"

    mountpoint='staging/gren-format-design'
    cd "$builddir"
    sed -i -e 's|mountPoint: ""|mountPoint: "'"$mountpoint"'"|' index.html
#    sed -i -e 's|"/static/|"/'"$mountpoint"'/static/|' index.html
    cd ..
}

function install_files() {
    builddir="$1"
    installdir="$2"

    sitedir="$installdir"
    mkdir -p "$sitedir"
    cp "$builddir"/index.html "$sitedir"/
    cp -r "$builddir"/static "$sitedir"/static/
}


buildtype="$1"
case "$buildtype" in
    "prod")
        ;;

    "stage")
        buildtype="staging"
        ;;

    "staging")
        ;;

    *)
        echo "Needs: prod or staging"
        exit 1
        ;;
esac

set -x

builddir="$buildtype-build"
installdir="$buildtype-install"

setup_venv
prep "$builddir" "$installdir"
record_build_id "$builddir"
build_fe "$builddir" "$buildtype"
munge_static "$builddir"
munge_static_"$buildtype" "$builddir"
install_files "$builddir" "$installdir"
