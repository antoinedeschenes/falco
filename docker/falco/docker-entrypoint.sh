#!/usr/bin/env bash
#
# Copyright (C) 2020 The Falco Authors.
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# todo(leogr): remove deprecation notice within a couple of releases
if [[ ! -z "${SKIP_MODULE_LOAD}" ]]; then
    echo "* SKIP_MODULE_LOAD is deprecated and will be removed soon, use SKIP_DRIVER_LOADER instead"
fi

# Set the SKIP_DRIVER_LOADER variable to skip loading the driver
if [[ -z "${SKIP_DRIVER_LOADER}" ]] && [[ -z "${SKIP_MODULE_LOAD}" ]]; then
    echo "* Setting up /usr/src links from host"

    for i in "$HOST_ROOT/usr/src"/*
    do
        base=$(basename "$i")
        ln -s "$i" "/usr/src/$base"
    done

    GCC_AVAILABLE_VERSIONS=( $(ls /usr/bin | grep -Po "^gcc-\K[0-9]+") )
    GCC_MIN_VERSION="${GCC_AVAILABLE_VERSIONS[0]}"
    GCC_MAX_VERSION="${GCC_AVAILABLE_VERSIONS[-1]}"
    GCC_KERNEL_VERSION="$(grep -Po "gcc version \K[0-9]+" /proc/version 2>/dev/null)"

    if [[ $GCC_KERNEL_VERSION -lt $GCC_MIN_VERSION ]]; then
	# Version not parsed or lower than lowest installed version
        GCC_KERNEL_VERSION="${GCC_MIN_VERSION}"
    elif [[ $GCC_KERNEL_VERSION -gt $GCC_MAX_VERSION ]]; then
	# Version greater than highest installed version
	GCC_KERNEL_VERSION="${GCC_MAX_VERSION}"
    fi

    echo "* Setting up link /usr/bin/gcc-${GCC_KERNEL_VERSION}->/usr/bin/gcc from /proc/version"

    ln -sf "/usr/bin/gcc-${GCC_KERNEL_VERSION}" "/usr/bin/gcc"

    /usr/bin/falco-driver-loader ${DRIVER_LOADER_ARGS}
fi

exec "$@"
