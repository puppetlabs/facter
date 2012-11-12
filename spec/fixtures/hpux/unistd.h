/* @(#) unistd.h $Date: 2008/08/13 14:45:21 $Revision: r11.31/2 PATCH_11.31 (B11.31.0903LR) */

/*
 * (C) Copyright 1996-2008 Hewlett-Packard Development Company, L.P.
 *
 * BEGIN_DESC
 *
 *  File:
 *	@(#)	common/include/sys/unistd.h	$Revision: $
 *
 * END_DESC
 */

#ifndef _SYS_UNISTD_INCLUDED
#define _SYS_UNISTD_INCLUDED

#ifndef _SYS_STDSYMS_INCLUDED
#    include <sys/stdsyms.h>
#endif   /* _SYS_STDSYMS_INCLUDED  */

#    include <sys/_inttypes.h>

/* Types */

#ifdef _INCLUDE_POSIX_SOURCE
#  ifndef NULL
#    include <sys/_null.h>
#  endif /* NULL */
#endif /* _INCLUDE_POSIX_SOURCE */

#if !defined(_INCLUDE_XOPEN_SOURCE) && !defined(_INCLUDE_XOPEN_SOURCE_EXTENDED)
/* The return value on failure of the sbrk(2) system call */
#define SBRK_FAILED     (void *)-1L
#endif

/* HP-UX supports 64-bit files on 32-bit systems */
#define _LFS64_STDIO    1
#define _LFS64_ASYNCHRONOUS_IO  1
#define _LFS_ASYNCHRONOUS_IO    1
#define _LFS_LARGEFILE          1
#define _LFS64_LARGEFILE        1

#if defined(_INCLUDE_XOPEN_SOURCE_EXTENDED) || defined(_INCLUDE_POSIX_SOURCE)
#    include <sys/types.h>
#endif /* _INCLUDE_XOPEN_SOURCE_EXTENDED || _INCLUDE_POSIX_SOURCE */

#ifdef _INCLUDE_HPUX_SOURCE
#  ifdef _KERNEL
     /* Structure for "utime" function moved to the unsupported section */
#  else /* ! _KERNEL */
#    include <utime.h>
#  endif /* ! _KERNEL */
#endif /* _INCLUDE_HPUX_SOURCE */

/* Function prototypes */

