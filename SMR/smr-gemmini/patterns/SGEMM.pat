f90 {
subroutine gemm_single(m, n, k, alpha, A, B, beta, C)
  integer :: m, n, k
  real, dimension(m, n) :: C
  real, dimension(m, k) :: A
  real, dimension(k, n) :: B
  real :: alpha, beta

  do nn = 1, n
    do mm = 1, m
      c(mm, nn) = c(mm, nn) * beta
      do i  = 1, k
        c(mm, nn) = c(mm, nn) + (alpha * b(i, nn) * a(mm, i))
      end do
    end do
  end do
end subroutine
}={
subroutine gemm_single(m, n, k, alpha, A, B, beta, C)
  integer :: m, n, k
  real, dimension(m, n) :: C
  real, dimension(m, k) :: A
  real, dimension(k, n) :: B
  real :: alpha, beta

  external :: sgemm
  call sgemm('T', 'N', m, n, k, alpha, A, m, B, k, beta, C, m)
end subroutine
}