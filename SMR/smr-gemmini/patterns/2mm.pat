f90 {
subroutine p2mm1_single(tmp, a, b, alpha, ni, nj, nk)
  real, dimension(nj, ni) :: tmp
  real, dimension(nk, ni) :: a
  real, dimension(nj, nk) :: b
  real :: alpha
  integer :: ni, nj, nk

  do i = 1, ni
    do j = 1, nj
      tmp(j,i) = 0.0
      do k = 1, nk
        tmp(j,i) = tmp(j,i) + alpha * a(k,i) * b(j,k)
      end do
    end do
  end do
end subroutine
}={
subroutine p2mm1_single(tmp, a, b, alpha, ni, nj, nk)
  real, dimension(nj, ni) :: tmp
  real, dimension(nk, ni) :: a
  real, dimension(nj, nk) :: b
  real :: alpha
  integer :: ni, nj, nk

  external :: sgemm

  call sgemm('N', 'N', nj, ni, nk, alpha, b, nj, a, nk, 0.0, tmp, nj)
end subroutine
}

f90 {
subroutine p2mm2_single(tmp, c, d, beta, ni, nj, nl)
  real, dimension(nj, ni) :: tmp
  real, dimension(nl, nj) :: c
  real, dimension(nl, ni) :: d
  real :: beta
  integer :: ni, nj, nl

  do i = 1, ni
    do j = 1, nl
      d(j,i) = d(j,i) * beta
      do k = 1, nj
        d(j,i) = d(j,i) + tmp(k,i) * c(j,k)
      end do
    end do
  end do
end subroutine
}={
subroutine p2mm2_single(tmp, c, d, beta, ni, nj, nl)
  real, dimension(nj, ni) :: tmp
  real, dimension(nl, nj) :: c
  real, dimension(nl, ni) :: d
  real :: beta
  integer :: ni, nj, nl

  external :: sgemm

  call sgemm('N', 'N', nl, ni, nj, 1.0, c, nl, tmp, nj, beta, d, nl)
end subroutine
}