#ifndef _KERNEL
#ifdef __cplusplus
   extern "C" {
#endif /* __cplusplus */

#ifdef _INCLUDE_POSIX_SOURCE
#if defined(__ia64) && !defined(_LIBC)  
  /* pragmas needed to support -B protected */  
#pragma extern _exit, access, chdir, chown, close, ctermid
#pragma extern dup, dup2, execl, execle, execlp, execv, execve, execvp
#pragma extern fpathconf, getcwd, getgroups, getlogin 
#ifdef _INCLUDE_XOPEN_SOURCE_PRE_600
#pragma extern cuserid
#endif /* _INCLUDE_XOPEN_SOURCE_PRE_600 */
#   ifdef _REENTRANT
#     pragma extern getlogin_r
#   endif /* _REENTRANT */
#pragma extern  isatty, link
#   if !defined(__cplusplus) || !defined(_APP32_64BIT_OFF_T)
#     pragma extern lseek
#   endif /* !__cplusplus || !_APP32_64BIT_OFF_T */
#pragma builtin read
#pragma extern pathconf, pause, pipe, read, rmdir, setgid, setpgid
#pragma extern setsid, setuid, sleep, sysconf, tcgetpgrp, tcsetpgrp
#pragma extern ttyname  
#   ifdef _REENTRANT
#        pragma extern ttyname_r 
#   endif /* _REENTRANT */
#pragma builtin write
#pragma extern unlink, write, alarm, fork, getuid, geteuid, getgid
#pragma extern getegid, getpid, getpgrp, getppid 
#endif /* __ia64 && ! _LIBC */ 

     extern void _exit __((int));
     extern int access __((const char *, int));
     extern int chdir __((const char *));
     extern int chown __((const char *, uid_t, gid_t));
     extern int close __((int));
     extern char *ctermid __((char *));
#ifdef _INCLUDE_XOPEN_SOURCE_PRE_600
     extern char *cuserid __((char *));
#endif /* _INCLUDE_XOPEN_SOURCE_PRE_600 */
     extern int dup __((int));
     extern int dup2 __((int, int));
     extern int execl __((const char *, const char *, ...));
     extern int execle __((const char *, const char *, ...));
     extern int execlp __((const char *, const char *, ...));
     extern int execv __((const char *, char *const []));
     extern int execve __((const char *, char *const [], char *const []));
     extern int execvp __((const char *, char *const []));
     extern long fpathconf __((int, int));
     extern char *getcwd __((char *, __size_t));
     extern int getgroups __((int, gid_t []));
     extern char *getlogin __((void));
#   ifdef _REENTRANT
#     ifndef _PTHREADS_DRAFT4
        extern int getlogin_r __((char *, __size_t));
#     else /* _PTHREADS_DRAFT4 */
        extern int getlogin_r __((char *, int));
#     endif /* _PTHREADS_DRAFT4 */
#   endif
     extern int isatty __((int));
     extern int link __((const char *, const char *));
#   if !defined(__cplusplus) || !defined(_APP32_64BIT_OFF_T)
     _LF_EXTERN off_t lseek __((int, off_t, int)); 
#   endif /* !__cplusplus || !_APP32_64BIT_OFF_T */
     extern long pathconf __((const char *, int));
     extern int pause __((void));
     extern int pipe __((int *));
     extern ssize_t read __((int, void *, __size_t));
     extern int rmdir __((const char *));
     extern int setgid __((gid_t));
     extern int setpgid __((pid_t, pid_t));
     extern pid_t setsid __((void));
     extern int setuid __((uid_t));
     extern unsigned int sleep __((unsigned int));
     extern long sysconf __((int));
     extern pid_t tcgetpgrp __((int));
     extern int tcsetpgrp __((int, pid_t));
     extern char *ttyname __((int));
#   ifdef _REENTRANT
#     ifndef _PTHREADS_DRAFT4
        extern int ttyname_r __((int, char *, __size_t));
#     else /* _PTHREADS_DRAFT4 */
        extern int ttyname_r __((int, char *, int));
#     endif /* _PTHREADS_DRAFT4 */
#   endif
     extern int unlink __((const char *));
     extern ssize_t write __((int, const void *, __size_t));

#  ifdef _CLASSIC_POSIX_TYPES
     unsigned long alarm();
     extern int fork();
     extern unsigned short getuid();
     extern unsigned short geteuid();
     extern unsigned short getgid();
     extern unsigned short getegid();
     extern int getpid();
     extern int getpgrp();
     extern int getppid();
#  else
     extern unsigned int alarm __((unsigned int));
     extern pid_t fork __((void));
     extern gid_t getegid __((void));
     extern uid_t geteuid __((void));
     extern gid_t getgid __((void));
     extern pid_t getpgrp __((void));
     extern pid_t getpid __((void));
     extern pid_t getppid __((void));
     extern uid_t getuid __((void));
#  endif /* _CLASSIC_POSIX_TYPES */
#endif /* _INCLUDE_POSIX_SOURCE */


#ifdef _INCLUDE_POSIX2_SOURCE
#if defined(__ia64) && !defined(_LIBC)  
  /* pragmas needed to support -B protected */  
#  pragma extern optarg, opterr, optind, optopt, getopt, confstr
#endif /* __ia64 && ! _LIBC */ 

     extern char *optarg;
     extern int opterr;
     extern int optind;
     extern int optopt;
     /* fnmatch() has moved to <fnmatch.h> */
     extern int getopt __((int, char * const [], const char *));/* was <stdio.h> */
     extern __size_t confstr __((int, char *, __size_t));
#endif /* _INCLUDE_POSIX2_SOURCE */

#ifdef _INCLUDE_POSIX1C_SOURCE
#  if defined(__ia64) && !defined(_LIBC)  
    /* pragmas needed to support -B protected */  
#    pragma extern pthread_atfork
#  endif /* __ia64 && ! _LIBC */ 
#  ifdef _PROTOTYPES
     extern int pthread_atfork(void (*)(void), void (*)(void),
               				                   void (*)(void));
#  else /* not _PROTOTYPES */
     extern int pthread_atfork();
#  endif /* _PROTOTYPES */
#endif /* _INCLUDE_POSIX1C_SOURCE */


#ifdef _INCLUDE_XOPEN_SOURCE
#  if defined(__ia64) && !defined(_LIBC)  
#    /* pragmas needed to support -B protected */  
#    pragma extern crypt, encrypt, fsync, nice
#    ifdef _INCLUDE_XOPEN_SOURCE_PRE_600
#      pragma extern chroot, getpass
#    endif /* _INCLUDE_XOPEN_SOURCE_PRE_600 */
#    if defined(_XPG3) || defined(_INCLUDE_HPUX_SOURCE) || defined(_SVID3)
#      pragma extern rename 
#    endif /* _XPG3 || _INCLUDE_HPUX_SOURCE || _SVID3 */
#    if !defined(_INCLUDE_AES_SOURCE) || defined(_INCLUDE_XOPEN_SOURCE_EXTENDED)
#      ifdef _BIND_LIBCALLS
#        pragma builtin_milli swab
#      endif /* _BIND_LIBCALLS */
#      pragma extern swab
#    endif /* not _INCLUDE_AES_SOURCE || _INCLUDE_XOPEN_SOURCE_EXTENDED */
#  endif /* __ia64 && ! _LIBC */ 

#  ifdef _INCLUDE_XOPEN_SOURCE_PRE_600
        extern int chroot __((const char *));
        extern char *getpass __((const char *));
#  endif /* _INCLUDE_XOPEN_SOURCE_PRE_600 */
        extern char *crypt __((const char *, const char *));
        extern void encrypt __((char [64], int));
        extern int fsync __((int));
        extern int nice __((int));
#      if defined(_XPG3) || defined(_INCLUDE_HPUX_SOURCE) || defined(_SVID3)
#      ifdef _NAMESPACE_STD
namespace std {
        extern int rename __((const char *, const char *));     /* now in <stdio.h> */
}
using std::rename;
#      else /* !_NAMESPACE_STD */
        extern int rename __((const char *, const char *));	/* now in <stdio.h> */
#      endif /* _NAMESPACE_STD */
#      endif /* _XPG3 || _INCLUDE_HPUX_SOURCE || _SVID3 */
#      if !defined(_INCLUDE_AES_SOURCE) || defined(_INCLUDE_XOPEN_SOURCE_EXTENDED)
        extern void swab __((const void * __restrict, void * __restrict, ssize_t));
#      endif /* not _INCLUDE_AES_SOURCE || _INCLUDE_XOPEN_SOURCE_EXTENDED */
#endif /* _INCLUDE_XOPEN_SOURCE */


#ifdef _INCLUDE_AES_SOURCE
#  if !defined(_XPG4_EXTENDED) || defined(_INCLUDE_HPUX_SOURCE)
     /* Exclude from CASPEC  but keep in HPUX */
#    if defined(__ia64) && !defined(_LIBC)  
      /* pragmas needed to support -B protected */  
#      pragma extern environ
#    endif /* __ia64 && ! _LIBC */ 
     extern char **environ;
#  endif /* !_XPG4_EXTENDED || _INCLUDE_HPUX_SOURCE */

#  if defined(__ia64) && !defined(_LIBC)  
    /* pragmas needed to support -B protected */  
#    pragma extern readlink, fchown, symlink 
#  endif /* __ia64 && ! _LIBC */ 

#    ifdef _INCLUDE_XOPEN_SOURCE_EXTENDED
#      ifdef _INCLUDE_XOPEN_SOURCE_PRE_600
         extern int readlink __((const char *, char *, __size_t));  /*XPG4_EXT, HPUX*/
#      else /*  _INCLUDE_XOPEN_SOURCE_600 */
         extern ssize_t readlink __((const char * __restrict, char * __restrict, __size_t));  /*Unix 2003, HPUX*/
#      endif /* _INCLUDE_XOPEN_SOURCE_PRE_600 */
#    else /* ! _INCLUDE_XOPEN_SOURCE_EXTENDED */
       extern int readlink __((const char *, char *, int));  /* AES */
#    endif /* _INCLUDE_XOPEN_SOURCE_EXTENDED */
     extern int fchown __((int, uid_t, gid_t));
#    if !defined(__cplusplus) || !defined(_APP32_64BIT_OFF_T)
#      if defined(__ia64) && !defined(_LIBC)  
        /* pragmas needed to support -B protected */  
#        pragma extern ftruncate, truncate
#      endif /* __ia64 && ! _LIBC */ 
     _LF_EXTERN int ftruncate __((int, off_t));
     _LF_EXTERN int truncate __((const char *, off_t));
#    endif /* !__cplusplus || !_APP32_64BIT_OFF_T */
#    if !defined(_XPG4_EXTENDED) || defined(_INCLUDE_HPUX_SOURCE)
       /* Exclude from CASPEC  but keep in HPUX */
#      if defined(__ia64) && !defined(_LIBC) 
        /* pragmas needed to support -B protected */ 
#        pragma extern setgroups
#      endif /* __ia64 && ! _LIBC */ 
       extern int setgroups __((int, gid_t []));
#    endif /* !_XPG4_EXTENDED || _INCLUDE_HPUX_SOURCE */
     extern int symlink __((const char *, const char *));
#endif /*  _INCLUDE_AES_SOURCE */

#ifdef _INCLUDE_XOPEN_SOURCE_EXTENDED
#  ifdef _XPG4_EXTENDED
#    if defined(__ia64) && !defined(_LIBC)  
      /* pragmas needed to support -B protected */  
#      pragma extern setpgrp
#    endif /* __ia64 && ! _LIBC */ 
	extern pid_t setpgrp __((void));
#  else /* !_XPG4_EXTENDED */
#    ifndef _SVID3
#      if defined(__ia64) && !defined(_LIBC)  
        /* pragmas needed to support -B protected */  
#        pragma extern setpgrp
#      endif /* __ia64 && ! _LIBC */

#      ifdef _CLASSIC_ID_TYPES
	  extern int setpgrp();
#      else /* ! _CLASSIC_ID_TYPES */
	     extern pid_t setpgrp __((void));
#      endif /* _CLASSIC_ID_TYPES */
#    endif /* ! _SVID3 */
#  endif /* _XPG4_EXTENDED */

#if defined(__ia64) && !defined(_LIBC)  
  /* pragmas needed to support -B protected */  
#  pragma extern vfork
#endif /* __ia64 && ! _LIBC */ 
#  ifdef _CLASSIC_ID_TYPES
     extern int vfork();
#  else /* not _CLASSIC_ID_TYPES */
	extern pid_t vfork __((void));
#  endif /* not _CLASSIC_ID_TYPES */

#  if defined(_XPG4_EXTENDED) && !defined(_INCLUDE_HPUX_SOURCE)
	/* For CASPEC, look in stdlib.h for the _XPG4_EXTENDED definition */
	/* But for _INCLUDE_HPUX_SOURCE, maintain definitions here */
#  else /* !_XPG4_EXTENDED || _INCLUDE_HPUX_SOURCE*/
#    ifndef _MKTEMP_DEFINED
#      define _MKTEMP_DEFINED
#      if defined(__ia64) && !defined(_LIBC)  
        /* pragmas needed to support -B protected */  
#        pragma extern mkstemp, mktemp, ttyslot
#      endif /* __ia64 && ! _LIBC */ 
		extern int mkstemp __((char *));
		extern char *mktemp __((char *));
		extern int ttyslot __((void));
#    endif /*_MKTEMP_DEFINED */
#  endif /* _XPG4_EXTENDED && !_INCLUDE_HPUX_SOURCE */

#if defined(__ia64) && !defined(_LIBC)  
  /* pragmas needed to support -B protected */  
#  pragma extern fchdir, gethostid, gethostname
#  pragma extern getpgid, getsid, getwd
#    if !defined(__cplusplus) || !defined(_APP32_64BIT_OFF_T)
#      pragma extern lockf
#    endif /* !__cplusplus || !_APP32_64BIT_OFF_T */  
#  pragma extern lchown, setregid, setreuid, sync
#  pragma extern ualarm, usleep
#  ifdef _INCLUDE_XOPEN_SOURCE_PRE_600
#    pragma extern brk, sbrk, getdtablesize, getpagesize
#  endif /* _INCLUD_XOPEN_SOURCE_PRE_600 */
#endif /* __ia64 && ! _LIBC */  

#ifdef _INCLUDE_XOPEN_SOURCE_PRE_600 
	extern int brk __((void *));
        extern int getdtablesize __((void));
        extern int getpagesize __((void));
#endif /* _INCLUDE_XOPEN_SOURCE_PRE_600 */
	extern int fchdir __((int));
#    ifdef _XPG4_EXTENDED
	extern long gethostid __((void));
#    else /* !_XPG4_EXTENDED */
	extern int gethostid __((void));
#    endif /* _XPG4_EXTENDED */
	extern int gethostname __((char *, __size_t));
	extern pid_t getpgid __((pid_t));
	extern pid_t getsid __((pid_t));
	extern char *getwd __((char *));
#    if !defined(__cplusplus) || !defined(_APP32_64BIT_OFF_T)
 	_LF_EXTERN int lockf __((int, int, off_t));
#    endif /* !__cplusplus || !_APP32_64BIT_OFF_T */
	extern int lchown __((const char *, uid_t, gid_t));
#  ifdef _INCLUDE_XOPEN_SOURCE_PRE_600
#    ifdef _CLASSIC_XOPEN_TYPES
	extern char *sbrk __((int));
#    else /* not _CLASSIC_XOPEN_TYPES */
#      ifdef _INCLUDE_XOPEN_SOURCE_PRE_500      
	 extern void *sbrk __((int));
#      else /* _INCLUDE_XOPEN_SOURCE_500 */
         extern void *sbrk __((intptr_t));
#      endif /* _INCLUDE_XOPEN_SOURCE_PRE_500 */  
#    endif /* not _CLASSIC_XOPEN_TYPES */
#  endif /* _INCLUDE_XOPEN_SOURCE_PRE_600 */
	extern int setregid __((gid_t, gid_t)); 
	extern int setreuid __((uid_t, uid_t)); 
	extern void sync __((void));
#    ifdef _XPG4_EXTENDED
	extern useconds_t ualarm __((useconds_t, useconds_t));
	extern int usleep __((useconds_t));
#    else /* !_XPG4_EXTENDED */
	extern unsigned int ualarm __((unsigned int, unsigned int));
	extern int usleep __((unsigned int));
#    endif /* _XPG4_EXTENDED */
#endif /* _INCLUDE_XOPEN_SOURCE_EXTENDED */

#if defined(_INCLUDE_XOPEN_SOURCE_500)
#  if defined(__ia64) && !defined(_LIBC)
     /* pragmas needed to support -B protected */
#    pragma extern fdatasync
#    if !defined(_APP32_64BIT_OFF_T)
#      pragma extern pread, pwrite
#    endif /* !_APP32_64BIT_OFF_T */
#  endif /* __ia64 && ! _LIBC */ 
#  if !defined(__cplusplus) || !defined(_APP32_64BIT_OFF_T)
     _LF_EXTERN ssize_t pread __((int, void *, size_t, off_t));
     _LF_EXTERN ssize_t pwrite __((int, const void *, size_t, off_t));
#  endif /* !__cplusplus || !_APP32_64BIT_OFF_T */
     extern int fdatasync __((int));
#  if defined(_LARGEFILE64_SOURCE)
#    ifdef __LP64__
#      define pread64	pread
#      define pwrite64	pwrite
#    else /* __LP64__ */
#    if defined(__ia64) && !defined(_LIBC)
       /* pragmas needed to support -B protected */
#      pragma extern pread64, pwrite64
#    endif /* __ia64 && ! _LIBC */ 
     extern ssize_t pread64 __((int, void *, size_t, off64_t));
     extern ssize_t pwrite64 __((int, const void *, size_t, off64_t));
#    endif /* __LP64__ */
#  endif /* _LARGEFILE64_SOURCE */
#endif /* _INCLUDE_XOPEN_SOURCE_500 */


#ifdef _INCLUDE_XOPEN_SOURCE_600
# if defined(__ia64) && !defined(_LIBC)
   /* pragmas needed to support -B protected */
#   pragma extern setegid, seteuid
# endif /* __ia64 && ! _LIBC */ 
     extern int setegid __((gid_t));
     extern int seteuid __((uid_t));
#endif /* _INCLUDE_XOPEN_SOURCE_600 */


#ifdef _INCLUDE_HPUX_SOURCE
#  if defined(__ia64) && !defined(_LIBC)  
    /* pragmas needed to support -B protected */  
#    pragma extern endusershell, fsctl, getcdf, gethcwd, getpgrp2
#    pragma extern getusershell, getresgid, getresuid, hidecdf, initgroups
#    ifndef _XPG4_EXTENDED
#      pragma extern ioctl
#    endif /* !_XPG4_EXTENDED */
#    pragma extern logname, lsync
#    if !defined(__cplusplus) || !defined(_APP32_64BIT_OFF_T)
#      pragma extern prealloc 
#    endif /* !__cplusplus || !_APP32_64BIT_OFF_T */
#    pragma extern sethostname, setpgrp2, setresgid, setresuid 
#    pragma extern setusershell, sgetl, sputl, swapon, swapoff, ttyname
#    ifndef __STDC_32_MODE__
#      pragma extern __sysconfx 
#    endif /* __STDC_32_MODE__ */
#    ifdef _REENTRANT
#      ifndef _PTHREADS_DRAFT4
#        pragma extern ttyname_r 
#      else 
#        pragma extern ttyname_r, endusershell_r, getusershell_r 
#        pragma extern setusershell_r
#      endif /* _PTHREADS_DRAFT4 */
#    endif /* _REENTRANT */
#    pragma extern set_userthreadid
#  endif /* __ia64 && ! _LIBC */ 

     extern void endusershell __((void));
     extern int fsctl __((int, int, void *, __size_t));
     extern char *getcdf __((const char *, char *, __size_t));
     extern char *gethcwd __((char *, __size_t));
     extern int getpgrp2 __((pid_t));
     extern char *getusershell __((void));
     extern int getresgid __((gid_t *, gid_t *, gid_t *));
     extern int getresuid __((uid_t *, uid_t *, uid_t *));
     extern char *hidecdf __((const char *, char *, __size_t));
     extern int initgroups __((const char *, gid_t));
#  ifndef _XPG4_EXTENDED
     extern int ioctl __((int, int, ...));
#  endif /* !_XPG4_EXTENDED */
     extern char *logname __((void));
     extern void lsync __((void));
#  if !defined(__cplusplus) || !defined(_APP32_64BIT_OFF_T)
     _LF_EXTERN int prealloc __((int, off_t));
#  endif /* !__cplusplus || !_APP32_64BIT_OFF_T */
     extern int sethostname __((const char *, __size_t));
     extern int setpgrp2 __((pid_t, pid_t));
     extern int setresgid __((gid_t, gid_t, gid_t));
     extern int setresuid __((uid_t, uid_t, uid_t));
     extern void setusershell __((void));
     extern long sgetl __((const char *));
     extern void sputl __((long, char *));
     extern int swapon __((const char *, ...));
     extern int swapoff __((const char *, int));
     extern char *ttyname __((int));
#ifndef __STDC_32_MODE__
     extern int64_t __sysconfx __((int, int));
#endif /* __STDC_32_MODE__ */
#   ifdef _REENTRANT
#    ifndef _PTHREADS_DRAFT4
        extern int ttyname_r __((int, char *, __size_t));
#    else /* _PTHREADS_DRAFT4 */
        extern int ttyname_r __((int, char *, int));
        extern void endusershell_r __((char **));
        extern char *getusershell_r __((char **));
        extern void setusershell_r __((char **));
#    endif /* _PTHREADS_DRAFT4 */
#   endif
     extern int set_userthreadid __((int));

#if defined(__ia64) && !defined(_LIBC)  
  /* pragmas needed to support -B protected */  
#  ifdef _SVID3
#    pragma extern gettxt  
#  else 
#    pragma extern setpgrp3 
#  endif /* _SVID3 */
#endif /* __ia64 && ! _LIBC */ 

#  ifdef _CLASSIC_ID_TYPES
#    ifdef _SVID3
        extern char *gettxt();
#    endif /* _SVID3 */
#    ifndef _SVID3
     	extern int setpgrp3();
#    endif /* _SVID3 */
#  else /* not _CLASSIC_ID_TYPES */
#      ifdef _SVID3
	   extern char *gettxt __((const char *, const char *));
#      endif /* _SVID3 */
#      ifndef _SVID3
	   extern pid_t setpgrp3 __((void));
#      endif /* _SVID3 */
#  endif /* not _CLASSIC_ID_TYPES */
#endif /* _INCLUDE_HPUX_SOURCE */

# if defined(_LARGEFILE64_SOURCE)
#  ifdef __LP64__
#   define prealloc64	prealloc
#   define lockf64	lockf
#   define truncate64	truncate
#   define ftruncate64  ftruncate
#   define lseek64	lseek
#  else /* __LP64__ */
#   if defined(__ia64) && !defined(_LIBC)  
     /* pragmas needed to support -B protected */  
#     pragma extern prealloc64, lockf64, truncate64, ftruncate64
#     pragma extern lseek64
#   endif /* __ia64 && ! _LIBC */ 
     extern int prealloc64 __((int, off64_t));
     extern int lockf64 __((int, int, off64_t));
     extern int truncate64 __((const char *, off64_t));
     extern int ftruncate64 __((int, off64_t));
     extern off64_t lseek64 __((int, off64_t, int));
#  endif /* __LP64 */
# endif /* _LARGEFILE64_SOURCE */

# ifdef _APP32_64BIT_OFF_T
#   if defined(__ia64) && !defined(_LIBC)  
     /* pragmas needed to support -B protected */  
#     pragma extern __prealloc64, __lockf64, __truncate64, __ftruncate64
#     pragma extern __lseek64, __pread64, __pwrite64 
#   endif /* __ia64 && ! _LIBC */ 
extern int __prealloc64 __((int, off_t));
extern int __lockf64 __((int, int, off_t));
extern int __truncate64 __((const char *, off_t));
extern int __ftruncate64 __((int, off_t));
extern off64_t __lseek64 __((int, off_t, int));
extern ssize_t __pread64 __((int, void *, size_t, off64_t));
extern ssize_t __pwrite64 __((int, const void *, size_t, off64_t));
#  ifndef __cplusplus
static int truncate(a,b) __const char *a; off_t b; { return __truncate64(a,b); }
static int prealloc(a,b) int a; off_t b;	{ return __prealloc64(a,b); }
static int lockf(a,b,c) int a, b; off_t c;	{ return __lockf64(a,b,c); }
static int ftruncate(a,b) int a; off_t b;	{ return __ftruncate64(a,b); }
static off_t lseek(a,b,c) int a, c; off_t b;	  { return __lseek64(a,b,c); }
static ssize_t pread(a,b,c,d) int a; void *b; size_t c; off64_t d;
						  { return __pread64(a,b,c,d); }
static ssize_t pwrite(a,b,c,d) int a; const void *b; size_t c; off64_t d;
						 { return __pwrite64(a,b,c,d); }
#  endif /* __cplusplus */
# endif /* _APP32_64BIT_OFF_T */

#ifdef __cplusplus
   }
