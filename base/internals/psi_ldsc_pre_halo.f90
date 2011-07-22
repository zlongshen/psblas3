!!$ 
!!$              Parallel Sparse BLAS  version 3.0
!!$    (C) Copyright 2006, 2007, 2008, 2009, 2010
!!$                       Salvatore Filippone    University of Rome Tor Vergata
!!$                       Alfredo Buttari        CNRS-IRIT, Toulouse
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
!
! File: psi_ldsc_pre_halo.f90
!
! Subroutine: psi_ldsc_pre_halo
!   Build initial versions of data exchange lists for the 
!   large index space case.
!   
! 
! Arguments: 
!    desc     - type(psb_desc_type).    The communication descriptor.        
!    ext_hv   - logical                   Should we work on the halo_index.
!    info     - integer.                  return code.
!
subroutine psi_ldsc_pre_halo(desc,ext_hv,info)
  use psb_descriptor_type
  use psb_serial_mod
  use psb_const_mod
  use psb_error_mod
  use psb_penv_mod
  use psb_realloc_mod
  use psi_mod, psb_protect_name => psi_ldsc_pre_halo
  implicit none
  type(psb_desc_type), intent(inout) :: desc
  logical, intent(in)  :: ext_hv
  integer, intent(out) :: info

  integer,allocatable :: helem(:),hproc(:)
  integer,allocatable :: tmphl(:)

  integer          ::  i,j,np,me,lhalo,nhalo,&
       & n_col, err_act,  key, ih, nh, idx, nk,icomm
  integer             :: ictxt,n_row
  character(len=20)   :: name,ch_err

  info = psb_success_
  name = 'psi_ldsc_pre_halo'
  call psb_erractionsave(err_act)

  ictxt = desc%get_context()
  icomm = desc%get_mpic()
  n_row = desc%get_local_rows()
  n_col = desc%get_local_cols()

  ! check on blacs grid 
  call psb_info(ictxt, me, np)
  if (np == -1) then
    info = psb_err_context_error_
    call psb_errpush(info,name)
    goto 9999
  endif


  if (.not.(psb_is_bld_desc(desc))) then 
    info = psb_err_invalid_cd_state_
    call psb_errpush(info,name)
    goto 9999
  end if

  if (.not.ext_hv) then
    call psi_bld_tmphalo(desc,info)
    if (info /= psb_success_) then 
      ch_err='psi_bld_tmphalo'
      call psb_errpush(info,name,a_err=ch_err)
      goto 9999
    end if
  end if

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)

  if (err_act == psb_act_ret_) then
    return
  else
    call psb_error(ictxt)
  end if
  return


end subroutine psi_ldsc_pre_halo
