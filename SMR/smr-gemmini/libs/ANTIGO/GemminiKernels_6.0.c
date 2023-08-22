#include <stdio.h>
#ifndef BAREMETAL
#include <sys/mman.h>
#endif

#include "include/gemmini_testutils.h"

/// \brief Calculates a generic single precision matrix multiplication.
///
/// The equation is:
///   C := alpha*A*B + beta*C
/// Where
///   Alpha and Beta are scalars
///   A is a MxK matrix
///   B is a KxN matrix
///   C is a MxN matrix
///
/// The result is returned in \param C.
///
/// \param TRANSA Whether A is transposed.
/// \param TRANSB Whether B is transposed.
/// \param _M First dimension of A.
/// \param _N Second dimension of B.
/// \param _K Commom dimension of A and B.
/// \param _alpha Alpha scalar.
/// \param A Reference to matrix A.
/// \param _LDA Leading dimension of A.
/// \param B Reference to matrix B.
/// \param _LDB Leading dimension of B.
/// \param _beta Beta scalar.
/// \param C Reference to matrix C.
/// \param _LDC Leading dimension of C.
///
void sgemm_(unsigned char* TRANSA, unsigned char* TRANSB,
            int* _M, int* _N, int* _K,
            float* _alpha, float* A, int* _LDA,
            float* B, int* _LDB, float* _beta,
            float* C, int* _LDC)
{
  // Dereference arguments
  int M = *_M, N = *_N, K = *_K;
  float Alpha = *_alpha, Beta = *_beta;
  int LDA = *_LDA, LDB = *_LDB, LDC = *_LDC;
  int stride_A, stride_B;

  bool transpose_A;
  bool transpose_B;
  
  // A is not transposed: copy dimensions as is
  if (*TRANSA == 'N' || *TRANSA == 'n') {
    stride_A = M;
    transpose_A = true;
  }
  // B is transposed: invert dimensions
  else if (*TRANSA == 'T' || *TRANSA == 't' || *TRANSA == 'C' || *TRANSA == 'c') {
    stride_A = K;
    transpose_A = false;
  } else {
    printf("Invalid value for TRANSA: %c\n", TRANSA);
    exit(1);
  }

  // B is not transposed: copy dimensions as is
  if (*TRANSB == 'N' || *TRANSB == 'n') {
    stride_B = K;
    transpose_B = true;
  }
  // B is transposed: invert dimensions
  else if (*TRANSB == 'T' || *TRANSB == 't' || *TRANSB == 'C' || *TRANSB == 'c') {
    stride_B = N;
    transpose_B = false;
  } else {
    printf("Invalid value for TRANSB: %c\n", TRANSA);
    exit(1);
  }

  // Calculate matmul using gemmini
  // Case A and B are transposed
  if (transpose_A && transpose_B){
    tiled_matmul_auto(
      N, M, K,
      (elem_t*)B, (elem_t*)A, C, C,
      K, M, M, M,
      Alpha, MVIN_SCALE_IDENTITY, Beta,
      NO_ACTIVATION, ACC_SCALE_IDENTITY, 0, false,
      false, false,
      false, false,
      0,
      WS
    );
  } else {
    tiled_matmul_auto(
      M, N, K,
      (elem_t*)A, (elem_t*)B, C, C,
      stride_A, stride_B, N, N,
      MVIN_SCALE_IDENTITY, Alpha, Beta,
      NO_ACTIVATION, ACC_SCALE_IDENTITY, 0, false,
      transpose_A, transpose_B,
      false, false,
      0,
      WS
    );
  }
}

/// \brief Calculates a generic single precision matrix-vector multiplication.
///
/// The equation is:
///   y := alpha*A*x + beta*y
/// Where
///   Alpha and Beta are scalars
///   A is a MxN matrix
///   x is a N-length (M if A is transposed) vector
///   y is a M-length (N if A is transposed) vector
///
/// The result is returned in \param Y.
///
/// \param TRANSA Whether A is transposed.
/// \param _M First dimension of A.
/// \param _N Second dimension of A.
/// \param _alpha Alpha scalar.
/// \param A Reference to matrix A.
/// \param _LDA Leading dimension of A.
/// \param X Reference to x vector.
/// \param _incX Increment for iterating over X.
/// \param _beta Beta scalar.
/// \param Y Reference to y vector.
/// \param _incY Increment for iterating over Y.
///
void sgemv_(unsigned char* TRANSA,
            int* _M, int* _N,
            float* _alpha, float* A, int* _LDA,
            float* X, int* _incX, float* _beta,
            float* Y, int* _incY)
{
  // Dereference arguments
  int M = *_M, N = *_N, stride_A;
  float alpha = *_alpha, beta = *_beta;
  int LDA = *_LDA, INCX = *_incX, INCY = *_incY;

  bool transpose_A;

  // A is not transposed
  if (*TRANSA == 'N' || *TRANSA == 'n') {
    stride_A = M;
    transpose_A = true;
  }
  // A is transposed
  else if (*TRANSA == 'T' || *TRANSA == 't' || *TRANSA == 'C' || *TRANSA == 'c') {
    stride_A = N;
    transpose_A = false;
  }
  // Unknown tranpose argument: exit as error
  else{
    printf("Invalid value for TRANSA: %c\n", TRANSA);
    exit(1);
  }

  // Calculate matrix-vector product through gemmini
  tiled_matmul_auto(
    M, 1, N,
    (elem_t*)A, (elem_t*)X, (beta == 0.0f) ? NULL : Y, Y,
    stride_A, 1, 1, 1,
    MVIN_SCALE_IDENTITY, alpha, beta,
    NO_ACTIVATION, ACC_SCALE_IDENTITY, 0, false,
    transpose_A, false,
    true, false,
    1,
    WS
  );
}