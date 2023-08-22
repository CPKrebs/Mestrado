
#include <stdio.h>
#include <stdlib.h>
#include <vec-util.h>
#include <stdbool.h>

//#define stride_j 128

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
    } 

    asm volatile ("vsetcfg %0" : : "r" (VCFG(0, 0, 16, 0))); 

    int consumed;
    asm volatile ("vsetvl %0, %1" : "=r" (consumed)  : "r" (stride_A));

    void * vpset_vfblockaddr;
    asm volatile ("la %0, vpset_int" : "=r" (vpset_vfblockaddr));
    asm volatile ("vf 0(%0)" : : "r" (vpset_vfblockaddr));

    void * pre_vfblockaddr;
    void * main_vfblockaddr;
    void * post_vfblockaddr;
    asm volatile ("la %0, sgemm_pre" : "=r" (pre_vfblockaddr));
    asm volatile ("la %0, sgemm_4_4" : "=r" (main_vfblockaddr));
    asm volatile ("la %0, sgemm_post" : "=r" (post_vfblockaddr));

    asm volatile ("vsetvl %0, %1" : "=r" (consumed)  : "r" (stride_A));


    //if (transpose_A && transpose_B){
        //for (int jj = 0; jj < stride_B; jj+=stride_j) {    
            for (int i = 0; i < stride_A; i+=4) {
                for (int k = 0; k < stride_A;) {

                    asm volatile ("vsetvl %0, %1" : "=r" (consumed)  : "r" (stride_A));    
                
                    if (Beta == 0.0f)
                        for (int l = 0; l < consumed; l++) {
                            C[i*stride_A+l] = 0;
                            C[(i+1)*stride_A+l] = 0;
                            C[(i+2)*stride_A+l] = 0;
                            C[(i+3)*stride_A+l] = 0;
                        }
                    else if (Beta != 1.0f)
                        for (int l = 0; l < consumed; l++) {
                            C[i*stride_A+l] *= Beta;
                            C[(i+1)*stride_A+l] *= Beta;
                            C[(i+2)*stride_A+l] *= Beta;
                            C[(i+3)*stride_A+l] *= Beta;
                        }

                    // C rows 1, 2, 3, 4
                    asm volatile ("vmca va0, %0" : : "r" (&C[i*stride_A+k]));
                    asm volatile ("vmca va1, %0" : : "r" (&C[(i+1)*stride_A+k]));
                    asm volatile ("vmca va2, %0" : : "r" (&C[(i+2)*stride_A+k]));
                    asm volatile ("vmca va3, %0" : : "r" (&C[(i+3)*stride_A+k]));

                    asm volatile ("vf 0(%0)" : : "r" (pre_vfblockaddr));

                    //for (int j = jj; j < jj+stride_j; j+=4) {
                    for (int j = 0; j < stride_A; j+=4) {

                        // B row 1, 2, 3, 4
                        asm volatile ("vmca va4, %0" : : "r" (&A[j*stride_B+k]));
                        asm volatile ("vmca va5, %0" : : "r" (&A[(j+1)*stride_B+k]));
                        asm volatile ("vmca va6, %0" : : "r" (&A[(j+2)*stride_B+k]));
                        asm volatile ("vmca va7, %0" : : "r" (&A[(j+3)*stride_B+k]));

                        // A row 1, 2, 3, 4
                        if (Alpha == 1.0f)
                            asm volatile (  "vmcs vs1, %0\n"
                                            "vmcs vs2, %1\n"
                                            "vmcs vs3, %2\n"
                                            "vmcs vs4, %3\n"

                                            "vmcs vs5, %4\n"
                                            "vmcs vs6, %5\n"
                                            "vmcs vs7, %6\n"
                                            "vmcs vs8, %7\n"

                                            "vmcs vs9, %8\n"
                                            "vmcs vs10, %9\n"
                                            "vmcs vs11, %10\n"
                                            "vmcs vs12, %11\n"

                                            "vmcs vs13, %12\n"
                                            "vmcs vs14, %13\n"
                                            "vmcs vs15, %14\n"
                                            "vmcs vs16, %15"
                                        : 
                                        : "r" (B[j+i*stride_B]), "r" (B[j+i*stride_B+1]), "r" (B[j+i*stride_B+2]), "r" (B[j+i*stride_B+3]), 
                                        "r" (B[j+(i+1)*stride_B]), "r" (B[j+(i+1)*stride_B+1]), "r" (B[j+(i+1)*stride_B+2]), "r" (B[j+(i+1)*stride_B+3]),
                                        "r" (B[j+(i+2)*stride_B]), "r" (B[j+(i+2)*stride_B+1]), "r" (B[j+(i+2)*stride_B+2]), "r" (B[j+(i+2)*stride_B+3]),
                                        "r" (B[j+(i+3)*stride_B]), "r" (B[j+(i+3)*stride_B+1]), "r" (B[j+(i+3)*stride_B+2]), "r" (B[j+(i+3)*stride_B+3])
                                        );
                        else
                            asm volatile (  "vmcs vs1, %0\n"
                                            "vmcs vs2, %1\n"
                                            "vmcs vs3, %2\n"
                                            "vmcs vs4, %3\n"

                                            "vmcs vs5, %4\n"
                                            "vmcs vs6, %5\n"
                                            "vmcs vs7, %6\n"
                                            "vmcs vs8, %7\n"

                                            "vmcs vs9, %8\n"
                                            "vmcs vs10, %9\n"
                                            "vmcs vs11, %10\n"
                                            "vmcs vs12, %11\n"

                                            "vmcs vs13, %12\n"
                                            "vmcs vs14, %13\n"
                                            "vmcs vs15, %14\n"
                                            "vmcs vs16, %15"
                                        : 
                                        : "r" (B[j+i*stride_B] * Alpha), "r" (B[j+i*stride_B+1] * Alpha), "r" (B[j+i*stride_B+2] * Alpha), "r" (B[j+i*stride_B+3] * Alpha), 
                                        "r" (B[j+(i+1)*stride_B] * Alpha), "r" (B[j+(i+1)*stride_B+1] * Alpha), "r" (B[j+(i+1)*stride_B+2] * Alpha), "r" (B[j+(i+1)*stride_B+3] * Alpha),
                                        "r" (B[j+(i+2)*stride_B] * Alpha), "r" (B[j+(i+2)*stride_B+1] * Alpha), "r" (B[j+(i+2)*stride_B+2] * Alpha), "r" (B[j+(i+2)*stride_B+3] * Alpha),
                                        "r" (B[j+(i+3)*stride_B] * Alpha), "r" (B[j+(i+3)*stride_B+1] * Alpha), "r" (B[j+(i+3)*stride_B+2] * Alpha), "r" (B[j+(i+3)*stride_B+3] * Alpha)
                                        );
                        
                        asm volatile ("vf 0(%0)" : : "r" (main_vfblockaddr));
                    }
                    asm volatile ("vf 0(%0)" : : "r" (post_vfblockaddr));
                    k += consumed;
                }
            }
    /*    }
    }else if (transpose_A && !transpose_B){
        for (int jj = 0; jj < stride_B; jj+=stride_j) {   
            for (int i = 0; i < stride_A; i+=4) {
                for (int k = 0; k < stride_A;) {

                    asm volatile ("vsetvl %0, %1" : "=r" (consumed)  : "r" (stride_A));
                    
                    if (Beta == 0.0f)
                        for (int l = 0; l < consumed; l++) {
                            C[i*stride_A+l] = 0;
                            C[(i+1)*stride_A+l] = 0;
                            C[(i+2)*stride_A+l] = 0;
                            C[(i+3)*stride_A+l] = 0;
                        }
                    else if (Beta != 1.0f)
                        for (int l = 0; l < consumed; l++) {
                            C[i*stride_A+l] *= Beta;
                            C[(i+1)*stride_A+l] *= Beta;
                            C[(i+2)*stride_A+l] *= Beta;
                            C[(i+3)*stride_A+l] *= Beta;
                        }

                    // C rows 1, 2, 3, 4
                    asm volatile ("vmca va0, %0" : : "r" (&C[i*stride_A+k]));
                    asm volatile ("vmca va1, %0" : : "r" (&C[(i+1)*stride_A+k]));
                    asm volatile ("vmca va2, %0" : : "r" (&C[(i+2)*stride_A+k]));
                    asm volatile ("vmca va3, %0" : : "r" (&C[(i+3)*stride_A+k]));

                    asm volatile ("vf 0(%0)" : : "r" (pre_vfblockaddr));

                    for (int j = jj; j < jj+stride_j; j+=4) {

                        // B row 1, 2, 3, 4
                        asm volatile ("vmca va4, %0" : : "r" (&B[j*stride_B+k]));
                        asm volatile ("vmca va5, %0" : : "r" (&B[(j+1)*stride_B+k]));
                        asm volatile ("vmca va6, %0" : : "r" (&B[(j+2)*stride_B+k]));
                        asm volatile ("vmca va7, %0" : : "r" (&B[(j+3)*stride_B+k]));

                        // A row 1, 2, 3, 4
                        if (Alpha == 1.0f)
                            asm volatile (  "vmcs vs1, %0\n"
                                            "vmcs vs2, %1\n"
                                            "vmcs vs3, %2\n"
                                            "vmcs vs4, %3\n"

                                            "vmcs vs5, %4\n"
                                            "vmcs vs6, %5\n"
                                            "vmcs vs7, %6\n"
                                            "vmcs vs8, %7\n"

                                            "vmcs vs9, %8\n"
                                            "vmcs vs10, %9\n"
                                            "vmcs vs11, %10\n"
                                            "vmcs vs12, %11\n"

                                            "vmcs vs13, %12\n"
                                            "vmcs vs14, %13\n"
                                            "vmcs vs15, %14\n"
                                            "vmcs vs16, %15"
                                        : 
                                        : "r" (A[i+(j)*stride_B]), "r" (A[i+(j+1)*stride_B]), "r" (A[i+(j+2)*stride_B]), "r" (A[i+(j+3)*stride_B]), 
                                        "r" (A[i+(j)*stride_B+1]), "r" (A[i+(j+1)*stride_B+1]), "r" (A[i+(j+2)*stride_B+1]), "r" (A[i+(j+3)*stride_B+1]),
                                        "r" (A[i+(j)*stride_B+2]), "r" (A[i+(j+1)*stride_B+2]), "r" (A[i+(j+2)*stride_B+2]), "r" (A[i+(j+3)*stride_B+2]),
                                        "r" (A[i+(j)*stride_B+3]), "r" (A[i+(j+1)*stride_B+3]), "r" (A[i+(j+2)*stride_B+3]), "r" (A[i+(j+3)*stride_B+3])
                                        );
                        else 
                            asm volatile (  "vmcs vs1, %0\n"
                                            "vmcs vs2, %1\n"
                                            "vmcs vs3, %2\n"
                                            "vmcs vs4, %3\n"

                                            "vmcs vs5, %4\n"
                                            "vmcs vs6, %5\n"
                                            "vmcs vs7, %6\n"
                                            "vmcs vs8, %7\n"

                                            "vmcs vs9, %8\n"
                                            "vmcs vs10, %9\n"
                                            "vmcs vs11, %10\n"
                                            "vmcs vs12, %11\n"

                                            "vmcs vs13, %12\n"
                                            "vmcs vs14, %13\n"
                                            "vmcs vs15, %14\n"
                                            "vmcs vs16, %15"
                                        : 
                                        : "r" (A[i+(j)*stride_B] * Alpha), "r" (A[i+(j+1)*stride_B] * Alpha), "r" (A[i+(j+2)*stride_B] * Alpha), "r" (A[i+(j+3)*stride_B] * Alpha), 
                                        "r" (A[i+(j)*stride_B+1] * Alpha), "r" (A[i+(j+1)*stride_B+1] * Alpha), "r" (A[i+(j+2)*stride_B+1] * Alpha), "r" (A[i+(j+3)*stride_B+1] * Alpha),
                                        "r" (A[i+(j)*stride_B+2] * Alpha), "r" (A[i+(j+1)*stride_B+2] * Alpha), "r" (A[i+(j+2)*stride_B+2] * Alpha), "r" (A[i+(j+3)*stride_B+2] * Alpha),
                                        "r" (A[i+(j)*stride_B+3] * Alpha), "r" (A[i+(j+1)*stride_B+3] * Alpha), "r" (A[i+(j+2)*stride_B+3] * Alpha), "r" (A[i+(j+3)*stride_B+3] * Alpha)
                                        );

                        asm volatile ("vf 0(%0)" : : "r" (main_vfblockaddr));
                    }
                    asm volatile ("vf 0(%0)" : : "r" (post_vfblockaddr));
                    k += consumed;
                }
            }
        }
    }else if (!transpose_A && transpose_B){
        for (int jj = 0; jj < stride_B; jj+=stride_j) {   
            for (int i = 0; i < stride_A; i+=4) {
                for (int k = 0; k < stride_A;) {

                    asm volatile ("vsetvl %0, %1" : "=r" (consumed)  : "r" (stride_A));
                    
                    if (Beta == 0.0f)
                        for (int l = 0; l < consumed; l++) {
                            C[i*stride_A+l] = 0;
                            C[(i+1)*stride_A+l] = 0;
                            C[(i+2)*stride_A+l] = 0;
                            C[(i+3)*stride_A+l] = 0;
                        }
                    else if (Beta != 1.0f)
                        for (int l = 0; l < consumed; l++) {
                            C[i*stride_A+l] *= Beta;
                            C[(i+1)*stride_A+l] *= Beta;
                            C[(i+2)*stride_A+l] *= Beta;
                            C[(i+3)*stride_A+l] *= Beta;
                        }

                    // C rows 1, 2, 3, 4
                    asm volatile ("vmca va0, %0" : : "r" (&C[i*stride_A+k]));
                    asm volatile ("vmca va1, %0" : : "r" (&C[(i+1)*stride_A+k]));
                    asm volatile ("vmca va2, %0" : : "r" (&C[(i+2)*stride_A+k]));
                    asm volatile ("vmca va3, %0" : : "r" (&C[(i+3)*stride_A+k]));

                    asm volatile ("vf 0(%0)" : : "r" (pre_vfblockaddr));

                    for (int j = jj; j < jj+stride_j; j+=4) {

                        // B row 1, 2, 3, 4
                        asm volatile ("vmca va4, %0" : : "r" (&A[j*stride_B+k]));
                        asm volatile ("vmca va5, %0" : : "r" (&A[(j+1)*stride_B+k]));
                        asm volatile ("vmca va6, %0" : : "r" (&A[(j+2)*stride_B+k]));
                        asm volatile ("vmca va7, %0" : : "r" (&A[(j+3)*stride_B+k]));

                        // A row 1, 2, 3, 4
                        if (Alpha == 1.0f)
                            asm volatile (  "vmcs vs1, %0\n"
                                            "vmcs vs2, %1\n"
                                            "vmcs vs3, %2\n"
                                            "vmcs vs4, %3\n"

                                            "vmcs vs5, %4\n"
                                            "vmcs vs6, %5\n"
                                            "vmcs vs7, %6\n"
                                            "vmcs vs8, %7\n"

                                            "vmcs vs9, %8\n"
                                            "vmcs vs10, %9\n"
                                            "vmcs vs11, %10\n"
                                            "vmcs vs12, %11\n"

                                            "vmcs vs13, %12\n"
                                            "vmcs vs14, %13\n"
                                            "vmcs vs15, %14\n"
                                            "vmcs vs16, %15"
                                        : 
                                        : "r" (B[i+(j)*stride_B]), "r" (B[i+(j+1)*stride_B]), "r" (B[i+(j+2)*stride_B]), "r" (B[i+(j+3)*stride_B]), 
                                        "r" (B[i+(j)*stride_B+1]), "r" (B[i+(j+1)*stride_B+1]), "r" (B[i+(j+2)*stride_B+1]), "r" (B[i+(j+3)*stride_B+1]),
                                        "r" (B[i+(j)*stride_B+2]), "r" (B[i+(j+1)*stride_B+2]), "r" (B[i+(j+2)*stride_B+2]), "r" (B[i+(j+3)*stride_B+2]),
                                        "r" (B[i+(j)*stride_B+3]), "r" (B[i+(j+1)*stride_B+3]), "r" (B[i+(j+2)*stride_B+3]), "r" (B[i+(j+3)*stride_B+3])
                                        );
                        else
                            asm volatile (  "vmcs vs1, %0\n"
                                            "vmcs vs2, %1\n"
                                            "vmcs vs3, %2\n"
                                            "vmcs vs4, %3\n"

                                            "vmcs vs5, %4\n"
                                            "vmcs vs6, %5\n"
                                            "vmcs vs7, %6\n"
                                            "vmcs vs8, %7\n"

                                            "vmcs vs9, %8\n"
                                            "vmcs vs10, %9\n"
                                            "vmcs vs11, %10\n"
                                            "vmcs vs12, %11\n"

                                            "vmcs vs13, %12\n"
                                            "vmcs vs14, %13\n"
                                            "vmcs vs15, %14\n"
                                            "vmcs vs16, %15"
                                        : 
                                        : "r" (B[i+(j)*stride_B] * Alpha), "r" (B[i+(j+1)*stride_B] * Alpha), "r" (B[i+(j+2)*stride_B] * Alpha), "r" (B[i+(j+3)*stride_B] * Alpha), 
                                        "r" (B[i+(j)*stride_B+1] * Alpha), "r" (B[i+(j+1)*stride_B+1] * Alpha), "r" (B[i+(j+2)*stride_B+1] * Alpha), "r" (B[i+(j+3)*stride_B+1] * Alpha),
                                        "r" (B[i+(j)*stride_B+2] * Alpha), "r" (B[i+(j+1)*stride_B+2] * Alpha), "r" (B[i+(j+2)*stride_B+2] * Alpha), "r" (B[i+(j+3)*stride_B+2] * Alpha),
                                        "r" (B[i+(j)*stride_B+3] * Alpha), "r" (B[i+(j+1)*stride_B+3] * Alpha), "r" (B[i+(j+2)*stride_B+3] * Alpha), "r" (B[i+(j+3)*stride_B+3] * Alpha)
                                        );


                        asm volatile ("vf 0(%0)" : : "r" (main_vfblockaddr));
                    }
                    asm volatile ("vf 0(%0)" : : "r" (post_vfblockaddr));
                    k += consumed;
                }
            }
        }
    }else{
        for (int jj = 0; jj < stride_B; jj+=stride_j) {   
            for (int i = 0; i < stride_A; i+=4) {
                for (int k = 0; k < stride_A;) {

                    asm volatile ("vsetvl %0, %1" : "=r" (consumed)  : "r" (stride_A));
                    
                    if (Beta == 0.0f)
                        for (int l = 0; l < consumed; l++) {
                            C[i*stride_A+l] = 0;
                            C[(i+1)*stride_A+l] = 0;
                            C[(i+2)*stride_A+l] = 0;
                            C[(i+3)*stride_A+l] = 0;
                        }
                    else if (Beta != 1.0f)
                        for (int l = 0; l < consumed; l++) {
                            C[i*stride_A+l] *= Beta;
                            C[(i+1)*stride_A+l] *= Beta;
                            C[(i+2)*stride_A+l] *= Beta;
                            C[(i+3)*stride_A+l] *= Beta;
                        }

                    // C rows 1, 2, 3, 4
                    asm volatile ("vmca va0, %0" : : "r" (&C[i*stride_A+k]));
                    asm volatile ("vmca va1, %0" : : "r" (&C[(i+1)*stride_A+k]));
                    asm volatile ("vmca va2, %0" : : "r" (&C[(i+2)*stride_A+k]));
                    asm volatile ("vmca va3, %0" : : "r" (&C[(i+3)*stride_A+k]));

                    asm volatile ("vf 0(%0)" : : "r" (pre_vfblockaddr));

                    for (int j = jj; j < jj+stride_j; j+=4) {

                        // B row 1, 2, 3, 4
                        asm volatile ("vmca va4, %0" : : "r" (&B[j*stride_B+k]));
                        asm volatile ("vmca va5, %0" : : "r" (&B[(j+1)*stride_B+k]));
                        asm volatile ("vmca va6, %0" : : "r" (&B[(j+2)*stride_B+k]));
                        asm volatile ("vmca va7, %0" : : "r" (&B[(j+3)*stride_B+k]));

                        // A row 1, 2, 3, 4
                        if (Alpha == 1.0f)
                            asm volatile (  "vmcs vs1, %0\n"
                                            "vmcs vs2, %1\n"
                                            "vmcs vs3, %2\n"
                                            "vmcs vs4, %3\n"

                                            "vmcs vs5, %4\n"
                                            "vmcs vs6, %5\n"
                                            "vmcs vs7, %6\n"
                                            "vmcs vs8, %7\n"

                                            "vmcs vs9, %8\n"
                                            "vmcs vs10, %9\n"
                                            "vmcs vs11, %10\n"
                                            "vmcs vs12, %11\n"

                                            "vmcs vs13, %12\n"
                                            "vmcs vs14, %13\n"
                                            "vmcs vs15, %14\n"
                                            "vmcs vs16, %15"
                                        : 
                                        : "r" (A[j+i*stride_B]), "r" (A[j+i*stride_B+1]), "r" (A[j+i*stride_B+2]), "r" (A[j+i*stride_B+3]), 
                                        "r" (A[j+(i+1)*stride_B]), "r" (A[j+(i+1)*stride_B+1]), "r" (A[j+(i+1)*stride_B+2]), "r" (A[j+(i+1)*stride_B+3]),
                                        "r" (A[j+(i+2)*stride_B]), "r" (A[j+(i+2)*stride_B+1]), "r" (A[j+(i+2)*stride_B+2]), "r" (A[j+(i+2)*stride_B+3]),
                                        "r" (A[j+(i+3)*stride_B]), "r" (A[j+(i+3)*stride_B+1]), "r" (A[j+(i+3)*stride_B+2]), "r" (A[j+(i+3)*stride_B+3])
                                        );
                        else
                            asm volatile (  "vmcs vs1, %0\n"
                                            "vmcs vs2, %1\n"
                                            "vmcs vs3, %2\n"
                                            "vmcs vs4, %3\n"

                                            "vmcs vs5, %4\n"
                                            "vmcs vs6, %5\n"
                                            "vmcs vs7, %6\n"
                                            "vmcs vs8, %7\n"

                                            "vmcs vs9, %8\n"
                                            "vmcs vs10, %9\n"
                                            "vmcs vs11, %10\n"
                                            "vmcs vs12, %11\n"

                                            "vmcs vs13, %12\n"
                                            "vmcs vs14, %13\n"
                                            "vmcs vs15, %14\n"
                                            "vmcs vs16, %15"
                                        : 
                                        : "r" (A[j+i*stride_B] * Alpha), "r" (A[j+i*stride_B+1] * Alpha), "r" (A[j+i*stride_B+2] * Alpha), "r" (A[j+i*stride_B+3] * Alpha), 
                                        "r" (A[j+(i+1)*stride_B] * Alpha), "r" (A[j+(i+1)*stride_B+1] * Alpha), "r" (A[j+(i+1)*stride_B+2] * Alpha), "r" (A[j+(i+1)*stride_B+3] * Alpha),
                                        "r" (A[j+(i+2)*stride_B] * Alpha), "r" (A[j+(i+2)*stride_B+1] * Alpha), "r" (A[j+(i+2)*stride_B+2] * Alpha), "r" (A[j+(i+2)*stride_B+3] * Alpha),
                                        "r" (A[j+(i+3)*stride_B] * Alpha), "r" (A[j+(i+3)*stride_B+1] * Alpha), "r" (A[j+(i+3)*stride_B+2] * Alpha), "r" (A[j+(i+3)*stride_B+3] * Alpha)
                                        );

                        asm volatile ("vf 0(%0)" : : "r" (main_vfblockaddr));
                    }
                    asm volatile ("vf 0(%0)" : : "r" (post_vfblockaddr));
                    k += consumed;
                }
            }
        }
    }
    */
    asm volatile ("fence");
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
    // A is not transposed
    if (*TRANSA == 'N' || *TRANSA == 'n') {
        sgemv_n( _M, _N, _alpha, A, _LDA,X, _incX, _beta, Y, _incY);
    }
    // A is transposed
    else if (*TRANSA == 'T' || *TRANSA == 't' || *TRANSA == 'C' || *TRANSA == 'c') {
        sgemv_t( _M, _N, _alpha, A, _LDA,X, _incX, _beta, Y, _incY);
    }
}

