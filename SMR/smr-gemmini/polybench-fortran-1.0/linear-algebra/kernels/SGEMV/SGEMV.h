/**
 * mvt.h: This file is part of the PolyBench/Fortran 1.0 test suite.
 *
 * Contact: Louis-Noel Pouchet <pouchet@cse.ohio-state.edu>
 * Web address: http://polybench.sourceforge.net
 */
#ifndef MVT_H
# define MVT_H

/* Default to STANDARD_DATASET. */
# if !defined(MINI_DATASET) && !defined(SMALL_DATASET) && !defined(LARGE_DATASET) && !defined(EXTRALARGE_DATASET)
#  define STANDARD_DATASET
# endif

/* Do not define anything if the user manually defines the size. */
# ifndef N
/* Define the possible dataset sizes. */
#  ifdef MINI_DATASET
#   define N 128
#  endif

#  ifdef SMALL_DATASET
#   define N 500
#  endif

#  ifdef STANDARD_DATASET /* Default if unspecified. */
#   define N 4000
#  endif

#  ifdef LARGE_DATASET
#   define N 8000
#  endif

#  ifdef EXTRALARGE_DATASET
#   define N 100000
#  endif
# endif /* !N */

# define _PB_N POLYBENCH_LOOP_BOUND(N,n)

# ifndef DATA_TYPE
#  define DATA_TYPE double precision
#  define DATA_PRINTF_MODIFIER "(f0.2,1x)", advance='no'
# endif


#endif /* !MVT */
