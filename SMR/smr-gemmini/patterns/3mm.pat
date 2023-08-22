f90 {
subroutine p3mm_single(a, b, e, ni, nj, nk)
  real, dimension(nj, nk) :: b
  real, dimension(nj, ni) :: e
  real, dimension(nk, ni) :: a
  integer :: ni, nj, nk

  ! E := A*B
  do i = 1, ni
    do j = 1, nj
      e(j,i) = 0.0
      do k = 1, nk
        e(j,i) = e(j,i) + a(k,i) * b(j,k)
      end do
    end do
  end do
end subroutine
}={
subroutine p3mm_single(a, b, e, ni, nj, nk)
  real, dimension(nj, nk) :: b
  real, dimension(nj, ni) :: e
  real, dimension(nk, ni) :: a
  integer :: ni, nj, nk

  external :: sgemm

  call sgemm('N', 'N', nj, ni, nk, 1.0, b, nk, a, nj, 0.0, e, nj)
end subroutine
}