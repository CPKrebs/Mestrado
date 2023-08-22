#include <stdio.h>
#ifndef BAREMETAL
#include <sys/mman.h>
#endif

#include "include/gemmini_testutils.h"


/// \brief Copies a flat column major matrix into as a row major matrix.
///
/// The equation is:
///   A := op(B)*scalar, where op(A) is A or A^t.
///
/// A is always assumed to be in column major order, and B will always be copied
/// in row major order.
///
/// The dimensions refer to the output matrix. If the copy is supposed to be
/// A^t, then \param A should be NxM, otherwise, \param A is also MxN.
///
/// \param A Flat MxN column major matrix to be copied.
/// \param LDA Leading dimension of \param A matrix.
/// \param M Amount of lines in the copied matrix.
/// \param N Amount of columns in copied matrix.
/// \param trans Wheter should copy the transpose of A.
/// \param scalar Scalar value which A should be scaled by.
/// \param nullable Should return a NULL pointer if result is a null matrix.
///
/// \returns Reference to the copied matrix.
///
float* copy(float* A, int LDA, int M, int N, bool trans, float scalar, bool nullable)
{
  float aux;

  // NOTE: if the A should be transposed and the scalar is 1, then we don't need
  //       to do anything. A is column major, so it's already tranpose is a row
  //       major layout. The scalar 1 is netral in a multiplication.
  //
  // no work to be done: use A
  if (trans == true && scalar == 1.0)
    return A;
  // result is a null matrix: return null pointer
  else if (scalar == 0.0 && nullable == true)
    return NULL;
  // must alter A: make room for the copy

  // should not transpose A: copy A as row major
  if (trans == false && scalar != 1.0)
  {
    for (int j = 0; j < N; ++j)
      for (int i = j; i < M; ++i){
        aux = A[i + j * LDA] * scalar;
        A[i + j * LDA] = A[i * M + j] * scalar;
        A[i * M + j] = aux;
      }
  }
  else if (trans == false && scalar == 1.0)
  {
    for (int j = 0; j < N; ++j)
      for (int i = j; i < M; ++i){
        aux = A[i + j * LDA];
        A[i + j * LDA] = A[i * M + j];
        A[i * M + j] = aux;
      }
  }
  // should transpose A: copy transpose of A as row major
  else if (trans == true &&  scalar != 1.0)
  {
    for (int j = 0; j < N; ++j)
      for (int i = j; i < M; ++i){
        aux = A[i * LDA + j] * scalar;
        A[i * LDA + j] = A[i * M + j] * scalar;
        A[i * M + j] = aux;
      }
        
  }
  else
  {
    for (int j = 0; j < N; ++j)
      for (int i = j; i < M; ++i){
        aux = A[i * LDA + j] * scalar;
        A[i * LDA + j] = A[i * M + j] * scalar;
        A[i * M + j] = aux;
      }
  }
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
  // dereference arguments
  int M, N, K;
  float alpha = *_alpha, beta = *_beta;
  int LDA = *_LDA, LDB = *_LDB, LDC = *_LDC;

  bool transpose_A;
  bool transpose_B;
  
  // A is not transposed: copy dimensions as is
  if (*TRANSA == 'N' || *TRANSA == 'n')
  {
    M = *_M;
    K = *_K;
    transpose_A = false;
  }
  // B is transposed: invert dimensions
  else if (*TRANSA == 'T' || *TRANSA == 't' || *TRANSA == 'C' || *TRANSA == 'c') {
    M = *_K;
    K = *_M;
    transpose_A = true;
  }
  else {
    printf("Invalid value for TRANSA: %c\n", TRANSA);
    exit(1);
  }

  // B is not transposed: copy dimensions as is
  if (*TRANSB == 'N' || *TRANSB == 'n')
  {
    K = *_K;
    N = *_N;
    transpose_B = false;
  }
  // B is transposed: invert dimensions
  else if (*TRANSB == 'T' || *TRANSB == 't' || *TRANSB == 'C' || *TRANSB == 'c')
  {
    K = *_N;
    N = *_K;
    transpose_B = true;
  }
  else {
    printf("Invalid value for TRANSB: %c\n", TRANSA);
    exit(1);
  }

  // create variable size auxiliar matrices for gemmini matmul
  float *auxA, *auxB, *auxC;

  // copy fortran arguments to C
  auxA = copy(A, M, K, LDA, transpose_A, alpha, true); // alpha * op(A)
  auxB = copy(B, K, N, LDB, transpose_B, 1.0, true); // op(B)
  auxC = copy(C, M, N, LDC, false, beta, false); // beta * C

  // calculate matmul using gemmini
  tiled_matmul_auto(
    M, N, K,
    (elem_t*)auxA, (elem_t*)auxB, auxC, auxC,
    K, N, N, N,
    MVIN_SCALE_IDENTITY, MVIN_SCALE_IDENTITY, MVIN_SCALE_IDENTITY,
    NO_ACTIVATION, ACC_SCALE_IDENTITY, 0, false,
    false, false,
    true, false,
    1,
    OS
  );

  // copy matmul result to output matrix in row major order
  float aux;
  for (int j = 0; j < N; ++j)
    for (int i = j; i < M; ++i){
      aux = auxC[i + j * LDC];
      C[i + j * LDC] = auxC[i * M + j];
      C[i * M + j] = aux;
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
  // dereference arguments
  int M, N;
  float alpha = *_alpha, beta = *_beta;
  int LDA = *_LDA, INCX = *_incX, INCY = *_incY;

  bool transpose_A;
  float *auxA, *auxX, *auxY;

  // A is not transposed: copy dimensions as is
  if (*TRANSA == 'N' || *TRANSA == 'n')
  {
    M = *_M;
    N = *_N;
    transpose_A = false;
  }
  // A is transposed: invert M and N dimensions
  else if (*TRANSA == 'T' || *TRANSA == 't' || *TRANSA == 'C' || *TRANSA == 'c')
  {
    M = *_N;
    N = *_M;
    transpose_A = true;
  }
  // unknown tranpose argument: exit as error
  else
  {
    printf("Invalid value for TRANSA: %c\n", TRANSA);
    exit(1);
  }

  // calculate alpha*X if necessary
  if (alpha != 1.0){
    for (int i = 0; i < M; ++i)
      X[i] = X[i] * alpha;
  }

  // calculate beta*y if necessary
  if (beta != 1.0){
    for (int i = 0; i < M; ++i)
      Y[i] = Y[i] * beta;
  }

  auxX = X;
  auxY = Y;

  // create variable size auxiliar A matrix for gemmini
  auxA = copy(A, M, N, LDA, transpose_A, 1.0, true);

  // calculate matrix-vector product through gemmini
  tiled_matmul_auto(
    M, 1, N,
    (elem_t*)auxA, (elem_t*)auxX, auxY, Y,
    M, 1, 1, 1,
    MVIN_SCALE_IDENTITY, MVIN_SCALE_IDENTITY, MVIN_SCALE_IDENTITY,
    NO_ACTIVATION, ACC_SCALE_IDENTITY, 0, false,
    false, false,
    true, false,
    1,
    OS
  );
}
