#!/bin/ksh -p
#
# CDDL HEADER START
#
# This file and its contents are supplied under the terms of the
# Common Development and Distribution License ("CDDL"), version 1.0.
# You may only use this file in accordance with the terms of version
# 1.0 of the CDDL.
#
# A full copy of the text of the CDDL should have accompanied this
# source.  A copy of the CDDL is also available via the Internet at
# http://www.illumos.org/license/CDDL.
#
# CDDL HEADER END
#

#
# Copyright (c) 2019 by Tim Chase. All rights reserved.
# Copyright (c) 2019 Lawrence Livermore National Security, LLC.
# Copyright 2019 Joyent, Inc.
#

. $STF_SUITE/include/libtest.shlib
. $STF_SUITE/tests/functional/cli_root/zpool_initialize/zpool_initialize.kshlib
. $STF_SUITE/tests/functional/cli_root/zpool_trim/zpool_trim.kshlib

#
# DESCRIPTION:
# After trimming, the disk is actually trimmed.
#
# STRATEGY:
# 1. Create a one-disk pool using a sparse file.
# 2. Initialize the pool and verify the file vdev is no longer sparse.
# 3. Trim the pool and verify the file vdev is again sparse.
#

function cleanup
{
	if poolexists $TESTPOOL; then
		destroy_pool $TESTPOOL
	fi

        if [[ -d "$TESTDIR" ]]; then
                rm -rf "$TESTDIR"
        fi

	log_must set_tunable32 zfs_trim_extent_bytes_min $trim_extent_bytes_min
}
log_onexit cleanup

LARGESIZE=$((MINVDEVSIZE * 4))
LARGEFILE="$TESTDIR/largefile"

# Reduce trim size to allow for tighter tolerance below when checking.
typeset trim_extent_bytes_min=$(get_tunable zfs_trim_extent_bytes_min)
log_must set_tunable32 zfs_trim_extent_bytes_min 4096

log_must mkdir "$TESTDIR"
log_must truncate -s $LARGESIZE "$LARGEFILE"
log_must zpool create $TESTPOOL "$LARGEFILE"

original_size=$(du "$LARGEFILE" | cut -f1)
original_size=$((original_size * 512))

log_must zpool initialize $TESTPOOL

while [[ "$(initialize_progress $TESTPOOL $LARGEFILE)" -lt "100" ]]; do
        sleep 0.5
done

new_size=$(du "$LARGEFILE" | cut -f1)
new_size=$((new_size * 512))
log_must test $new_size -gt $((8 * 1024 * 1024))

log_must zpool trim $TESTPOOL

while [[ "$(trim_progress $TESTPOOL $LARGEFILE)" -lt "100" ]]; do
        sleep 0.5
done

new_size=$(du "$LARGEFILE" | cut -f1)
new_size=$((new_size * 512))
log_must within_tolerance $new_size $original_size $((128 * 1024 * 1024))

log_pass "Trimmed appropriate amount of disk space"
