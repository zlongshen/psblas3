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
!
! File: psi_idx_ins_cnv.f90
!
! Subroutine: psi_idx_ins_cnv1
!   Converts a bunch of indices from global to local numbering. 
!   This routine is called while the descriptor is in the build state;
!   the idea is that if an index is not yet marked as local, it is a new 
!   connection to another process, i.e. a new entry into the halo. 
!   But we still need the mask, because we have to take out the column indices 
!   corresponding to row indices we do not own (see psb_cdins for how this is used). 
! 
! Arguments: 
!    nv        - integer                   Number of indices required 
!    idxin(:)  - integer                   Required indices, overwritten on output
!                                          output is negative for masked entries
!    desc      - type(psb_desc_type).    The communication descriptor.        
!    info      - integer.                  return code.
!    mask(:)   - logical, optional         Only do the conversion for specific indices.
!    
subroutine psi_idx_ins_cnv1(nv,idxin,desc,info,mask)
  use psi_mod, psb_protect_name => psi_idx_ins_cnv1
  use psb_descriptor_type
  use psb_serial_mod
  use psb_const_mod
  use psb_error_mod
  use psb_penv_mod
  implicit none
  integer, intent(in)    :: nv
  integer, intent(inout) ::  idxin(:)
  type(psb_desc_type), intent(inout) :: desc
  integer, intent(out) :: info
  logical, intent(in), optional, target :: mask(:)
  integer :: ictxt,mglob, nglob
  integer                :: np, me
  integer                :: nrow,ncol, err_act
  integer, allocatable   :: idxout(:)
  integer, parameter     :: relocsz=200
  character(len=20)      :: name
  logical, pointer       :: mask_(:)

  info = 0
  name = 'psb_idx_ins_cnv'
  call psb_erractionsave(err_act)

  ictxt = psb_cd_get_context(desc)
  mglob = psb_cd_get_global_rows(desc)
  nglob = psb_cd_get_global_cols(desc)
  nrow  = psb_cd_get_local_rows(desc)
  ncol  = psb_cd_get_local_cols(desc)

  call psb_info(ictxt, me, np)

  if (.not.psb_is_bld_desc(desc)) then 
    info = 3110
    call psb_errpush(info,name)
    goto 9999
  endif

  if (nv < 0) then 
    info = 1111
    call psb_errpush(info,name)
    goto 9999
  end if
  if (nv == 0) return
  

  if (size(idxin) < nv) then 
    info = 1111
    call psb_errpush(info,name)
    goto 9999
  end if


  if (present(mask)) then 
    if (size(mask) < nv) then 
      info = 1111
      call psb_errpush(info,name)
      goto 9999
    end if
    mask_ => mask
  else
    allocate(mask_(nv),stat=info)
    if (info /= 0) then 
      info = 4000 
      call psb_errpush(info,name)
      goto 9999
    endif
    mask_ = .true.
  endif

  allocate(idxout(nv),stat=info)
  if (info /= 0) then 
    info = 4000 
    call psb_errpush(info,name)
    goto 9999
  endif
  call psi_idx_ins_cnv2(nv,idxin,idxout,desc,info,mask_)
  idxin(1:nv) = idxout(1:nv)

  deallocate(idxout)

  if (.not.present(mask)) then 
    deallocate(mask_)
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

