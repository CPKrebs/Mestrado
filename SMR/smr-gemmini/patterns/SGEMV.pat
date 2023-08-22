f90 {
subroutine mvt1_single(a, x1, y1, n, alpha, beta)
  real, dimension(n, n) :: a
  real, dimension(n) :: x1
  real, dimension(n) :: y1
  real :: alpha, beta
  integer :: n
  integer :: i, j

  do i = 1, n
    x1(i) = (x1(i)*beta)
    do j = 1, n
      x1(i) = x1(i) + (alpha * a(j, i) * y1(j))
    end do
  end do
end subroutine
}={
subroutine mvt1_single(a, x1, y1, n, alpha, beta)
  real, dimension(n, n) :: a
  real, dimension(n) :: x1
  real, dimension(n) :: y1
  real :: alpha, beta
  integer :: n
  integer :: i, j

  external :: sgemv

  call sgemv('N', n, n, alpha, a, n, y1, 1, beta, x1, 1)
end subroutine
}
