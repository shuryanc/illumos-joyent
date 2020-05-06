/*
 * Copyright (c) 2006 Marcel Moolenaar
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

/*
 * Copyright (c) 2019, Joyent, Inc.
 */

#include <sys/cdefs.h>

#include <stand.h>
#include <bootstrap.h>
#include <efi.h>
#include <efilib.h>
#include <libzfs.h>

extern struct devsw vdisk_dev;

struct devsw *devsw[] = {
	&efipart_fddev,
	&efipart_cddev,
	&efipart_hddev,
#ifndef LOADER_DISABLE_SNP
	&efinet_dev,
#endif
	&vdisk_dev,
	&zfs_dev,
	NULL
};

struct fs_ops *file_system[] = {
	&gzipfs_fsops,
	&zfs_fsops,
	&dosfs_fsops,
	&ufs_fsops,
	&cd9660_fsops,
	&dosfs_fsops,
	&tftp_fsops,
	&nfs_fsops,
#ifdef LOADER_BZIP2_SUPPORT
	&bzipfs_fsops,
#endif
	NULL
};

struct netif_driver *netif_drivers[] = {
#ifndef LOADER_DISABLE_SNP
	&efinetif,
#endif
	NULL
};

extern struct console efi_console;
#if defined(__amd64__) || defined(__i386__)
extern struct console ttya;
extern struct console ttyb;
extern struct console ttyc;
extern struct console ttyd;
extern struct console nullconsole;
extern struct console spinconsole;
#endif

struct console *consoles[] = {
#if defined(__amd64__) || defined(__i386__)
	&efi_console,
	&ttya,
	&ttyb,
	&ttyc,
	&ttyd,
	&nullconsole,
	&spinconsole,
#endif
	NULL
};

#if defined(__amd64__) || defined(__i386__)
extern struct file_format multiboot2;
#endif

struct file_format *file_formats[] = {
#if defined(__amd64__) || defined(__i386__)
	&multiboot2,
#endif
	NULL
};