#endif /* __cplusplus */

#if defined(__cplusplus) && defined(_APP32_64BIT_OFF_T)
inline int prealloc __((int, off_t));
inline off_t lseek __((int, off_t, int)); 
inline int ftruncate __((int, off_t));
inline int truncate __((const char *, off_t));
inline int lockf __((int, int, off_t));
inline ssize_t pread __((int, void *, size_t, off64_t));
inline ssize_t pwrite __((int, const void *, size_t, off64_t));

inline int truncate(const char *a, off_t b) 	{ return __truncate64(a,b); }
inline int prealloc(int a, off_t b)		{ return __prealloc64(a,b); }
inline int lockf(int a, int b, off_t c)		{ return __lockf64(a,b,c); }
inline int ftruncate(int a, off_t b) 	 	{ return __ftruncate64(a,b); }
inline off_t lseek(int a, off_t b, int c) 	{ return __lseek64(a,b,c); }
inline ssize_t pread(int a, void *b, size_t c, off64_t d)
						{ return __pread64(a,b,c,d); }
inline ssize_t pwrite(int a, const void *b, size_t c, off64_t d)
						{ return __pwrite64(a,b,c,d); }
#   endif /* __cplusplus && _APP32_64BIT_OFF_T */

#endif /* not _KERNEL */


/* Symbolic constants */

#if defined(_INCLUDE_POSIX_SOURCE) || defined(_INCLUDE_POSIX2_SOURCE)

/* Symbolic constants for the access() function */
/* These must match the values found in <sys/file.h> */
#  ifndef R_OK
#    define R_OK	4	/* Test for read permission */
#    define W_OK	2	/* Test for write permission */
#    define X_OK	1	/* Test for execute (search) permission */
#    define F_OK	0	/* Test for existence of file */
#  endif /* R_OK */

/* Symbolic constants for the lseek() function */
#  ifndef SEEK_SET
#    define SEEK_SET	0	/* Set file pointer to "offset" */
#    define SEEK_CUR	1	/* Set file pointer to current plus "offset" */
#    define SEEK_END	2	/* Set file pointer to EOF plus "offset" */
#  endif /* SEEK_SET */

/* Versions of POSIX.1 we support */
#  define _POSIX1_VERSION_88	198808L	   /* We support POSIX.1-1988 */
#  define _POSIX1_VERSION_90	199009L	   /* We support POSIX.1-1990 */
#  define _POSIX1_VERSION_93	199309L	   /* We support POSIX.1b-1993 */
#  define _POSIX1_VERSION_95    199506L    /* We support POSIX.1-1995 */
#  define _POSIX1_VERSION_01    200112L    /* We support POSIX.1-2001 */

