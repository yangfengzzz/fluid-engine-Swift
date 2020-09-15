//
//  FdmMatrixRow.h
//  DigitalVox
//
//  Created by Feng Yang on 2020/9/13.
//  Copyright © 2020 Feng Yang. All rights reserved.
//

#ifndef FdmMatrixRow_h
#define FdmMatrixRow_h

//! The row of FdmMatrix2 where row corresponds to (i, j) grid point.
struct FdmMatrixRow2 {
    //! Diagonal component of the matrix (row, row).
    float center = 0.0;
    
    //! Off-diagonal element where colum refers to (i+1, j) grid point.
    float right = 0.0;
    
    //! Off-diagonal element where column refers to (i, j+1) grid point.
    float up = 0.0;
};

//! The row of FdmMatrix3 where row corresponds to (i, j, k) grid point.
struct FdmMatrixRow3 {
    //! Diagonal component of the matrix (row, row).
    float center = 0.0;
    
    //! Off-diagonal element where colum refers to (i+1, j, k) grid point.
    float right = 0.0;
    
    //! Off-diagonal element where column refers to (i, j+1, k) grid point.
    float up = 0.0;
    
    //! OFf-diagonal element where column refers to (i, j, k+1) grid point.
    float front = 0.0;
};

#endif /* FdmMatrixRow_h */
