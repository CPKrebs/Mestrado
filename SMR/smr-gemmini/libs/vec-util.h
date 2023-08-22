#ifndef __VEC_UTIL_H__
#define __VEC_UTIL_H__

// remove to disable VRU
#define VRU_ENABLE

//#ifdef VRU_ENABLE
// because gcc complains about shifting without L 0x0000000080000000
#define VRU_SWITCH 0x000000080000000
//#else
//#define VRU_SWITCH 0x0
//#endif

#define VCFG(nvvd, nvvw, nvvh, nvp) \
  (((nvvd) & 0x1ff) | \
  (((nvp) & 0x1f) << 9) | \
  (((nvvw) & 0x1ff) << 14) | \
  (((nvvh) & 0x1ff) << 23) | \
  (VRU_SWITCH))

#endif
