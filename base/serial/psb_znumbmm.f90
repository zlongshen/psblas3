!!$ 
!!$              Parallel Sparse BLAS  version 2.2
!!$    (C) Copyright 2006/2007/2008
!!$                       Salvatore Filippone    University of Rome Tor Vergata
!!$                       Alfredo Buttari        University of Rome Tor Vergata
!!$ 
!!$  Redistribution and use in source and binary forms, with or without
!!$  modification, are permitted provided that the following conditions
!!$  are met:
!!$    1. Redistributions of source code must retain the above copyright
!!$       notice, this list of conditions and the following disclaimer.
!!$    2. Redistributions in binary form must reproduce the above copyright
!!$       notice, this list of conditions, and the following disclaimer in the
!!$       documentation and/or other materials provided with the distribution.
!!$    3. The name of the PSBLAS group or the names of its contributors may
!!$       not be used to endorse or promote products derived from this
!!$       software without specific written permission.
!!$ 
!!$  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
!!$  ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
!!$  TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
!!$  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE PSBLAS GROUP OR ITS CONTRIBUTORS
!!$  BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
!!$  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
!!$  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
!!$  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
!!$  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
!!$  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
!!$  POSSIBILITY OF SUCH DAMAGE.
!!$ 
!!$  
! File:  psb_dnumbmm.f90 
! Subroutine: 
! Arguments:
!
!
! Note: This subroutine performs the numerical product of two sparse matrices.
!       It is modeled after the SMMP package by R. Bank and C. Douglas, but is 
!       rewritten in Fortran 95 making use of our sparse matrix facilities.
!
!

subroutine psb_znumbmm(a,b,c)
  use psb_spmat_type
  use psb_serial_mod, psb_protect_name => psb_znumbmm
  implicit none

  type(psb_zspmat_type)         :: a,b,c
  complex(psb_dpk_), allocatable :: temp(:)
  integer                       :: info
  logical                   :: csra, csrb
  
  allocate(temp(max(a%m,a%k,b%m,b%k)),stat=info)
  if (info /= 0) then
    return
  endif
  call psb_realloc(size(c%ia1),c%aspk,info)
  !
  ! Note: we still have to test about possible performance hits. 
  !
  !
  csra = (toupper(a%fida(1:3))=='CSR')
  csrb = (toupper(b%fida(1:3))=='CSR')

  if (csra.and.csrb) then 
    call znumbmm(a%m,a%k,b%k,a%ia2,a%ia1,0,a%aspk,&
         & b%ia2,b%ia1,0,b%aspk,&
         & c%ia2,c%ia1,0,c%aspk,temp)
  else
    call inner_numbmm(a,b,c,temp,info)
  end if
  deallocate(temp) 
  return

contains 

  subroutine inner_numbmm(a,b,c,temp,info)
    type(psb_zspmat_type) :: a,b,c
    integer               :: info
    complex(psb_dpk_)      :: temp(:)
    integer, allocatable  :: iarw(:), iacl(:),ibrw(:),ibcl(:)
    complex(psb_dpk_), allocatable :: aval(:),bval(:)
    integer  :: maxlmn,i,j,m,n,k,l,nazr,nbzr,jj,minlm,minmn,minln
    complex(psb_dpk_)      :: ajj


    n = a%m
    m = a%k 
    l = b%k 
    maxlmn = max(l,m,n)
    allocate(iarw(maxlmn),iacl(maxlmn),ibrw(maxlmn),ibcl(maxlmn),&
         & aval(maxlmn),bval(maxlmn), stat=info)
    if (info /= 0) then 
      return
    endif

    do i = 1,maxlmn
      temp(i) = dzero
    end do
    minlm = min(l,m)
    minln = min(l,n)
    minmn = min(m,n)
    do  i = 1,n

      call psb_sp_getrow(i,a,nazr,iarw,iacl,aval,info)

      do jj=1, nazr
        j=iacl(jj)
        ajj = aval(jj)
        if ((j<1).or.(j>m)) then 
          write(0,*) ' NUMBMM: Problem with A ',i,jj,j,m
        endif
        call psb_sp_getrow(j,b,nbzr,ibrw,ibcl,bval,info)
        do k=1,nbzr
          if ((ibcl(k)<1).or.(ibcl(k)>maxlmn)) then 
            write(0,*) 'Problem in NUMBM 1:',j,k,ibcl(k),maxlmn
          else
            temp(ibcl(k)) = temp(ibcl(k)) + ajj * bval(k)
          endif
        enddo
      end do
      do  j = c%ia2(i),c%ia2(i+1)-1
        if((c%ia1(j)<1).or. (c%ia1(j) > maxlmn))  then 
          write(0,*) ' NUMBMM: output problem',i,j,c%ia1(j),maxlmn
        else
          c%aspk(j) = temp(c%ia1(j))
          temp(c%ia1(j)) = dzero
        endif
      end do
    end do




  end subroutine inner_numbmm


end subroutine psb_znumbmm