#  ifdef _POSIX1_1988
#    define _POSIX_VERSION	_POSIX1_VERSION_88
#  else /* not _POSIX1_1988 */
#    if !defined(_POSIX_C_SOURCE) || (_POSIX_C_SOURCE < 199309L)
#      define _POSIX_VERSION	_POSIX1_VERSION_90
#    else /* _POSIX_C_SOURCE && _POSIX_C_SOURCE >= 199309L */
#      if _POSIX_C_SOURCE < 199506L
#        define _POSIX_VERSION	_POSIX1_VERSION_93
#      else /* _POSIX_C_SOURCE >= 199506L */
#        if  _POSIX_C_SOURCE < 200112L
#          define _POSIX_VERSION	_POSIX1_VERSION_95
#        else /* _POSIX_C_SOURCE >= 200112L */
#          define _POSIX_VERSION	_POSIX1_VERSION_01
#        endif /* _POSIX_C_SOURCE < 200112L */
#      endif /* _POSIX_C_SOURCE < 199506L */
#    endif /* _POSIX_C_SOURCE && _POSIX_C_SOURCE >= 199309L */
#  endif /* not _POSIX1_1988 */

#    define STDIN_FILENO	0
#    define STDOUT_FILENO	1
#    define STDERR_FILENO	2

/* Compile-time symbolic constants */
#  define _POSIX_SAVED_IDS	1	/* If defined, each process has a
					 * saved set-user-ID and a saved 
					 * set_group-ID 
				         */
#  define _POSIX_JOB_CONTROL	2	/* If defined, it indicates that
					   the implementation supports job
					   control */
#  define _POSIX_VDISABLE       0xff    /* Character which disables local
					   TTY control character functions */
/* All the following macros are defined as 1 for Unix95 environment and 200112 for others */
#if defined(_INCLUDE_XOPEN_SOURCE_600)
#  define _POSIX_PRIORITY_SCHEDULING 200112L  /* If defined, POSIX.1b Priority
                                                 Scheduler extensions are
                                                 supported */
#  define _POSIX_TIMERS         200112L       /* If defined, POSIX.1b Clocks & Timers
                                                 extensions are supported */
#  define _POSIX_SEMAPHORES     200112L       /* If defined, POSIX.1b Semaphores
                                                 are supported */
#  define _POSIX_SYNCHRONIZED_IO     200112L  /* If defined, POSIX.1b Synchronized
                                                 IO option is supported */
#  define _POSIX_FSYNC          200112L       /* If defined, POSIX.1b File
                                                 Synchronization option is
                                                 supported. Must be defined if
                                                 _POSIX_SYNCHRONIZED_IO is */
#  define _POSIX_ASYNCHRONOUS_IO     200112L  /* If defined, POSIX.1b Asynchronous
                                                 IO option is supported */
#  define _POSIX_MEMLOCK     200112L          /* If defined, POSIX.1b mlockall and
                                                 munlockall are supported */
#  define _POSIX_MEMLOCK_RANGE     200112L    /* If defined, POSIX.1b mlock and
                                                 munlock are supported */
#  define _POSIX_SHARED_MEMORY_OBJECTS  200112L /* If defined, POSIX.1b shm_open and
                                                   shm_unlink are supported */
#  define _POSIX_REALTIME_SIGNALS    200112L  /* If defined, POSIX.1b Realtime
                                                 Signals extension option
                                                 is supported */
#  define _POSIX_MESSAGE_PASSING 200112L      /* if defined, POSIX.1b Message Passing
                                                 extensions are supported */

#  define _POSIX_THREAD_ATTR_STACKADDR  200112L /* if defined, thread stack address
                                                   attribute option is supported */
#  define _POSIX_THREAD_ATTR_STACKSIZE  200112L /* if defined, thread stack size
                                                   attribute option is supported */
#  define _POSIX_THREAD_PROCESS_SHARED  200112L /* if defined, process-shared
                                                   synchronization is supported */
#  define _POSIX_THREAD_SAFE_FUNCTIONS  200112L /* if defined, thread-safe
                                                   functions are supported */
#  define _POSIX_THREADS 200112L /* Base pthread functions are supported */

#  define _POSIX_BARRIERS                         -1
#  define _POSIX_CLOCK_SELECTION                  -1
#  define _POSIX_IPV6                             200112L
#  define _POSIX_MONOTONIC_CLOCK                  -1
#  define _POSIX_RAW_SOCKETS                      -1
#  define _POSIX_READER_WRITER_LOCKS              200112L
#  define _POSIX_SPAWN                            -1
#  define _POSIX_SPIN_LOCKS                       -1
#  define _POSIX_TIMEOUTS                         -1

#  define _POSIX_ADVISORY_INFO          -1
#  define _POSIX_CPUTIME                -1
#  define _POSIX_THREAD_CPUTIME         -1
#  define _POSIX_MAPPED_FILES           200112L
#  define _POSIX_MEMORY_PROTECTION      200112L 
#  define _POSIX_TYPED_MEMORY_OBJECTS   -1

#  define _POSIX_PRIORITIZED_IO         -1
#  define _POSIX_SPORADIC_SERVER        -1
#  define _POSIX_THREAD_PRIO_PROTECT    -1
#  define _POSIX_THREAD_PRIO_INHERIT	-1
#  define _POSIX_THREAD_SPORADIC_SERVER -1

/* Constants for tracing option */
#  define _POSIX_TRACE                  -1
#  define _POSIX_TRACE_EVENT_FILTER     -1
#  define _POSIX_TRACE_INHERIT          -1
#  define _POSIX_TRACE_LOG              -1

/* Constants for the Batch Environment Services and Utilities option */
#  define _POSIX2_PBS                   -1
#  define _POSIX2_PBS_ACCOUNTING        -1
#  define _POSIX2_PBS_CHECKPOINT        -1
#  define _POSIX2_PBS_LOCATE            -1
#  define _POSIX2_PBS_MESSAGE           -1
#  define _POSIX2_PBS_TRACK             -1

#  define _POSIX_REGEXP           1       /* Supports POSIX Regular Expressions */
#  define _POSIX_SHELL            1       /* Supports POSIX shell */

#else

#  define _POSIX_PRIORITY_SCHEDULING 1	/* If defined, POSIX.1b Priority
					   Scheduler extensions are
					   supported */
#  define _POSIX_TIMERS		1	/* If defined, POSIX.1b Clocks & Timers
					   extensions are supported */
#  define _POSIX_SEMAPHORES	1	/* If defined, POSIX.1b Semaphores
					   are supported */
#  define _POSIX_SYNCHRONIZED_IO     1  /* If defined, POSIX.1b Synchronized
                                           IO option is supported */
#  define _POSIX_FSYNC          1       /* If defined, POSIX.1b File
                                           Synchronization option is
                                           supported. Must be defined if
                                           _POSIX_SYNCHRONIZED_IO is */
#  define _POSIX_ASYNCHRONOUS_IO     1  /* If defined, POSIX.1b Asynchronous
					   IO option is supported */
#  define _POSIX_MEMLOCK     1  	/* If defined, POSIX.1b mlockall and
					   munlockall are supported */
#  define _POSIX_MEMLOCK_RANGE     1  	/* If defined, POSIX.1b mlock and
					   munlock are supported */
#  define _POSIX_SHARED_MEMORY_OBJECTS 	1 /* If defined, POSIX.1b shm_open and
					   shm_unlink are supported */
#  define _POSIX_REALTIME_SIGNALS    1	/* If defined, POSIX.1b Realtime
					   Signals extension option 
					   is supported */
#  define _POSIX_MESSAGE_PASSING 1	/* if defined, POSIX.1b Message Passing
					   extensions are supported */

/* Added for POSIX.1c (threads extensions) */
#  define _POSIX_THREAD_ATTR_STACKADDR	1 /* if defined, thread stack address
					     attribute option is supported */
#  define _POSIX_THREAD_ATTR_STACKSIZE	1 /* if defined, thread stack size
					     attribute option is supported */
#  define _POSIX_THREAD_PROCESS_SHARED	1 /* if defined, process-shared
					     synchronization is supported */
#  define _POSIX_THREAD_SAFE_FUNCTIONS	1 /* if defined, thread-safe
					     functions are supported */
#  define _POSIX_THREADS 1 /* Base pthread functions are supported */

#endif

#  ifdef _INCLUDE_XOPEN_SOURCE_PRE_600
#    define _POSIX_THREAD_PRIORITY_SCHEDULING	1 /* thread execution
						     scheduling is supported */ 
#  else
#    define _POSIX_THREAD_PRIORITY_SCHEDULING	-1
#  endif /*_INCLUDE_XOPEN_SOURCE_PRE_600 */

/* _POSIX_CHOWN_RESTRICTED, _POSIX_NO_TRUNC and _POSIX_SYNC_IO are not
 * defined here since they are pathname-dependent.  Use the pathconf() or 
 * fpathconf() functions to query for these values.
 */


/* Symbolic constants for sysconf() variables defined by POSIX.1-1988: 0-7 */

#  define _SC_ARG_MAX	      0	 /* ARG_MAX: Max length of argument to exec()
				    including environment data */
#  define _SC_CHILD_MAX	      1	 /* CHILD_MAX: Max # of processes per userid */
#  define _SC_CLK_TCK	      2	 /* Number of clock ticks per second */
#  define _SC_NGROUPS_MAX     3	 /* NGROUPS_MAX: Max # of simultaneous
				    supplementary group IDs per process */
#  define _SC_OPEN_MAX	      4	 /* OPEN_MAX: Max # of files that one process 
				    can have open at any one time */
#  define _SC_JOB_CONTROL     5	 /* _POSIX_JOB_CONTROL: 1 iff supported */
#  define _SC_SAVED_IDS	      6	 /* _POSIX_SAVED_IDS: 1 iff supported */
#  define _SC_1_VERSION_88    7	 /* _POSIX_VERSION: Date of POSIX.1-1988 */

/* Symbolic constants for sysconf() variables added by POSIX.1-1990: 100-199 */

#  define _SC_STREAM_MAX     100 /* STREAM_MAX: Max # of open stdio FILEs */
#  define _SC_TZNAME_MAX     101 /* TZNAME_MAX: Max length of timezone name */
#  define _SC_1_VERSION_90   102 /* _POSIX_VERSION: Date of POSIX.1-1990 */
#  define _SC_1_VERSION_93   103 /* _POSIX_VERSION: Date of POSIX.1b-1993 */
#  define _SC_1_VERSION_95   104 
#  define _SC_1_VERSION_01   105

