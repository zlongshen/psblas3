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
! File:  psb_cspgtdiag.f90 
! Subroutine: 
! Arguments:

!*****************************************************************************
!*                                                                           *
!*                                                                           *
!*****************************************************************************
subroutine psb_cspgtdiag(a,d,info)
  ! Output is always in  COO format  into B, irrespective of 
  ! the input format 
  use psb_spmat_type
  use psb_error_mod
  use psb_const_mod
  use psb_serial_mod, psb_protect_name => psb_cspgtdiag
  implicit none

  type(psb_cspmat_type), intent(in)     :: a
  complex(psb_spk_), intent(inout)       :: d(:) 
  integer, intent(out)                  :: info

  type(psb_cspmat_type)     :: tmpa
  integer :: i,j, err_act, ii, rng, irb, nrb
  character(len=20)                 :: name, ch_err

  name='psb_cspgtdiag'
  info  = 0
  call psb_erractionsave(err_act)

  if (size(d) < min(a%k,a%m)) then 
    info=35
    call psb_errpush(info,name,i_err=(/2,size(d),0,0,0/))
    goto 9999
  end if
  d(:) = 0.d0
  if (a%fida == 'CSR') then 
    
    do i=1, min(a%m,a%k)
      do j=a%ia2(i),a%ia2(i+1)-1
        if (a%ia1(j) == i) then 
          d(i) = a%aspk(j)
        end if
      end do
    end do

  else if (a%fida == 'COO') then 

    do i=1,a%infoa(psb_nnz_)
      j=a%ia1(i)
      if ((j==a%ia2(i)).and.(j <= min(a%k,a%m)) .and.(j>0)) then 
        d(j) = a%aspk(i)
      endif
    enddo
    
 else if (a%fida == 'JAD') then 

    rng=min(a%m,a%k)
    nrb=16
    do i=1, rng, nrb
       irb=min(i+nrb-1,rng)
       call psb_sp_getblk(i,a,tmpa,info,lrw=irb)
       if(info /= 0) then
          info=4010
          ch_err='psb_spgtblk'
          call psb_errpush(info,name,a_err=ch_err)
          goto 9999
       end if

       do ii=1,tmpa%infoa(psb_nnz_)
          j=tmpa%ia1(ii)
          if ((j==tmpa%ia2(ii)).and.(j <= rng) .and.(j>0)) then 
             d(j) = tmpa%aspk(ii)
          endif
       enddo
       
    end do

 end if

 call psb_erractionrestore(err_act)
 return
 
9999 continue
 call psb_erractionrestore(err_act)
 if (err_act == psb_act_abort_) then
    call psb_error()
    return
 end if
 return
 
end subroutine psb_cspgtdiag
