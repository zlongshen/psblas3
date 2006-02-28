!!$ 
!!$              Parallel Sparse BLAS  v2.0
!!$    (C) Copyright 2006 Salvatore Filippone    University of Rome Tor Vergata
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
! File: psb_dnrmi.f90
!
! Function: psb_dnrmi
!    Forms the approximated norm of a sparse matrix,                                                                  
!
!    normi := max(abs(sum(A(i,j))))                                                                                   
!
! Parameters:
!    a      -  type(<psb_dspmat_type>).   The sparse matrix containing A.
!    desc_a -  type(<psb_desc_type>).     The communication descriptor.
!    info   -  integer.                   Eventually returns an error code.
!
function psb_dnrmi(a,desc_a,info)  
  use psb_descriptor_type
  use psb_serial_mod
  use psb_check_mod
  use psb_error_mod
  implicit none

  type(psb_dspmat_type), intent(in)   :: a
  integer, intent(out)                :: info
  type(psb_desc_type), intent(in)     :: desc_a
  real(kind(1.d0))                    :: psb_dnrmi

  ! locals
  integer                  :: int_err(5), icontxt, nprow, npcol, myrow, mycol,&
       & err_act, n, iia, jja, ia, ja, temp(2), mdim, ndim, m
  real(kind(1.d0))         :: nrmi, dcsnmi
  character(len=20)        :: name, ch_err

  name='psb_dnrmi'
  if(psb_get_errstatus().ne.0) return 
  info=0
  call psb_erractionsave(err_act)

  icontxt=desc_a%matrix_data(psb_ctxt_)

  ! check on blacs grid 
  call blacs_gridinfo(icontxt, nprow, npcol, myrow, mycol)
  if (nprow == -1) then
    info = 2010
    call psb_errpush(info,name)
    goto 9999
  else if (npcol /= 1) then
    info = 2030
    int_err(1) = npcol
    call psb_errpush(info,name)
    goto 9999
  endif

  ia = 1
  ja = 1
  m = desc_a%matrix_data(psb_m_)
  n = desc_a%matrix_data(psb_n_)

  call psb_chkmat(m,n,ia,ja,desc_a%matrix_data,info,iia,jja)
  if(info.ne.0) then
     info=4010
     ch_err='psb_chkmat'
     call psb_errpush(info,name,a_err=ch_err)
     goto 9999
  end if

  if ((iia.ne.1).or.(jja.ne.1)) then
     info=3040
     call psb_errpush(info,name)
     goto 9999
  end if

  if ((m.ne.0).and.(n.ne.0)) then
     mdim = desc_a%matrix_data(psb_n_row_)
     ndim = desc_a%matrix_data(psb_n_col_)
     nrmi = dcsnmi('N',mdim,ndim,a%fida,&
          & a%descra,a%aspk,a%ia1,a%ia2,&
          & a%infoa,info)

     if(info.ne.0) then
        info=4010
        ch_err='dcsnmi'
        call psb_errpush(info,name,a_err=ch_err)
        goto 9999
     end if

     ! compute global max
     call dgamx2d(icontxt, 'A', ' ', ione, ione, nrmi, ione,&
          &temp ,temp,-ione ,-ione,-ione)
  else
     nrmi = 0.d0
  end if

  psb_dnrmi = nrmi

  call psb_erractionrestore(err_act)
  return  

9999 continue
  call psb_erractionrestore(err_act)

  if (err_act.eq.act_abort) then
     call psb_error(icontxt)
     return
  end if
  return
end function psb_dnrmi
