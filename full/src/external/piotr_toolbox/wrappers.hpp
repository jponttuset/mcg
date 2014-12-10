/*******************************************************************************
* Piotr's Image&Video Toolbox      Version 3.00
* Copyright 2012 Piotr Dollar.  [pdollar-at-caltech.edu]
* Please email me if you find bugs, or have suggestions or questions!
* Licensed under the Simplified BSD License [see external/bsd.txt]
*******************************************************************************/
#ifndef _WRAPPERS_HPP_
#define _WRAPPERS_HPP_
#include "mex.h"
#include <cstdio>
#include <stdlib.h>

inline void wrError(const char *errormsg) { mexErrMsgTxt(errormsg); }
inline void* wrCalloc( std::size_t num, std::size_t size ) { return mxCalloc(num,size); }
inline void* wrMalloc( std::size_t size ) { return mxMalloc(size); }
inline void wrFree( void * ptr ) { mxFree(ptr); }

// platform independent aligned memory allocation (see also alFree)
void* alMalloc( std::size_t size, int alignment ) {
  const std::size_t pSize = sizeof(void*), a = alignment-1;
  void *raw = wrMalloc(size + a + pSize);
  void *aligned = (void*) (((std::size_t) raw + pSize + a) & ~a);
  *(void**) ((std::size_t) aligned-pSize) = raw;
  return aligned;
}

// platform independent alignned memory de-allocation (see also alMalloc)
void alFree(void* aligned) {
  void* raw = *(void**)((char*)aligned-sizeof(void*));
  wrFree(raw);
}

#endif
