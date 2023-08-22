f90 {
subroutine syrk2_single(a, c, alpha, ni, nj)
  real, dimension(ni, ni) :: a
  real, dimension(nj, ni) :: c
  real :: alpha
  integer :: ni, nj

  do i = 1, ni
    do j = 1, ni
      do k = 1, nj
        c(j, i) = c(j, i) + (alpha * a(k, i) * a(k, j))
      end do
    end do
  end do
end subroutine
}={
subroutine syrk2_single(a, c, alpha, ni, nj)
  real, dimension(ni, ni) :: a
  real, dimension(nj, ni) :: c
  real :: alpha
  integer :: ni, nj

  external :: sgemm

  call sgemm('N', 'T', ni, ni, ni, alpha, a, ni, a, ni, 1.0, c, nj)
end subroutine
}