void sgemv_n(   int* _M, int* _N,
                float* _alpha, float* A, int* _LDA,
                float* X, int* _incX, float* _beta,
                float* Y, int* _incY)
{
    // Dereference arguments
    float Alpha = *_alpha, Beta = *_beta;
    int stride_A = *_M, stride_B = *_N;

    //vsetcfg 2, 1, 1, 2 # Configure 2 integer, 1 double, 1 single, and 2 half registers
    asm volatile ("vsetcfg %0" : : "r" (VCFG(0, 0, 16, 0))); 

    int consumed;
    asm volatile ("vsetvl %0, %1" : "=r" (consumed)  : "r" (stride_A));

    void * vpset_vfblockaddr;
    asm volatile ("la %0, vpset_int" : "=r" (vpset_vfblockaddr));
    asm volatile ("vf 0(%0)" : : "r" (vpset_vfblockaddr));

    void * pre_vfblockaddr;
    void * main_vfblockaddr;
    void * post_vfblockaddr;

    asm volatile ("la %0, sgemv_pre" : "=r" (pre_vfblockaddr));
    asm volatile ("la %0, sgemv_4" : "=r" (main_vfblockaddr));
    asm volatile ("la %0, sgemv_post" : "=r" (post_vfblockaddr));
    
    asm volatile ("vsetvl %0, %1" : "=r" (consumed)  : "r" (stride_A));
    
    if (Beta == 0.0f)
        for (int j = 0; j < stride_B; j+=1){
            Y[j] = 0;
        }
    else if (Beta != 1.0f)
        for (int j = 0; j < stride_B; j+=1){
            Y[j] = Y[j] * Beta;
        }

    if (Alpha != 1.0f)
        for (int j = 0; j < stride_B; j+=1){
            X[j] = X[j] * Alpha;
        }
     
    for (int k = 0; k < stride_A;) {

        asm volatile ("vsetvl %0, %1" : "=r" (consumed)  : "r" (stride_A));

        asm volatile ("vmca va0, %0" : : "r" (&Y[k]));
        asm volatile ("vf 0(%0)" : : "r" (pre_vfblockaddr));

        for (int j = 0; j < stride_B; j+=4) {
            asm volatile ("vmca va2, %0" : : "r" (&A[j*stride_A+k]));
            asm volatile ("vmcs vs1, %0" : : "r" (X[j]));

            asm volatile ("vmca va3, %0" : : "r" (&A[(j+1)*stride_A+k]));
            asm volatile ("vmcs vs2, %0" : : "r" (X[j+1]));

            asm volatile ("vmca va4, %0" : : "r" (&A[(j+2)*stride_A+k]));
            asm volatile ("vmcs vs3, %0" : : "r" (X[j+2]));

            asm volatile ("vmca va5, %0" : : "r" (&A[(j+3)*stride_A+k]));
            asm volatile ("vmcs vs4, %0" : : "r" (X[j+3]));

            asm volatile ("vf 0(%0)" : : "r" (main_vfblockaddr));
        }
        asm volatile ("vf 0(%0)" : : "r" (post_vfblockaddr));
        k += consumed;
    }
    
    asm volatile ("fence");
}

