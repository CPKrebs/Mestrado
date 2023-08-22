f90 {
subroutine bicg_single(a, r, q, p, s, nx, ny)
  real, dimension(ny, nx) :: a
  real, dimension(nx) :: r
  real, dimension(nx) :: q
  real, dimension(ny) :: p
  real, dimension(ny) :: s
  integer :: nx,ny
  integer :: i,j

  do i = 1, nx
    q(i) = 0.0D0
    do j = 1, ny
      s(j) = s(j) + (r(i) * a(j, i))
      q(i) = q(i) + (a(j, i) * p(j))
    end do
  end do
end subroutine
}={
subroutine bicg_single(a, r, q, p, s, nx, ny)
  real, dimension(ny, nx) :: a
  real, dimension(nx) :: r
  real, dimension(nx) :: q
  real, dimension(ny) :: p
  real, dimension(ny) :: s
  integer :: nx,ny

  external :: sgemv

  call sgemv('N', ny, nx, 1.0, a, ny, r, 1, 0.0, s, 1)
  call sgemv('T', nx, ny, 1.0, a, ny, p, 1, 0.0, q, 1)
end subroutine
}