/* Pick appropriate value for _SC_VERSION symbolic constant */

#  if (_POSIX_VERSION == _POSIX1_VERSION_88)
#    define _SC_VERSION _SC_1_VERSION_88
#  else
#    if (_POSIX_VERSION == _POSIX1_VERSION_90)
#      define _SC_VERSION _SC_1_VERSION_90
#    else
#      if (_POSIX_VERSION == _POSIX1_VERSION_93)
#          define _SC_VERSION _SC_1_VERSION_93
#      else
#          if (_POSIX_VERSION == _POSIX1_VERSION_95)
#             define _SC_VERSION _SC_1_VERSION_95
#          else
#             define _SC_VERSION _SC_1_VERSION_01
#          endif
#      endif
#    endif
#  endif

/* Symbolic constants for sysconf() variables added by POSIX.2: 200-299 */

#  define _SC_BC_BASE_MAX	200  /* largest ibase & obase for bc */
#  define _SC_BC_DIM_MAX	201  /* max array elements for bc */
#  define _SC_BC_SCALE_MAX	202  /* max scale value for bc */
#  define _SC_EXPR_NEST_MAX	204  /* max nesting of (...) for expr */
#  define _SC_LINE_MAX		205  /* max length in bytes of input line */
#  define _SC_RE_DUP_MAX	207  /* max regular expressions permitted */
#  define _SC_2_VERSION		211  /* Current version of POSIX.2 */
#  define _SC_2_C_BIND		212  /* C Language Bindings Option */
#  define _SC_2_C_DEV		213  /* C Development Utilities Option */
#  define _SC_2_FORT_DEV	214  /* FORTRAN Dev. Utilities Option */
#  define _SC_2_SW_DEV		215  /* Software Dev. Utilities Option */
#  define _SC_2_C_VERSION	216  /* version of POSIX.2 CLB supported */
#  define _SC_2_CHAR_TERM	217  /* termianls exist where vi works */
#  define _SC_2_FORT_RUN	218  /* FORTRAN Runtime Utilities Option */
#  define _SC_2_LOCALEDEF	219  /* localedef(1M) can create locales */
#  define _SC_2_UPE		220  /* User Portability Utilities Option */
#  define _SC_BC_STRING_MAX	221  /* max scale value for bc */
#  define _SC_COLL_WEIGHTS_MAX  222  /* max collation weights in locale */

    /* The following are obsolete and will be removed in a future release */
#  define _SC_COLL_ELEM_MAX	203  /* max bytes in collation element */
#  define _SC_PASTE_FILES_MAX	206  /* max file operands for paste */
#  define _SC_SED_PATTERN_MAX	208  /* max bytes of pattern space for sed */
#  define _SC_SENDTO_MAX	209  /* max bytes of message for sendto */
#  define _SC_SORT_LINE_MAX	210  /* max bytes of input line for sort */

/* Symbolic constants for sysconf() variables added by POSIX.4: 400-499 */
#  define _SC_TIMER_MAX		400   /* max number of timers per process */
#  define _SC_FSYNC		401   /* yes: POSIX.1b File Synchronization */
#  define _SC_SYNCHRONIZED_IO	402   /* yes: POSIX.1b Synchronized IO */
#  define _SC_PRIORITY_SCHEDULING 403 /* Priority scheduling supported */
#  define _SC_TIMERS		404   /* POSIX.1b Clocks and Timers supported*/
#  define _SC_DELAYTIMER_MAX	405   /* max timer overrun count */
/*   these following POSIX.4 constants represent unsupported functionality */
#  define _SC_ASYNCHRONOUS_IO	406   /* POSIX.1b asynchronous I/O supported */
#  define _SC_MAPPED_FILES	407   /* POSIX.1b mapped files supported */
#  define _SC_MEMLOCK		408   /* POSIX.1b memory locking supported */
#  define _SC_MEMLOCK_RANGE	409   /* POSIX.1b memory range locking */
#  define _SC_MEMORY_PROTECTION	410   /* POSIX.1b memory protection supported*/
#  define _SC_MESSAGE_PASSING	411   /* POSIX.1b message queues supported */
#  define _SC_PRIORITIZED_IO	412   /* POSIX.1b prioritized I/O supported */
#  define _SC_REALTIME_SIGNALS	413   /* POSIX.1b realtime signals supported */
#  define _SC_SEMAPHORES	414   /* POSIX.1b semaphores supported */
#  define _SC_SHARED_MEMORY_OBJECTS 415 /* POSIX.1b shared memory supported */

#  define _SC_AIO_LISTIO_MAX	416   /* max I/O ops in a list I/O call */
#  define _SC_AIO_MAX		417   /* max outstanding async I/O ops */
#  define _SC_AIO_PRIO_DELTA_MAX 418  /* max aio/scheduling prio delta */
#  define _SC_MQ_OPEN_MAX	419   /* max open msg queues per process */
#  define _SC_MQ_PRIO_MAX	420   /* max different message priorities */
#  define _SC_RTSIG_MAX		421   /* # of realtime signals */
#  define _SC_SEM_NSEMS_MAX	422   /* max open semaphores per process */
#  define _SC_SEM_VALUE_MAX	423   /* max semaphore value */
#  define _SC_SIGQUEUE_MAX	424   /* max queued signals pending/sender */

/* Symbolic constants for sysconf() variables added by POSIX.1c (threads) */
#  define _SC_THREAD_DESTRUCTOR_ITERATIONS 430 /* PTHREAD_DESTRUCTOR_ITERATIONS:
						  max trys to destroy thread-
						  specific data on thrd exit */
#  define _SC_THREAD_KEYS_MAX		431 /* PTHREAD_KEYS_MAX: max num data
					       keys per proc */
#  define _SC_THREAD_STACK_MIN		432 /* PTHREAD_STACK_MIN: min size of
					       thread stack */
#  define _SC_THREAD_THREADS_MAX	433 /* PTHREAD_THREADS_MAX: max threads
					       per proc */

#  define _SC_THREADS			434 /* _POSIX_THREADS:
					       1 iff POSIX threads supported */
#  define _SC_THREAD_ATTR_STACKADDR	435 /* _POSIX_THREAD_ATTR_STACKADDR:
					       1 iff stack address attribute
					       supported */
#  define _SC_THREAD_ATTR_STACKSIZE	436 /* _POSIX_THREAD_ATTR_STACKSIZE:
					       1 iff stack size attribute
					       supported */
#  define _SC_THREAD_PRIORITY_SCHEDULING 437 /*_POSIX_THREAD_PRIORITY_SCHEDULING
					       1 iff thread execution
				               scheduling supported */
#  define _SC_THREAD_PRIO_INHERIT	438 /* _POSIX_THREAD_PRIO_INHERIT:
					       1 iff priority inheritance is
					       supported */
#  define _SC_THREAD_PRIO_PROTECT	439 /* _POSIX_THREAD_PRIO_PROTECT:
					       1 iff priority protection is
					       supported */
#  define _SC_THREAD_PROCESS_SHARED	440 /* _POSIX_THREAD_PROCESS_SHARED:
					       1 iff process-shared
					       synchronization is supported */
#  define _SC_THREAD_SAFE_FUNCTIONS	441 /* _POSIX_THREAD_SAFE_FUNCTIONS:
					       1 iff thread-safe functions are
					       supported */
#  define _SC_GETGR_R_SIZE_MAX 		442 /* Maximum size of getgrgid_r() and 
					       and getgrnam_r() data buffers */
#  define _SC_GETPW_R_SIZE_MAX 		443 /* Maximum size of getpwuid_r() and 
					       and getpwnam_r() data buffers */
#  define _SC_LOGIN_NAME_MAX 		444 /* Value of LOGIN_NAME_MAX */
#  define _SC_TTY_NAME_MAX 		445 /* Value of TTY_NAME_MAX */
#  define _SC_CACHE_LINE_SIZE   	446 /* Size of Cache line in bytes*/
#  define _SC_I_CACHE_SIZE      	447 /* Size of I-Cache in bytes */
#  define _SC_D_CACHE_SIZE      	448 /* Size of D-Cache in bytes */
#  define _SC_I_CACHE_LINE_SIZE 	449 /* Size of I-Cache line in bytes */
#  define _SC_D_CACHE_LINE_SIZE 	450 /* Size of D-Cache line in bytes */
#  define _SC_I_CACHE_WT        	451 /* 0 means write-back I-Cache, 
						1 means write-through I-Cache */
#  define _SC_D_CACHE_WT        	452 /* 0 for write-back D-Cache,
       		                                1 for write-through D-Cache */
#  define _SC_I_CACHE_CST       	453 /* 0 means I-Cache is not issuing coherent
               		                        operations, 1 means I-Cache is issuing
                       		                coherent operations */
#  define _SC_D_CACHE_CST       	454 /* 0 means D-Cache is not issuing cohere
                               		        operations, 1 means D-Cache is issuing
                                       		coherent operations */
#  define _SC_I_CACHE_F_SEL     	455 /* tells software how to flush a range 
                                       		of address from the I_cache and has 
                                       		following meaning:
                                      		 0 - Both FIC and FDC must be used
                                       		 1 - Only need FDC
                                       		 2 - Only need FIC
                                       		 3 - Either FIC or FDC may be used */
#  define _SC_D_CACHE_F_SEL     	456 /* tells software how to flush a range 
                                       		of address from the D_cache and has 
                                       		following meaning:
                                       		0 - Both FIC and FDC must be used
                                       		1 - Only need FDC
                                       		2 - Only need FIC
                                       		3 - Either FIC or FDC may be used*/ 
#  define _SC_I_CACHE_LOOP      	457 /* intended for set-associative caches.
                                       		It is used to force the FDCE  
                                       		instruction  to be  executed multiple
                                       		times with the same address.  Note 
                                       		that when it is 1, software can 
                                       		optimize out the inner loop of the C
                                       		routine. */
#  define _SC_D_CACHE_LOOP      	458 /* same as _SC_I_CACHE_LOOP */