void sgemv_t(   int* _M, int* _N,
                float* _alpha, float* A, int* _LDA,
                float* X, int* _incX, float* _beta,
                float* Y, int* _incY)
{
    // Dereference arguments
    float Alpha = *_alpha, Beta = *_beta;
    int stride_A = *_N, stride_B = *_M;

    //vsetcfg 2, 1, 1, 2 # Configure 2 integer, 1 double, 1 single, and 2 half registers
    asm volatile ("vsetcfg %0" : : "r" (VCFG(0, 0, 16, 0))); 

    int consumed;
    asm volatile ("vsetvl %0, %1" : "=r" (consumed)  : "r" (stride_A));

    void * vpset_vfblockaddr;
    asm volatile ("la %0, vpset_int" : "=r" (vpset_vfblockaddr));
    asm volatile ("vf 0(%0)" : : "r" (vpset_vfblockaddr));

    void * pre_vfblockaddr;
    void * main_vfblockaddr;
    void * post_vfblockaddr;

    asm volatile ("la %0, sgemv_pre" : "=r" (pre_vfblockaddr));
    asm volatile ("la %0, sgemv_4" : "=r" (main_vfblockaddr));
    asm volatile ("la %0, sgemv_post" : "=r" (post_vfblockaddr));
    
    asm volatile ("vsetvl %0, %1" : "=r" (consumed)  : "r" (stride_A));
    
    if (Beta == 0.0f)
        for (int j = 0; j < stride_B; j+=1){
            Y[j] = 0;
        }
    else if (Beta != 1.0f)
        for (int j = 0; j < stride_B; j+=1){
            Y[j] = Y[j] * Beta;
        }

    if (Alpha != 1.0f)
        for (int j = 0; j < stride_B; j+=1){
            X[j] = X[j] * Alpha;
        }
    
    
    float A_t[4*stride_A];
    for (int k = 0; k < stride_A;) {

        asm volatile ("vsetvl %0, %1" : "=r" (consumed)  : "r" (stride_A));

        asm volatile ("vmca va0, %0" : : "r" (&Y[k]));
        asm volatile ("vf 0(%0)" : : "r" (pre_vfblockaddr));
        
        for (int j = 0; j < stride_B; j+=4) {

            for (int i = 0; i < consumed; i+=1) {
                A_t[i]              = A[(i+k)*stride_B + j];
                A_t[stride_A+i]     = A[(i+k)*stride_B + j+1];
                A_t[2*stride_A+i]   = A[(i+k)*stride_B + j+2];
                A_t[3*stride_A+i]   = A[(i+k)*stride_B + j+3];
            }
                
            asm volatile ( "vmca va2, %0" : : "r" (&A_t[0]));
            asm volatile ( "vmcs vs1, %0" : : "r" (X[j]));

            asm volatile ( "vmca va3, %0" : : "r" (&A_t[stride_A]));
            asm volatile ( "vmcs vs2, %0" : : "r" (X[j+1]));

            asm volatile ( "vmca va4, %0" : : "r" (&A_t[2*stride_A]));
            asm volatile ( "vmcs vs3, %0" : : "r" (X[j+2]));
            
            asm volatile ( "vmca va5, %0" : : "r" (&A_t[3*stride_A]));
            asm volatile ( "vmcs vs4, %0" : : "r" (X[j+3]));

            asm volatile ("vf 0(%0)" : : "r" (main_vfblockaddr));
            //asm volatile ("fence");
        }
        asm volatile ("vf 0(%0)" : : "r" (post_vfblockaddr));
        k += consumed;
    }
    asm volatile ("fence");
}

