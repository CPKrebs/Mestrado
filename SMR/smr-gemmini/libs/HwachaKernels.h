
void sgemm_(unsigned char* TRANSA, unsigned char* TRANSB,
            int* _M, int* _N, int* _K,
            float* _alpha, float* A, int* _LDA,
            float* B, int* _LDB, float* _beta,
            float* C, int* _LDC);


void sgemv_(unsigned char* TRANSA,
            int* _M, int* _N,
            float* _alpha, float* A, int* _LDA,
            float* X, int* _incX, float* _beta,
            float* Y, int* _incY);