end subroutine psi_idx_ins_cnv1
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
!
!
! Subroutine: psi_idx_ins_cnv2
!   Converts a bunch of indices from global to local numbering. 
!   This routine is called while the descriptor is in the build state;
!   the idea is that if an index is not yet marked as local, it is a new 
!   connection to another process, i.e. a new entry into the halo. 
!   But we still need the mask, because we have to take out the column indices 
!   corresponding to row indices we do not own (see psb_cdins for how this is used). 
! 
! Arguments: 
!    nv        - integer                   Number of indices required 
!    idxin(:)  - integer                   Required indices
!    idxout(:) - integer                   Output values (negative for masked entries)
!    desc      - type(psb_desc_type).    The communication descriptor.        
!    info      - integer.                  return code.
!    mask(:)   - logical, optional         Only do the conversion for specific indices.
!    
subroutine psi_idx_ins_cnv2(nv,idxin,idxout,desc,info,mask)
  use psi_mod, psb_protect_name => psi_idx_ins_cnv2
  use psb_descriptor_type
  use psb_serial_mod
  use psb_const_mod
  use psb_error_mod
  use psb_penv_mod
  use psi_mod
  implicit none
  integer, intent(in)  :: nv, idxin(:)
  integer, intent(out) :: idxout(:)
  type(psb_desc_type), intent(inout) :: desc
  integer, intent(out) :: info
  logical, intent(in), optional, target :: mask(:)
  integer :: i,ictxt,k,mglob, nglob
  integer                :: np, me, isize
  integer                :: pnt_halo,nrow,ncol, nh, ip, err_act,lip,nxt
  integer, parameter     :: relocsz=200
  character(len=20)      :: name,ch_err
  logical, pointer       :: mask_(:)

  info = 0
  name = 'psb_idx_ins_cnv'
  call psb_erractionsave(err_act)

  ictxt = psb_cd_get_context(desc)
  mglob = psb_cd_get_global_rows(desc)
  nglob = psb_cd_get_global_cols(desc)
  nrow  = psb_cd_get_local_rows(desc)
  ncol  = psb_cd_get_local_cols(desc)

  call psb_info(ictxt, me, np)

  if (.not.psb_is_ok_desc(desc)) then 
    info = 3110
    call psb_errpush(info,name)
    goto 9999
  endif

  if (nv < 0) then 
    info = 1111
    call psb_errpush(info,name)
    goto 9999
  end if
  if (nv == 0) return

  if (size(idxin) < nv) then 
    info = 1111
    call psb_errpush(info,name)
    goto 9999
  end if

  if (size(idxout) < nv) then 
    info = 1111
    call psb_errpush(info,name)
    goto 9999
  end if

  if (present(mask)) then 
    if (size(mask) < nv) then 
      info = 1111
      call psb_errpush(info,name)
      goto 9999
    end if
    mask_ => mask
  else
    allocate(mask_(nv),stat=info)
    if (info /= 0) then 
      info = 4000 
      call psb_errpush(info,name)
      goto 9999
    endif
    mask_ = .true.
  endif



  if (psb_is_large_desc(desc)) then 
    do i = 1, nv
      if (mask_(i)) then 
        ip = idxin(i) 
        if ((ip < 1 ).or.(ip>mglob)) then 
          idxout(i) = -1
          cycle
        endif
        nxt = ncol + 1

        call SearchInsKeyVal(desc%ptree,ip,nxt,lip,info)        
        if (info >=0) then 
          if (nxt == lip) then 
            ncol = nxt
            isize = size(desc%loc_to_glob)
            if (ncol > isize) then 
              nh = ncol + max(nv,relocsz)
              call psb_realloc(nh,desc%loc_to_glob,info,pad=-1)
              if (info /= 0) then
                info=1
                ch_err='psb_realloc'
                call psb_errpush(4013,name,a_err=ch_err,i_err=(/info,0,0,0,0/))
                goto 9999
              end if
              isize = nh
            endif
            desc%loc_to_glob(nxt)  = ip
          endif
          info = 0
        else
          ch_err='SearchInsKeyVal'
          call psb_errpush(4013,name,a_err=ch_err,i_err=(/info,0,0,0,0/))
          goto 9999
        end if
        idxout(i) = lip
      else
        idxout(i) = -1
      end if
    enddo

  else

    if (.not.allocated(desc%halo_index)) then
      allocate(desc%halo_index(relocsz))
      desc%halo_index(:) = -1
    endif
    pnt_halo=1
    do while (desc%halo_index(pnt_halo)  /=   -1 )
      pnt_halo = pnt_halo + 1
    end do
    isize = size(desc%halo_index)

    do i = 1, nv
      if (mask_(i)) then 
        ip = idxin(i) 
        if ((ip < 1 ).or.(ip>mglob)) then 
          idxout(i) = -1
          cycle
        endif
        k  = desc%glob_to_loc(ip)
        if (k < -np) then
          k    = k + np
          k    = - k - 1
          ncol = ncol + 1      
          lip  = ncol
          desc%glob_to_loc(ip)   = ncol
          isize = size(desc%loc_to_glob)
          if (ncol > isize) then 
            nh = ncol + max(nv,relocsz)
            call psb_realloc(nh,desc%loc_to_glob,info,pad=-1)
            if (info /= 0) then
              info=3
              ch_err='psb_realloc'
              call psb_errpush(4013,name,a_err=ch_err,i_err=(/info,0,0,0,0/))
              goto 9999
            end if
            isize = nh
          endif
          desc%loc_to_glob(ncol) = ip
          isize = size(desc%halo_index)
          if ((pnt_halo+3) > isize) then
            nh = isize + max(nv,relocsz)
            call psb_realloc(nh,desc%halo_index,info,pad=-1)
            if (info /= 0) then
              info=4
              ch_err='psb_realloc'
              call psb_errpush(4013,name,a_err=ch_err,i_err=(/info,0,0,0,0/))
              goto 9999
            end if
            isize = nh 
          endif
          desc%halo_index(pnt_halo)   = k
          desc%halo_index(pnt_halo+1) = 1
          desc%halo_index(pnt_halo+2) = ncol
          pnt_halo                    = pnt_halo + 3
        else
          lip = k
        endif
        idxout(i) = lip
      else
        idxout(i) = -1
      end if
    enddo

  end if

  desc%matrix_data(psb_n_col_) = ncol

  if (.not.present(mask)) then 
    deallocate(mask_)
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


end subroutine psi_idx_ins_cnv2
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
!
!
! Subroutine: psi_idx_ins_cnvs
!   Converts an index  from global to local numbering. 
!   This routine is called while the descriptor is in the build state;
!   the idea is that if an index is not yet marked as local, it is a new 
!   connection to another process, i.e. a new entry into the halo. 
!   But we still need the mask, because we have to take out the column indices 
!   corresponding to row indices we do not own (see psb_cdins for how this is used). 
! 
! Arguments: 
!    idxin     - integer                   Required index s
!    idxout    - integer                   Output value  (negative for masked entries)
!    desc      - type(psb_desc_type).    The communication descriptor.        
!    info      - integer.                  return code.
!    mask      - logical, optional         Only do the conversion for specific indices.
!    
subroutine psi_idx_ins_cnvs(idxin,idxout,desc,info,mask)
  use psi_mod, psb_protect_name => psi_idx_ins_cnvs
  use psb_descriptor_type
  integer, intent(in)  :: idxin
  integer, intent(out) :: idxout
  type(psb_desc_type), intent(inout) :: desc
  integer, intent(out) :: info
  logical, intent(in), optional, target :: mask
  integer  :: iout(1) 
  logical  :: mask_

  if (present(mask)) then 
    mask_ = mask
  else
    mask_ = .true.
  endif
  call psi_idx_ins_cnv(1,(/idxin/),iout,desc,info,(/mask_/))
  idxout=iout(1)

  return

end subroutine psi_idx_ins_cnvs
