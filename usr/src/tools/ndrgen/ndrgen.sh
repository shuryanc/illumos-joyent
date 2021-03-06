#!/bin/ksh -p
#
# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#

#
# Copyright 2009 Sun Microsystems, Inc.  All rights reserved.
# Use is subject to license terms.
#
# Copyright 2013 Nexenta Systems, Inc.  All rights reserved.
#

# This is a wrapper script around the ndrgen compiler (ndrgen1).

NDRPROG="${0}1"

# Note: most *.ndl files require an ANSI-compatible cpp,
# so we can NOT use /usr/lib/cpp or /usr/ccs/lib/cpp
# Wish there was an easier way to get an ANSI cpp.
CPP="${CC} -E"
CPPFLAGS="-DNDRGEN"
V_FLAG=

PROGNAME=`basename $0`

ndrgen_usage()
{
	if [[ $1 != "" ]] ; then
		print "$PROGNAME: ERROR: $1"
	fi

	echo "usage: $PROGNAME [options] file.ndl [file.ndl]..."
	echo "	options: -Y cc-path -Ddefine -Iinclude"
	exit 1
}

# Process the input ndl file ($1) generating C code on stdout.
process()
{

	# Put the standard top matter
	#
	# Want the include directive to have just
	# include "file.ndl" (no path) so...
	inc_ndl=`basename $1`
	cat - << EOF
/*
 * Please do not edit this file.
 * It was generated using ndrgen.
 */

#include <strings.h>
#include <libmlrpc/ndr.h>
#include "$inc_ndl"
EOF

	# Put optional custom top matter
	nawk 'BEGIN { copy=0; }
	/^\/\* NDRGEN_HEADER_BEGIN \*\// { copy=1; next; }
	/^\/\* NDRGEN_HEADER_END \*\// { copy=0; next; }
	/./ { if (copy==1) print; }' $1

	# now the real ndrgen output
	[ -n "$V_FLAG" ] &&
	  echo "$CPP $CPPFLAGS $1 | $NDRPROG" >&2
	$CPP $CPPFLAGS $1 | $NDRPROG
}


while getopts "D:I:Y:V" FLAG
do
	case $FLAG in
	D|I)	CPPFLAGS="$CPPFLAGS -${FLAG}${OPTARG}";;
	Y)	CPP="$OPTARG";;
	V)	V_FLAG="V";;
	*)	ndrgen_usage;;
	esac
done
shift $(($OPTIND - 1))

if [[ $# -lt 1 ]] ; then
	ndrgen_usage
fi

if [ ! -x $CPP ] ; then
	ndrgen_usage "cannot run $CPP"
fi

for i
do
	if [[ ! -r $i ]] ; then
		print "$PROGNAME: ERROR: cannot read $i"
		exit 1
	fi

	base=`basename $i .ndl`
	process $i > ${base}_ndr.c || {
	  echo "ndrgen error";
	  rm ${base}_ndr.c;
	}
done
