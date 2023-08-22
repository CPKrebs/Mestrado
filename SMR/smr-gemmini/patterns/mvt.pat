f90 {
subroutine mvt1_single(a, x1, y1, n)
  real, dimension(n, n) :: a
  real, dimension(n) :: x1
  real, dimension(n) :: y1
  integer :: n
  integer :: i, j

  do i = 1, n
    do j = 1, n
      x1(i) = x1(i) + (a(j, i) * y1(j))
    end do
  end do
end subroutine
}={
subroutine mvt1_single(a, x1, y1, n)
  real, dimension(n, n) :: a
  real, dimension(n) :: x1
  real, dimension(n) :: y1
  integer :: n
  integer :: i, j

  external :: sgemv

  call sgemv('T', n, n, 1.0, a, n, y1, 1, 1.0, x1, 1)
end subroutine
}

f90 {
subroutine mvt2_single(a, x2, y2, n)
  real, dimension(n, n) :: a
  real, dimension(n) :: x2
  real, dimension(n) :: y2
  integer :: n
  integer :: i, j

  do i = 1, n
    do j = 1, n
      x2(i) = x2(i) + (a(i, j) * y2(j))
    end do
  end do
end subroutine
}={
subroutine mvt2_single(a, x2, y2, n)
  real, dimension(n, n) :: a
  real, dimension(n) :: x2
  real, dimension(n) :: y2
  integer :: n
  integer :: i, j

  external :: sgemv

  call sgemv('N', n, n, 1.0, a, n, y2, 1, 1.0, x2, 1)
end subroutine
}