/*
void sgemv_(unsigned char* TRANSA,
            int* _M, int* _N,
            float* _alpha, float* A, int* _LDA,
            float* X, int* _incX, float* _beta,
            float* Y, int* _incY)
{
    // Dereference arguments
    int M = *_M, N = *_N, stride_A, stride_B;
    float Alpha = *_alpha, Beta = *_beta;

    bool transpose_A;

    // A is not transposed
    if (*TRANSA == 'N' || *TRANSA == 'n') {
        stride_A = M;
        stride_B = N;
        transpose_A = true;
    }
    // A is transposed
    else if (*TRANSA == 'T' || *TRANSA == 't' || *TRANSA == 'C' || *TRANSA == 'c') {
        stride_A = N;
        stride_B = M;
        transpose_A = false;
    }

    //vsetcfg 2, 1, 1, 2 # Configure 2 integer, 1 double, 1 single, and 2 half registers
    asm volatile ("vsetcfg %0" : : "r" (VCFG(0, 0, 16, 0))); 

    int consumed;
    asm volatile ("vsetvl %0, %1" : "=r" (consumed)  : "r" (stride_A));

    void * vpset_vfblockaddr;
    asm volatile ("la %0, vpset_int" : "=r" (vpset_vfblockaddr));
    asm volatile ("vf 0(%0)" : : "r" (vpset_vfblockaddr));

    void * pre_vfblockaddr;
    void * main_vfblockaddr;
    void * post_vfblockaddr;

    asm volatile ("la %0, sgemv_pre" : "=r" (pre_vfblockaddr));
    asm volatile ("la %0, sgemv_4" : "=r" (main_vfblockaddr));
    asm volatile ("la %0, sgemv_post" : "=r" (post_vfblockaddr));
    
    asm volatile ("vsetvl %0, %1" : "=r" (consumed)  : "r" (stride_A));
    
    if (Beta == 0.0f)
        for (int j = 0; j < stride_B; j+=1){
            Y[j] = 0;
        }
    else if (Beta != 1.0f)
        for (int j = 0; j < stride_B; j+=1){
            Y[j] = Y[j] * Beta;
        }

    if (Alpha != 1.0f)
        for (int j = 0; j < stride_B; j+=1){
            X[j] = X[j] * Alpha;
        }
    
    if (transpose_A){    
        for (int k = 0; k < stride_A;) {

            asm volatile ("vsetvl %0, %1" : "=r" (consumed)  : "r" (stride_A));

            asm volatile ("vmca va0, %0" : : "r" (&Y[k]));
            asm volatile ("vf 0(%0)" : : "r" (pre_vfblockaddr));

            for (int j = 0; j < stride_B; j+=4) {
                asm volatile ("vmca va2, %0" : : "r" (&A[j*stride_A+k]));
                asm volatile ("vmcs vs1, %0" : : "r" (X[j]));

                asm volatile ("vmca va3, %0" : : "r" (&A[(j+1)*stride_A+k]));
                asm volatile ("vmcs vs2, %0" : : "r" (X[j+1]));

                asm volatile ("vmca va4, %0" : : "r" (&A[(j+2)*stride_A+k]));
                asm volatile ("vmcs vs3, %0" : : "r" (X[j+2]));

                asm volatile ("vmca va5, %0" : : "r" (&A[(j+3)*stride_A+k]));
                asm volatile ("vmcs vs4, %0" : : "r" (X[j+3]));

                asm volatile ("vf 0(%0)" : : "r" (main_vfblockaddr));
            }
            asm volatile ("vf 0(%0)" : : "r" (post_vfblockaddr));
            k += consumed;
        }
    }else{
        float A_t[4*stride_A];
        for (int k = 0; k < stride_A;) {

            asm volatile ("vsetvl %0, %1" : "=r" (consumed)  : "r" (stride_A));

            asm volatile ("vmca va0, %0" : : "r" (&Y[k]));
            asm volatile ("vf 0(%0)" : : "r" (pre_vfblockaddr));
           
            for (int j = 0; j < stride_B; j+=4) {

                for (int i = 0; i < consumed; i+=1) {
                    A_t[i]              = A[(i+k)*stride_B + j];
                    A_t[stride_A+i]     = A[(i+k)*stride_B + j+1];
                    A_t[2*stride_A+i]   = A[(i+k)*stride_B + j+2];
                    A_t[3*stride_A+i]   = A[(i+k)*stride_B + j+3];
                }
                    
                asm volatile ( "vmca va2, %0" : : "r" (&A_t[0]));
                asm volatile ( "vmcs vs1, %0" : : "r" (X[j]));

                asm volatile ( "vmca va3, %0" : : "r" (&A_t[stride_A]));
                asm volatile ( "vmcs vs2, %0" : : "r" (X[j+1]));

                asm volatile ( "vmca va4, %0" : : "r" (&A_t[2*stride_A]));
                asm volatile ( "vmcs vs3, %0" : : "r" (X[j+2]));
                
                asm volatile ( "vmca va5, %0" : : "r" (&A_t[3*stride_A]));
                asm volatile ( "vmcs vs4, %0" : : "r" (X[j+3]));

                asm volatile ("vf 0(%0)" : : "r" (main_vfblockaddr));
                //asm volatile ("fence");
            }
            asm volatile ("vf 0(%0)" : : "r" (post_vfblockaddr));
            k += consumed;
        }
    }
    asm volatile ("fence");
}
*/