/* Symbolic constants for sysconf() variables added by POSIX.1,2003: 500-599 */
#  define _SC_2_PBS                     500
#  define _SC_2_PBS_ACCOUNTING          501
#  define _SC_2_PBS_CHECKPOINT          502
#  define _SC_2_PBS_LOCATE              503
#  define _SC_2_PBS_MESSAGE             504
#  define _SC_2_PBS_TRACK               505
#  define _SC_REGEXP                    506
#  define _SC_SHELL                     507
#  define _SC_HOST_NAME_MAX             508
#  define _SC_SYMLOOP_MAX               509
#  define _SC_ADVISORY_INFO             510
#  define _SC_BARRIERS                  511
#  define _SC_CLOCK_SELECTION           512
#  define _SC_CPUTIME                   513
#  define _SC_IPV6                      515
#  define _SC_MONOTONIC_CLOCK           516
#  define _SC_RAW_SOCKETS               518
#  define _SC_READER_WRITER_LOCKS       519
#  define _SC_SPAWN                     520
#  define _SC_SPIN_LOCKS                521
#  define _SC_SPORADIC_SERVER           522
#  define _SC_THREAD_CPUTIME            523
#  define _SC_THREAD_SPORADIC_SERVER    524
#  define _SC_TIMEOUTS                  525
#  define _SC_TRACE                     526
#  define _SC_TRACE_EVENT_FILTER        527
#  define _SC_TRACE_INHERIT             528
#  define _SC_TRACE_LOG                 529
#  define _SC_TYPED_MEMORY_OBJECTS      530
#  define _SC_XOPEN_REALTIME            531
#  define _SC_XOPEN_REALTIME_THREADS    532

/* Symbolic constants for sysconf() variables defined by X/Open: 2000-2999 */

#  define _SC_CLOCKS_PER_SEC   2000  /* CLOCKS_PER_SEC: Units/sec of clock() */
#  define _SC_XPG3_VERSION	  8  /* 3 */
#  define _SC_XPG4_VERSION     2001  /* 4 */
#  define _SC_PASS_MAX		  9  /* Max # of bytes in password */
#  define _SC_XOPEN_CRYPT      2002  /* Encryption feature group supported */
#  define _SC_XOPEN_ENH_I18N   2003  /* Enhanced I18N feature group  "	   */
#  define _SC_XOPEN_SHM	       2004  /* Shared memory feature group  "	   */
# ifdef _XPG3
#  define _SC_XOPEN_VERSION  _SC_XPG3_VERSION  /* Issue of XPG supported */
# else /* not _XPG3 */
#  define _SC_XOPEN_VERSION  _SC_XPG4_VERSION  /* Issue of XPG supported */
# endif /* not _XPG3 */

/* Symbolic constants for sysconf() variables defined by XPG5 */

#  define _SC_XBS5_ILP32_OFF32  2005 /* 32-bit int, long, pointer and off_t */
#  define _SC_XBS5_ILP32_OFFBIG 2006 /* 32-bit int, long, pointer, and 64-bit off_t */
#  define _SC_XBS5_LP64_OFF64   2007 /* 32-bit int, 64-bit long, pointer, off_t */
#  define _SC_XBS5_LPBIG_OFFBIG 2008 /* at least 32-bit int, at least 64-bit long, pointer, off_t */

/* Symbolic constants for sysconf() variables defined for UNIX 2003 */
#  define _SC_XOPEN_STREAMS	2009
#  define _SC_XOPEN_LEGACY	2010

#  define _SC_V6_ILP32_OFF32    _SC_XBS5_ILP32_OFF32
#  define _SC_V6_ILP32_OFFBIG   _SC_XBS5_ILP32_OFFBIG
#  define _SC_V6_LP64_OFF64     _SC_XBS5_LP64_OFF64
#  define _SC_V6_LPBIG_OFFBIG   _SC_XBS5_LPBIG_OFFBIG

#  define _SC_SS_REPL_MAX            2011
#  define _SC_TRACE_EVENT_NAME_MAX   2012
#  define _SC_TRACE_NAME_MAX         2013
#  define _SC_TRACE_SYS_MAX          2014
#  define _SC_TRACE_USER_EVENT_MAX   2015

/* Symbolic constants for sysconf() variables defined by OSF: 3000-3999 */

#  define _SC_AES_OS_VERSION   3000 /* AES_OS_VERSION: Version of OSF/AES OS */
#  define _SC_PAGE_SIZE	       3001 /* PAGE_SIZE: Software page size */
#  define _SC_ATEXIT_MAX       3002 /* ATEXIT_MAX: Max # of atexit() funcs */

/* Symbolic constants for sysconf() variables defined by SVID/3 */
#  define _SC_PAGESIZE               _SC_PAGE_SIZE

/* Symbolic constants for sysconf() variables defined by HP-UX: 10000-19999 */

#  define _SC_SECURITY_CLASS  10000 /* SECURITY_CLASS: DoD security level */
#  define _SC_CPU_VERSION     10001 /* CPU type this program is running on */
#  define _SC_IO_TYPE	      10002 /* I/O system type this system supports */
#  define _SC_MSEM_LOCKID     10003 /* msemaphore lock unique identifier */
#  define _SC_MCAS_OFFSET     10004 /* Offset on gateway page of mcas_util() */
#  define _SC_CPU_KEYBITS1    10005 /* hardware key bit information */
#  define _SC_PROC_RSRC_MGR   10006 /* Process Resource Manager is configured */
#  define _SC_SOFTPOWER	      10007 /* Soft Power Switch Hardware exists */
#  define _SC_EXEC_INTERPRETER_LENGTH	10008 /* for '#!' scripts, inclusive */
#  define _SC_SLVM_MAXNODES   10009 /* Max num of nodes supported by SLVM */
#  define _SC_SIGRTMIN	      10010 /* First POSIX.4 Realtime Signal */
#  define _SC_SIGRTMAX	      10011 /* Last  POSIX.4 Realtime Signal */
#  define _SC_LIBC_VERSION    10012 /* Libc version */
#  define _SC_KERNEL_BITS     10013 /* running kernel is 32 or 64bit */
#  define _SC_KERNEL_IS_BIGENDIAN 10014 /* indicates kernel "big-endian" */
#  define _SC_HW_32_64_CAPABLE    10015 /* indicates whether h/w is capable
					of running 32bit and/or 64bit OS */
#  define _SC_INT_MIN         10016 /* minimum value an object of type int can hold */
#  define _SC_INT_MAX         10017 /* maximum value an object of type int can hold */
#  define _SC_LONG_MIN        10018 /* minimum value an object of type long can hold */
#  define _SC_LONG_MAX        10019 /* maximum value an object of type long can hold */
#  define _SC_SSIZE_MAX       10020 /* maximum value an object of type ssize_t can hold */
#  define _SC_WORD_BIT        10021 /* number of bits in a word */
#  define _SC_LONG_BIT        10022 /* number of bits in a long */
#  define _SC_CPU_CHIP_TYPE   10023 /* encoded CPU chip type from PDC */
#  define _SC_CCNUMA_PM       10024 /* CCNUMA Programming Model Exts Active */
#  define _SC_CCNUMA_SUPPORT  10025 /* CCNUMA supported platform */
#  define _SC_IPMI_INTERFACE  10026 /* ipmi interface type */
#  define _SC_SPROFIL_MAX     10027 /* max number of profiled regions in 
					sprofil system call */
#  define _SC_NUM_CPUS        10028 /* number of cpus in use */
#  define _SC_MEM_MBYTES      10029 /* Mbytes of memory */

/* reserve 10030 for private use */

#  define _SC_PSET_RTE_SUPPORT	10031	/* RTE PSets Supported */
#  define _SC_RTE_SUPPORT	10032	/* RTE Supported */

#  define _SC_HG_SUPPORT	10034	/* HG (Project Mercury) supported */
#  define _SC_INIT_PROCESS_ID	10035	/* PID of the INIT process */
#  define _SC_SWAPPER_PROCESS_ID	10036	/* PID of the SWAPPER process */
#  define _SC_VHAND_PROCESS_ID	10037	/* PID of the VHAND process */
#  define _SC_HOST_NAME_MAX_2	10038	/* duplicate of _SC_HOST_NAME_MAX,
					   for compatibility with 11.23 0409 */  
#  define _SC_SCALABLE_INIT     10039 /* Scalable init code is present */

#  define _SC_HT_CAPABLE	10040 /* The hardware is capable of
					 hyperthread */
#  define _SC_HT_ENABLED	10041 /* The hardware is hyperthread enabled */

/* Macro to check if numeric username is enabled */
#  define _SC_EXTENDED_LOGIN_NAME	10042
#  define _SC_MINCORE		10043 /* mincore() system call support */


#  define _SC_CELL_OLA_SUPPORT  11001 /* OS supports Online Cell Addition */
#  define _SC_CELL_OLD_SUPPORT  11002 /* OS supports Online Cell Deletion */
#  define _SC_CPU_OLA_SUPPORT   11003 /* OS supports Online CPU Addition */
#  define _SC_CPU_OLD_SUPPORT   11004 /* OS supports Online CPU Deletion */
#  define _SC_MEM_OLA_SUPPORT   11005 /* OS supports Online Memory Addition */
#  define _SC_MEM_OLD_SUPPORT   11006 /* OS supports Online Memory Deletion */
#  define _SC_LORA_MODE         11007 /* NUMA mode for the partition */

#  define _SC_P2P             19500 /* p2p bcopy feature */

/* value(s) returned by sysconf(_SC_P2P) */

#  define _SC_P2P_ENABLED     0x1
#  define _SC_P2P_DATA_MOVER  0x2

#  define _SC_GANG_SCHED      19501 /* gang scheduler feature */

#  define _SC_PSET_SUPPORT    19502 /* Processor Set functionality support */

/* 20000-20999 reserved for private use */

/* Symbolic constants for pathconf() defined by POSIX.1: 0-99 */
#  define _PC_LINK_MAX		0  /* LINK_MAX: Max # of links to a single
				      file */
#  define _PC_MAX_CANON		1  /* MAX_CANON: Max # of bytes in a terminal 
				     canonical input line */
