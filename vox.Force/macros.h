//
//  macros.h
//  DigitalVox
//
//  Created by Feng Yang on 2020/9/20.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef INCLUDE_VOX_MACROS_H_
#define INCLUDE_VOX_MACROS_H_

#define DEBUG

#if defined(DEBUG) || defined(_DEBUG)
#   define VOX_DEBUG_MODE
#   define VOX_ASSERT(x) assert(x)
#else
#   define VOX_ASSERT(x)
#endif

#endif /* INCLUDE_VOX_MACROS_H_ */
