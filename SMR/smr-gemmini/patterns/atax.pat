f90 {
subroutine atax_single(a, x, y, tmp, nx, ny)
  real, dimension(ny, nx) :: a
  real, dimension(ny) :: x
  real, dimension(ny) :: y
  real, dimension(nx) :: tmp
  integer :: nx, ny

  do i = 1, nx
    tmp(i) = 0.0D0
    do j = 1, ny
      tmp(i) = tmp(i) + (a(j, i) * x(j))
    end do
    do j = 1, ny
      y(j) = y(j) + a(j, i) * tmp(i)
    end do
  end do
end subroutine
}={
subroutine atax_single(a, x, y, tmp, nx, ny)
  real, dimension(ny, nx) :: a
  real, dimension(ny) :: x
  real, dimension(ny) :: y
  real, dimension(nx) :: tmp
  integer :: nx, ny

  external :: sgemv

  call sgemv('T', nx, ny, 1.0, a, ny, x, 1, 0.0, tmp, 1)
  call sgemv('N', ny, nx, 1.0, a, ny, tmp, 1, 0.0, y, 1)
end subroutine
}