#  define _PC_MAX_INPUT		2  /* MAX_INPUT: Max # of bytes allowed in
				     a terminal input queue */ 
#  define _PC_NAME_MAX		3  /* NAME_MAX: Max # of bytes in a filename */

#  define _PC_PATH_MAX		4  /* PATH_MAX: Max # of bytes in a pathname */

#  define _PC_PIPE_BUF		5  /* PIPE_BUF: Max # of bytes for which pipe
				      writes are atomic */ 
#  define _PC_CHOWN_RESTRICTED	6  /* _POSIX_CHOWN_RESTRICTED: 1 iff only a
				      privileged process can use chown() */
#  define _PC_NO_TRUNC		7  /* _POSIX_NO_TRUNC: 1 iff an error is
				      detected when exceeding NAME_MAX */
#  define _PC_VDISABLE		8  /* _POSIX_VDISABLE: character setting which
				      disables TTY local editing characters */

/* Symbolic constants for pathconf() defined by POSIX.1b */

#  define _PC_SYNC_IO         100  /* SYNC_IO: 1 iff Synchronized IO may be
                                      performed for the associated file */
#  define _PC_ASYNC_IO	      101  /* Async I/O may be performed on this fd */
#  define _PC_PRIO_IO	      102  /* I/O Prioritization is done on this fd */

#  define _PC_FILESIZEBITS    103  /* bits needed to represent file offset */

/* Symbolic constants for pathconf() defined by POSIX.1d or Unix2003 */
                                                                                                                            
#  define _PC_2_SYMLINKS            600
#  define _PC_ALLOC_SIZE_MIN        601
#  define _PC_REC_INCR_XFER_SIZE    602
#  define _PC_REC_MAX_XFER_SIZE     603
#  define _PC_REC_MIN_XFER_SIZE     604
#  define _PC_REC_XFER_ALIGN        605
#  define _PC_SYMLINK_MAX           606

#endif /* _INCLUDE_POSIX_SOURCE || _INCLUDE_POSIX2_SOURCE */

/* Issue(s) of X/Open Portability Guide we support */

#ifdef _INCLUDE_XOPEN_SOURCE

#  ifdef _XPG3
#    define _XOPEN_VERSION	3 
#  else /* not _XPG3 */
#    define _XOPEN_VERSION	4
#  endif /* not _XPG3 */

#  ifdef _XPG2
#    define _XOPEN_XPG2		1
#  else /* not _XPG2 */
#    ifdef _XPG3
#      define _XOPEN_XPG3	1
#    else /* not _XPG3 */
#      define _XOPEN_XPG4	1
#    endif /* not _XPG3 */
#  endif /* not _XPG2 */

#  define _XOPEN_XCU_VERSION	3	/* X/Open Commands & Utilities */

    /* XPG4 Feature Groups */

#  define _XOPEN_CRYPT		1	/* Encryption and Decryption */
#  define _XOPEN_ENH_I18N	1	/* Enhanced Internationalization */
    /* _XOPEN_SHM is not defined because the Shared Memory routines can be
    configured in and out of the system.  See uxgen(1M) or config(1M).  */
#  ifdef _INCLUDE_XOPEN_SOURCE_500
#    define _XOPEN_SHM		1
#  endif /* _INCLUDE_XOPEN_SOURCE_500 */

#endif /* _INCLUDE_XOPEN_SOURCE */


/* Revision of AES OS we support */

#ifdef _INCLUDE_AES_SOURCE
#    define _AES_OS_VERSION	1
#endif /* _INCLUDE_AES_SOURCE */


#ifdef _INCLUDE_POSIX2_SOURCE

#  define _POSIX2_VERSION_92    199209L /* We support POSIX.2-1992 */
#  define _POSIX2_VERSION_01    200112L /* We support POSIX.2-2001 */

/* Conformance and options for POSIX.2 */
#  ifdef _INCLUDE_XOPEN_SOURCE_PRE_600
#    define _POSIX2_C_VERSION 		_POSIX2_VERSION_92
#    ifdef _HPUX_SOURCE
       /* IEEE POSIX.2-2001 base standard */
#      define _POSIX2_VERSION   	_POSIX2_VERSION_01
       /* IEEE POSIX.2-2001 C language binding */
#      define _SUPPORTED_POSIX2_OPTION	_POSIX2_VERSION_01
#    else /* !_HPUX_SOURCE */
       /* IEEE POSIX.2-1992 base standard */
#      define _POSIX2_VERSION   		_POSIX2_VERSION_92
       /* IEEE POSIX.2-1992 C language binding */
#      define _SUPPORTED_POSIX2_OPTION	1L
#    endif /* !_HPUX_SOURCE */
#  else /* !_INCLUDE_XOPEN_SOURCE_PRE_600 */
     /* IEEE POSIX.2-1992 base standard */
#    define _POSIX2_VERSION   		_POSIX2_VERSION_01
#    define _SUPPORTED_POSIX2_OPTION	_POSIX2_VERSION_01
#  endif /* !_INCLUDE_XOPEN_SOURCE_PRE_600 */

/* c89 finds POSIX.2 funcs by default */
#  define _POSIX2_C_BIND    _SUPPORTED_POSIX2_OPTION 

/* c89, lex, yacc, etc. are provided */
#  define _POSIX2_C_DEV     _SUPPORTED_POSIX2_OPTION

/* make, ar, etc. are provided */
#  define _POSIX2_SW_DEV    _SUPPORTED_POSIX2_OPTION

/* terminals exist where vi works */
#  define _POSIX2_CHAR_TERM _SUPPORTED_POSIX2_OPTION

/* User Portability Utilities supported */
#  define _POSIX2_UPE       _SUPPORTED_POSIX2_OPTION

/* localedef(1M) can create locales */
#  define _POSIX2_LOCALEDEF _SUPPORTED_POSIX2_OPTION

/* fort77 is not provided */
#  define _POSIX2_FORT_DEV  -1L

/* asa is not provided */
#  define _POSIX2_FORT_RUN  -1L


/* Symbolic constants representing C-language compilation environments defined
 * by XPG5
 */
#  define _XBS5_ILP32_OFF32      32 /* 32-bit int, long, pointer, off_t */
#  define _XBS5_ILP32_OFFBIG     32 /* 32-bit int, long, pointer, 64-bit off_t */
#  define _XBS5_LP64_OFF64       64 /* 32-bit int, 64-bit long, pointer, off_t */
#  define _XBS5_LPBIG_OFFBIG     64 /* 32-bit int, 64-bit long, pointer, off_t */

/* Symbolic constants for confstr() defined by POSIX.2: 200-299 */

#  define _CS_PATH	200	/* Search path that finds all POSIX.2 utils */

/* Symbolic constants for confstr() defined by XPG5: 300-399 */

/* Initial compiler options, final compiler options, set of libraries and lint
 * options for 32-bit int, long, pointer, off_t.
 */
#  define _CS_XBS5_ILP32_OFF32_CFLAGS     300
#  define _CS_XBS5_ILP32_OFF32_LDFLAGS    301
#  define _CS_XBS5_ILP32_OFF32_LIBS       302
#  define _CS_XBS5_ILP32_OFF32_LINTFLAGS  303

/* Initial compiler options, final compiler options, set of libraries and lint
 * options for 32-bit int, long, pointer, 64-bit off_t.
 */
#  define _CS_XBS5_ILP32_OFFBIG_CFLAGS    304
#  define _CS_XBS5_ILP32_OFFBIG_LDFLAGS   305
#  define _CS_XBS5_ILP32_OFFBIG_LIBS      306
#  define _CS_XBS5_ILP32_OFFBIG_LINTFLAGS 307

/* Initial compiler options, final compiler options, set of libraries and lint
 * options for 32-bit int, 64-bit long, pointer, off_t.
 */
#  define _CS_XBS5_LP64_OFF64_CFLAGS      308
#  define _CS_XBS5_LP64_OFF64_LDFLAGS     309
#  define _CS_XBS5_LP64_OFF64_LIBS        310
#  define _CS_XBS5_LP64_OFF64_LINTFLAGS   311

/* Initial compiler options, final compiler options, set of libraries and lint
 * options for an int type using at least 32-bits, and long, pointer, and off_t
 * types using at least 64-bits.
 */
#  define _CS_XBS5_LPBIG_OFFBIG_CFLAGS    312
#  define _CS_XBS5_LPBIG_OFFBIG_LDFLAGS   313
#  define _CS_XBS5_LPBIG_OFFBIG_LIBS      314
#  define _CS_XBS5_LPBIG_OFFBIG_LINTFLAGS 315

/* Symbolic constants for confstr() defined by Unix2003 : 700 - 799 */

/* Initial C99 compiler options, final C99 compiler options, set of libraries
 * options for 32-bit int, long, pointer, off_t.
 */
#  define _CS_POSIX_V6_ILP32_OFF32_CFLAGS    700
#  define _CS_POSIX_V6_ILP32_OFF32_LDFLAGS   701
#  define _CS_POSIX_V6_ILP32_OFF32_LIBS      702

/* Initial C99 compiler options, final C99 compiler options, set of libraries
 * options for 32-bit int, long, pointer, 64-bit off_t.
 */
#  define _CS_POSIX_V6_ILP32_OFFBIG_CFLAGS   704
#  define _CS_POSIX_V6_ILP32_OFFBIG_LDFLAGS  705
#  define _CS_POSIX_V6_ILP32_OFFBIG_LIBS     706

/* Initial C99 compiler options, final C99 compiler options, set of libraries
 * options for 32-bit int, 64-bit long, pointer, off_t.
 */
#  define _CS_POSIX_V6_LP64_OFF64_CFLAGS     708
#  define _CS_POSIX_V6_LP64_OFF64_LDFLAGS    709
#  define _CS_POSIX_V6_LP64_OFF64_LIBS       710

/* Initial compiler options, final compiler options, set of libraries and lint
 * options for an int type using at least 32-bits, and long, pointer, and off_t
 * types using at least 64-bits.
 */
#  define _CS_POSIX_V6_LPBIG_OFFBIG_CFLAGS   712
#  define _CS_POSIX_V6_LPBIG_OFFBIG_LDFLAGS  713
#  define _CS_POSIX_V6_LPBIG_OFFBIG_LIBS     714

