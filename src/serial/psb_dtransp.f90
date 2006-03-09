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
! File:  psb_dtransp.f90 
! Subroutine: 
! Parameters:

subroutine psb_dtransp(a,b,c,fmt)
  use psb_spmat_type
  use psb_tools_mod
  use psb_serial_mod, only : psb_ipcoo2csr, psb_ipcsr2coo, psb_fixcoo
  implicit none

  type(psb_dspmat_type)      :: a,b
  integer, optional          :: c
  character(len=*), optional :: fmt

  character(len=5)           :: fmt_
  integer  ::c_, info, nz 
  integer, pointer :: itmp(:)=>null()
  if (present(c)) then 
    c_=c
  else
    c_=1
  endif
  if (present(fmt)) then 
    fmt_ = fmt
  else 
    fmt_='CSR'
  endif
  if (associated(b%aspk)) call psb_spfree(b,info)
  call psb_sp_clone(a,b,info)
  
  if (b%fida=='CSR') then 
    call psb_ipcsr2coo(b,info)
  else if (b%fida=='COO') then 
    ! do nothing 
  else
    write(0,*) 'Unimplemented case in TRANSP '
  endif
!!$  nz = b%infoa(nnz_)
!!$  write(0,*) 'TRANSP CHECKS:',a%m,a%k,&
!!$       &minval(b%ia1(1:nz)),maxval(b%ia1(1:nz)),&
!!$       &minval(b%ia2(1:nz)),maxval(b%ia2(1:nz))
  itmp  => b%ia1
  b%ia1 => b%ia2
  b%ia2 => itmp

  b%m = a%k 
  b%k = a%m
!!$  write(0,*) 'Calling IPCOO2CSR from transp90 ',b%m,b%k
  if (fmt_=='CSR') then 
    call psb_ipcoo2csr(b,info)
    b%fida='CSR'
  else if (fmt_=='COO') then 
    call psb_fixcoo(b,info)
    b%fida='COO'
  else
    write(0,*) 'Unknown FMT in TRANSP : "',fmt_,'"'
  endif

  return
end subroutine psb_dtransp
