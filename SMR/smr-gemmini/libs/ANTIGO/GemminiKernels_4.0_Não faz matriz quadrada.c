#include <stdio.h>
#ifndef BAREMETAL
#include <sys/mman.h>
#endif

#include <math.h>
#include "include/gemmini_testutils.h"

/// \brief Multiply a matrix by a scalar.
///
/// The equation is:
///   A := op(A)*scalar, where op(A) is A or A^t.
///
/// \param A Flat MxN column major matrix to be copied.
/// \param M Amount of lines in the copied matrix.
/// \param N Amount of columns in copied matrix.
/// \param scalar Scalar value which A should be scaled by.
/// \param nullable Should return a NULL pointer if result is a null matrix.
///
/// \returns Reference to the multiplied matrix.
///

float* mult_esc(float* A, int M, int N, float scalar, bool nullable)
{
  float aux;

  // NOTE: if the scalar is 1, then we don't need to do anything. 
  //       The scalar 1 is netral in a multiplication.
  //       If the scalar is 0, then we just reference to NULL.
  //       NULL represent a void matrix.
  //
  // no work to be done: use A
  if (scalar == 1.0)
    return A;
  // Result is a null matrix: return null pointer
  else if (scalar == 0.0 && nullable == true)
    return NULL;

  // Multiply
  for (int i = 0; i < M; ++i)
    for (int j = 0; j < N; ++j) 
      A[i + j * M] *= scalar;

  return A;
}

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
  float aux, Alpha = *_alpha, Beta = *_beta;
  int LDA = *_LDA, LDB = *_LDB, LDC = *_LDC;
  int stride_A, stride_B;
  float *auxA, *auxB, *auxC;

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
  
  // Case A and B are the same matrix
  float auxAlpha = (&A[0] == &B[0]) ? sqrt(Alpha) : Alpha;

  // Copy fortran arguments to A and C
  auxA = mult_esc(A, M, K, auxAlpha, false); // alpha * op(A)
  auxC = mult_esc(C, M, N, Beta, true); // beta * C

  // Case A and B are transposed
  if (transpose_A && transpose_B){
    auxB = auxA;
    auxA = B;

    transpose_A = !transpose_A;
    transpose_B = !transpose_B;
  }else{
    auxB = B;
  }

  // Calculate matmul using gemmini
  tiled_matmul_auto(
    M, N, K,
    (elem_t*)auxA, (elem_t*)auxB, auxC, C,
    stride_A, stride_B, N, N,
    MVIN_SCALE_IDENTITY, MVIN_SCALE_IDENTITY, MVIN_SCALE_IDENTITY,
    NO_ACTIVATION, ACC_SCALE_IDENTITY, 0, false,
    transpose_A, transpose_B,
    true, false,
    1,
    WS
  );
  
  // Return initial condition for matrix A
  auxA = mult_esc(A, M, K, 1/auxAlpha, false); // alpha * op(A)
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
  
  // Calculate alpha*X 
  if (alpha != 1.0f){
    for (int i = 0; i < M; ++i)
      X[i] = X[i] * alpha;
  } 

  // Calculate beta*y 
  if (beta != 0.0f && beta != 1.0f){
    for (int i = 0; i < N; ++i)
      Y[i] = Y[i] * beta;
  }

  // Calculate matrix-vector product through gemmini
  tiled_matmul_auto(
    M, 1, N,
    (elem_t*)A, (elem_t*)X, (beta == 0.0f) ? NULL : Y, Y,
    stride_A, 1, 1, 1,
    MVIN_SCALE_IDENTITY, MVIN_SCALE_IDENTITY, MVIN_SCALE_IDENTITY,
    NO_ACTIVATION, ACC_SCALE_IDENTITY, 0, false,
    transpose_A, false,
    true, false,
    1,
    WS
  );
  
  // Return initial condition for vector X 
  if (alpha != 1.0f){
    for (int i = 0; i < M; ++i)
      X[i] = X[i] / alpha;
  } 
}