#  define _CS_POSIX_V6_WIDTH_RESTRICTED_ENVS 716

/* Symbolic constants for confstr() defined by HP-UX: 10000-19999 */

#  define _CS_MACHINE_MODEL 10000    /* system model name */
#  define _CS_HW_CPU_SUPP_BITS 10001 /* OS configurations supported */
#  define _CS_KERNEL_BITS   10002    /* kernel running is "32" or "64"  bits */
#  define _CS_MACHINE_IDENT 10003    /* Machine ID */
#  define _CS_PARTITION_IDENT 10004  /* Partition ID */
#  define _CS_MACHINE_SERIAL 10005   /* Machine serial number */

/* Symbolic constants for use with fnmatch() have been moved to <fnmatch.h> */

#endif /*  _INCLUDE_POSIX2_SOURCE */

#  ifndef _XOPEN_UNIX
#  	define _XOPEN_UNIX	-1       
#  endif
#  define _XOPEN_CURSES 1

#ifdef _INCLUDE_XOPEN_SOURCE_EXTENDED 

/* Symbolic constants for the "lockf" function: */

#  define F_ULOCK	0	/* Unlock a previously locked region */
#  define F_LOCK	1	/* Lock a region for exclusive use */
#  define F_TLOCK	2	/* Test and lock a region for exclusive use */
#  define F_TEST	3	/* Test a region for a previous lock */

/* Symbolic constants for sysconf() variables defined by XPG4_EXTENDED */
/* Continue with ones for XOPEN (2000-2999) */

#  define _SC_IOV_MAX	  2100    /* Max # of iovec structures for readv/writev */
#  define _SC_XOPEN_UNIX  2101    /* Whether or not XOPEN_UNIX is supported  */
#endif /* _INCLUDE_XOPEN_SOURCE_EXTENDED */

/*
 * Define _XOPEN_VERSION symbolic constant for unix98
 * compliance.
 */
#ifdef _INCLUDE_XOPEN_SOURCE_500
#  undef _XOPEN_VERSION
#  define _XOPEN_VERSION 500
#endif /* _INCLUDE_XOPEN_SOURCE_500 */
/*
 * Define _XOPEN_VERSION symbolic constant for unix03
 * compliance.
 */
#if defined(_INCLUDE_XOPEN_SOURCE_600)
#  undef _XOPEN_VERSION
#  define _XOPEN_VERSION 600
#  define _XOPEN_STREAMS 1
#  define _XOPEN_REALTIME -1
#  define _XOPEN_LEGACY -1
#  define _POSIX_V6_ILP32_OFF32 32
#  define _POSIX_V6_ILP32_OFFBIG 32
#  define _POSIX_V6_LP64_OFF64 64
#  define _POSIX_V6_LPBIG_OFFBIG 64
#endif /* _INCLUDE_XOPEN_SOURCE_600 */

#ifdef _INCLUDE_HPUX_SOURCE

/* Symbolic constants for the passwd file and group file */

#  define GF_PATH	"/etc/group"	/* Path name of the "group" file */
#  define PF_PATH	"/etc/passwd"	/* Path name of the "passwd" file */
#  define IN_PATH	"/usr/include"	/* Path name for <...> files */


/* Path on which all POSIX.2 utilities can be found */

#  define CS_PATH	  \
   "/usr/bin:/usr/ccs/bin:/opt/ansic/bin:/opt/langtools/bin:/opt/fortran/bin"

#  define CS_XBS5_ILP32_OFF32_CFLAGS		""
#  define CS_XBS5_ILP32_OFF32_LDFLAGS		""
#  define CS_XBS5_ILP32_OFF32_LIBS		""
#  define CS_XBS5_ILP32_OFF32_LINTFLAGS		""
#  define CS_XBS5_ILP32_OFFBIG_CFLAGS		"-D_FILE_OFFSET_BITS=64"
#  define CS_XBS5_ILP32_OFFBIG_LDFLAGS		""
#  define CS_XBS5_ILP32_OFFBIG_LIBS		""
#  define CS_XBS5_ILP32_OFFBIG_LINTFLAGS	"-D_FILE_OFFSET_BITS=64"

#if defined(__ia64)
#  define CS_XBS5_LP64_OFF64_CFLAGS		"+DD64"
#  define CS_XBS5_LPBIG_OFFBIG_CFLAGS           "+DD64"
#else
#  define CS_XBS5_LP64_OFF64_CFLAGS		"+DA2.0W"
#  define CS_XBS5_LPBIG_OFFBIG_CFLAGS		"+DA2.0W"
#endif

#  define CS_XBS5_LP64_OFF64_LDFLAGS		""
#  define CS_XBS5_LP64_OFF64_LIBS		""
#  define CS_XBS5_LP64_OFF64_LINTFLAGS		""
#  define CS_XBS5_LPBIG_OFFBIG_LDFLAGS		""
#  define CS_XBS5_LPBIG_OFFBIG_LIBS		""
#  define CS_XBS5_LPBIG_OFFBIG_LINTFLAGS	""

#  define CS_POSIX_V6_ILP32_OFF32_CFLAGS          ""
#  define CS_POSIX_V6_ILP32_OFF32_LDFLAGS         ""
#  define CS_POSIX_V6_ILP32_OFF32_LIBS            ""
#  define CS_POSIX_V6_ILP32_OFFBIG_CFLAGS         "-D_FILE_OFFSET_BITS=64"
#  define CS_POSIX_V6_ILP32_OFFBIG_LDFLAGS        ""
#  define CS_POSIX_V6_ILP32_OFFBIG_LIBS           ""
#  define CS_POSIX_V6_LP64_OFF64_CFLAGS           "+DD64"
#  define CS_POSIX_V6_LP64_OFF64_LDFLAGS          ""
#  define CS_POSIX_V6_LP64_OFF64_LIBS             ""
#  define CS_POSIX_V6_LPBIG_OFFBIG_CFLAGS         "+DD64"
#  define CS_POSIX_V6_LPBIG_OFFBIG_LDFLAGS        ""
#  define CS_POSIX_V6_LPBIG_OFFBIG_LIBS           ""
#  define CS_POSIX_V6_WIDTH_RESTRICTED_ENVS       "_POSIX_V6_ILP32_OFF32\n_POSIX_V6_ILP32_OFFBIG\n_POSIX_V6_LP64_OFF64\n_POSIX_V6_LPBIG_OFFBIG"

/* Symbolic constants for values of sysconf(_SC_SECURITY_LEVEL) */

#  define SEC_CLASS_NONE	0  /* default secure system */
#  define SEC_CLASS_C2		1  /* C2 level security */
#  define SEC_CLASS_B1		2  /* B1 level security */

/* Symbolic constants for values of sysconf(_SC_IO_TYPE) */

#  define IO_TYPE_WSIO    01
#  define IO_TYPE_SIO     02
#  define IO_TYPE_CDIO    03

/* Symbolic constants for values of sysconf(_SC_CPU_KEYBITS1) */

#define HARITH     0x00000010   /* Halfword parallel add, subtract, average */
#define HSHIFTADD  0x00000020   /* Halfword parallel shift-and-add          */

/* Symbolic constants for values of sysconf(_SC_CPU_VERSION) */
/* These are the same as the magic numbers defined in <sys/magic.h> */
/* Symbolic constants for values of sysconf(_SC_CPU_VERSION)
   do not have to be monotonic.  
   Values from 0x0210 through 0x02ff have been reserved for 
   revisions of PA-RISC */

#  define CPU_HP_MC68020	0x20C /* Motorola MC68020 */
#  define CPU_HP_MC68030	0x20D /* Motorola MC68030 */
#  define CPU_HP_MC68040	0x20E /* Motorola MC68040 */
#  define CPU_PA_RISC1_0	0x20B /* HP PA-RISC1.0 */
#  define CPU_PA_RISC1_1	0x210 /* HP PA-RISC1.1 */
#  define CPU_PA_RISC1_2	0x211 /* HP PA-RISC1.2 */
#  define CPU_PA_RISC2_0	0x214 /* HP PA-RISC2.0 */
#  define CPU_PA_RISC_MAX	0x2FF /* Maximum value for HP PA-RISC systems */
#  define CPU_IA64_ARCHREV_0	0x300 /* IA-64 archrev 0 */

/* Macro for detecting whether a given CPU version is an HP PA-RISC machine */

#  define CPU_IS_PA_RISC(__x)           \
       ((__x) == CPU_PA_RISC1_0 ||      \
        ((__x) >= CPU_PA_RISC1_1 && (__x) <= CPU_PA_RISC_MAX))

/* Macro for detecting whether a given CPU version is an HP MC680x0 machine */

#  define CPU_IS_HP_MC68K(__x)          \
        ((__x) == CPU_HP_MC68020 ||     \
         (__x) == CPU_HP_MC68030 ||     \
         (__x) == CPU_HP_MC68040)


/* Macros to interpret return value from sysconf(_SC_HW_32_64_CAPABLE) */

#  define _SYSTEM_SUPPORTS_LP64OS(__x) ((__x) & 0x1)
#  define _SYSTEM_SUPPORTS_ILP32OS(__x) ((__x) & 0x2)

#ifndef _KERNEL
/*
 * serialize system call
 */
	/* Function prototype */
#if defined(__ia64) && !defined(_LIBC)  
  /* pragmas needed to support -B protected */  
#pragma extern serialize
#endif /* __ia64 && ! _LIBC */ 
extern int serialize __((int, pid_t));

#endif /* not _KERNEL */

#endif /* _INCLUDE_HPUX_SOURCE */

#ifdef _UNSUPPORTED

	/* 
	 * NOTE: The following header file contains information specific
	 * to the internals of the HP-UX implementation. The contents of 
	 * this header file are subject to change without notice. Such
	 * changes may affect source code, object code, or binary
	 * compatibility between releases of HP-UX. Code which uses 
	 * the symbols contained within this header file is inherently
	 * non-portable (even between HP-UX implementations).
	*/
# include <.unsupp/sys/_unistd.h>
#endif /* _UNSUPPORTED */

#endif /* _SYS_UNISTD_INCLUDED */

