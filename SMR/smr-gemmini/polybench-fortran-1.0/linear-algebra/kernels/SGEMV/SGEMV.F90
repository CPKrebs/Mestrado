! Include polybench common header. 
#include <fpolybench.h>

! Include benchmark-specific header. 
! Default data type is double, default size is 4000. 
#include "SGEMV.h"

      program SGEMV
      implicit none

      DATA_TYPE :: alpha
      DATA_TYPE :: beta
      POLYBENCH_2D_ARRAY_DECL(a,DATA_TYPE,N, N)
      POLYBENCH_1D_ARRAY_DECL(x1,DATA_TYPE,N)
      POLYBENCH_1D_ARRAY_DECL(y1,DATA_TYPE,N)
      polybench_declare_prevent_dce_vars
      polybench_declare_instruments

!     Allocation of Arrays
      POLYBENCH_ALLOC_2D_ARRAY(a, N, N)
      POLYBENCH_ALLOC_1D_ARRAY(aux, N)
      POLYBENCH_ALLOC_1D_ARRAY(x1, N)
      POLYBENCH_ALLOC_1D_ARRAY(aux2, N)
      POLYBENCH_ALLOC_1D_ARRAY(y1, N)
      POLYBENCH_ALLOC_1D_ARRAY(aux3, N)

!     Initialization
      call init_array(N, x1, y1, a, alpha, beta)

!     Kernel Execution
      polybench_start_instruments

      call kernel_SGEMV(N, x1, y1, a, alpha, beta)

      polybench_stop_instruments
      polybench_print_instruments

!     Prevent dead-code elimination. All live-out data must be printed
!     by the function call in argument. 
      polybench_prevent_dce(print_array(N, x1, y1, a));

!     Deallocation of Arrays 
      POLYBENCH_DEALLOC_ARRAY(a)
      POLYBENCH_DEALLOC_ARRAY(x1)
      POLYBENCH_DEALLOC_ARRAY(y1)

      contains

        subroutine init_array(n, x1, y1, a, alpha, beta)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        DATA_TYPE, dimension(n) :: x1
        DATA_TYPE, dimension(n) :: y1
        DATA_TYPE :: alpha, beta
        integer :: n
        integer :: i, j

        alpha = 7
        beta = 3

        do i = 1, n
          x1(i) = DBLE(i - 1) / DBLE(n)
          y1(i) = (DBLE(i - 1) + 1.0D0) / DBLE(n)
          do j = 1, n
            a(j, i) = ((DBLE(i - 1) * DBLE(j - 1))) / DBLE(n)
          end do
        end do
        end subroutine


        subroutine print_array(n, x1, y1, a)
        implicit none

        DATA_TYPE, dimension(n) :: x1
        DATA_TYPE, dimension(n) :: y1
        DATA_TYPE, dimension(n, n) :: a
        integer :: n
        integer :: i, j
        external :: printf_line, printf_num
        do i = 1, 4
          call printf_num(x1(i))
          call printf_num(y1(i))
          call printf_line()
        end do
        call printf_line()
        
        do i = n-3, n
          call printf_num(x1(i))
          call printf_num(y1(i))
          call printf_line()
        end do
        call printf_line()

        do i = 1, 4
          do j = 1, 4
            call printf_num(a(j,i))
          end do
          call printf_line()
        end do



        call printf_line()
        end subroutine


        subroutine kernel_SGEMV(n, x1, y1, a, alpha, beta)
        implicit none

        DATA_TYPE, dimension(n, n) :: a
        DATA_TYPE, dimension(n) :: x1
        DATA_TYPE, dimension(n) :: y1
        DATA_TYPE :: alpha, beta
        integer :: n
        integer :: i, j

!$pragma scop
        do i = 1, _PB_N
          x1(i) = (x1(i)*beta) 
          do j = 1, _PB_N
            x1(i) = x1(i) + (alpha * a(j, i) * y1(j))
          end do
        end do
!$pragma endscop
        end subroutine

      end program
