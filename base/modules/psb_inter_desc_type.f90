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
! package: psb_inter_descriptor_type
!    Defines facilities for mapping between vectors belonging
!    to different spaces.
!
module psb_inter_descriptor_type
  use psb_spmat_type, only : psb_dspmat_type, psb_zspmat_type
  use psb_descriptor_type, only : psb_desc_type
  
  

  ! Inter-descriptor mapping data structures. 
  integer, parameter :: psb_map_kind_    = 1
  integer, parameter :: psb_map_data_    = 2
  integer, parameter :: psb_map_integer_ = 1
  integer, parameter :: psb_map_double_  = 2
  integer, parameter :: psb_map_complex_ = 3 
 
  integer, parameter :: psb_fw_tmp_kind_ = 5 
  integer, parameter :: psb_fw_tmp_sz_   = 6 
  integer, parameter :: psb_bk_tmp_kind_ = 7
  integer, parameter :: psb_bk_tmp_sz_   = 8
  integer, parameter :: psb_itd_data_size_=20


  type psb_d_map_type
    type(psb_dspmat_type) :: map_fw, map_bk
  end type psb_d_map_type
  type psb_z_map_type
    type(psb_zspmat_type) :: map_fw, map_bk
  end type psb_z_map_type
  
  type psb_inter_desc_type 
    integer, allocatable :: itd_data(:)
    type(psb_desc_type), pointer :: desc_1=>null(), desc_2=>null()
    integer, allocatable :: exch_fw_idx(:), exch_bk_idx(:)
    type(psb_desc_type)  :: desc_fw, desc_bk
    type(psb_d_map_type) :: dmap
    type(psb_z_map_type) :: zmap
  end type psb_inter_desc_type

  interface psb_forward_map
    module procedure psb_d_forward_map, psb_z_forward_map
  end interface

  interface psb_backward_map
    module procedure psb_d_backward_map, psb_z_backward_map
  end interface

  interface psb_is_ok_desc
    module procedure psb_is_ok_inter_desc
  end interface

  interface psb_is_asb_desc
    module procedure psb_is_asb_inter_desc
  end interface

  interface psb_inter_desc
    module procedure psb_d_inter_desc, psb_d_inter_desc_noidx,&
         & psb_z_inter_desc, psb_z_inter_desc_noidx
  end interface

  interface psb_sizeof
    module procedure psb_itd_sizeof,&
         & psb_d_map_sizeof, psb_z_map_sizeof
  end interface

  interface psb_linmap
    module procedure  psb_d_apply_linmap, psb_z_apply_linmap
  end interface

contains
 
  function psb_cd_get_map_kind(desc)    
    implicit none
    type(psb_inter_desc_type), intent(in) :: desc
    Integer                      :: psb_cd_get_map_kind
    if (psb_is_ok_desc(desc)) then 
      psb_cd_get_map_kind = desc%itd_data(psb_map_kind_) 
    else    
      psb_cd_get_map_kind = -1
    end if
  end function psb_cd_get_map_kind
 
  subroutine psb_cd_set_map_kind(map_kind,desc)    
    implicit none
    integer, intent(in)          :: map_kind
    type(psb_inter_desc_type), intent(inout) :: desc

    desc%itd_data(psb_map_kind_) = map_kind

  end subroutine psb_cd_set_map_kind
 
  function psb_cd_get_map_data(desc)    
    implicit none
    type(psb_inter_desc_type), intent(in) :: desc
    Integer                      :: psb_cd_get_map_data
    if (psb_is_ok_desc(desc)) then 
      psb_cd_get_map_data = desc%itd_data(psb_map_data_) 
    else    
      psb_cd_get_map_data = -1
    end if
  end function psb_cd_get_map_data
 
  subroutine psb_cd_set_map_data(map_data,desc)    
    implicit none
    integer, intent(in)          :: map_data
    type(psb_inter_desc_type), intent(inout) :: desc

    
    desc%itd_data(psb_map_data_) = map_data

  end subroutine psb_cd_set_map_data

 
  function psb_cd_get_fw_tmp_sz(desc)    
    implicit none
    type(psb_inter_desc_type), intent(in) :: desc
    Integer                      :: psb_cd_get_fw_tmp_sz
    
    psb_cd_get_fw_tmp_sz = desc%itd_data(psb_fw_tmp_sz_) 
  end function psb_cd_get_fw_tmp_sz

  function psb_cd_get_bk_tmp_sz(desc)    
    implicit none
    type(psb_inter_desc_type), intent(in) :: desc
    Integer                      :: psb_cd_get_bk_tmp_sz
    
    psb_cd_get_bk_tmp_sz = desc%itd_data(psb_bk_tmp_sz_) 
  end function psb_cd_get_bk_tmp_sz

  subroutine psb_cd_set_fw_tmp_sz(isz,desc)    
    implicit none
    type(psb_inter_desc_type), intent(inout) :: desc
    integer, intent(in)                      :: isz 
    
    desc%itd_data(psb_fw_tmp_sz_) =isz
  end subroutine psb_cd_set_fw_tmp_sz

  subroutine psb_cd_set_bk_tmp_sz(isz,desc)    
    implicit none
    type(psb_inter_desc_type), intent(inout) :: desc
    integer, intent(in)                      :: isz 
    
    desc%itd_data(psb_bk_tmp_sz_) =isz

  end subroutine psb_cd_set_bk_tmp_sz


  logical function psb_is_asb_inter_desc(desc)
    use psb_descriptor_type
    implicit none 
    type(psb_inter_desc_type), intent(in) :: desc

    psb_is_asb_inter_desc = .false.
    if (.not.allocated(desc%itd_data)) return
    if (.not.associated(desc%desc_1)) return
    if (.not.associated(desc%desc_2)) return
    psb_is_asb_inter_desc = &
         & psb_is_asb_desc(desc%desc_1).and.psb_is_asb_desc(desc%desc_2)    

  end function psb_is_asb_inter_desc

  logical function psb_is_ok_inter_desc(desc)
    use psb_descriptor_type
    implicit none 
    type(psb_inter_desc_type), intent(in) :: desc

    psb_is_ok_inter_desc = .false.
    if (.not.allocated(desc%itd_data)) return
    select case(desc%itd_data(psb_map_data_))
    case(psb_map_integer_, psb_map_double_, psb_map_complex_) 
      ! Ok go ahead
    case default
      ! Since it's false so far, simply return
      return
    end select
    if (.not.associated(desc%desc_1)) return
    if (.not.associated(desc%desc_2)) return
    psb_is_ok_inter_desc = &
         & psb_is_ok_desc(desc%desc_1).and.psb_is_ok_desc(desc%desc_2)    

  end function psb_is_ok_inter_desc


  function psb_d_map_sizeof(map)
    use psb_spmat_type
    implicit none
    type(psb_d_map_type), intent(in) :: map
    Integer                      :: psb_d_map_sizeof
    integer :: val

    val = 0

    val = val + psb_sizeof(map%map_fw)
    val = val + psb_sizeof(map%map_bk)
    psb_d_map_sizeof = val 
  end function psb_d_map_sizeof

  function psb_z_map_sizeof(map)
    use psb_spmat_type
    implicit none
    type(psb_z_map_type), intent(in) :: map
    Integer                      :: psb_z_map_sizeof
    integer :: val

    val = 0

    val = val + psb_sizeof(map%map_fw)
    val = val + psb_sizeof(map%map_bk)
    psb_z_map_sizeof = val 
  end function psb_z_map_sizeof

  function psb_itd_sizeof(desc)
    use psb_spmat_type
    use psb_descriptor_type
    implicit none 
    type(psb_inter_desc_type), intent(in) :: desc
    Integer                      :: psb_itd_sizeof
    integer :: val

    val = 0

    if (allocated(desc%itd_data))    val = val + 4*size(desc%itd_data)
    if (allocated(desc%exch_fw_idx)) val = val + 4*size(desc%exch_fw_idx)
    if (allocated(desc%exch_bk_idx)) val = val + 4*size(desc%exch_bk_idx)
    val = val + psb_sizeof(desc%desc_fw)
    val = val + psb_sizeof(desc%desc_bk)
    val = val + psb_sizeof(desc%dmap)
    val = val + psb_sizeof(desc%zmap)
    psb_itd_sizeof = val 
  end function psb_itd_sizeof
  
  function psb_d_inter_desc(map_kind,desc1,desc2,map_fw,map_bk,idx_fw,idx_bk)
    use psb_spmat_type
    use psb_descriptor_type
    use psb_serial_mod
    use psi_mod
    implicit none 
    type(psb_inter_desc_type)         :: psb_d_inter_desc    
    type(psb_desc_type), target       :: desc1, desc2
    type(psb_dspmat_type), intent(in) :: map_fw, map_bk
    integer, intent(in)               :: map_kind,idx_fw(:), idx_bk(:)
    !
    type(psb_inter_desc_type)    :: this
    integer                      :: info
    character(len=20), parameter :: name='psb_inter_desc'
    
    info = 0 
    if (psb_is_ok_desc(desc1)) then 
      this%desc_1=>desc1
    else
      info = 2
    endif
    if (psb_is_ok_desc(desc2)) then 
      this%desc_2=>desc2
    else
      info = 3
    endif

    if (info == 0) call psb_sp_clone(map_fw,this%dmap%map_fw,info)
    if (info == 0) call psb_sp_clone(map_bk,this%dmap%map_bk,info)
    if (info == 0) call psb_safe_cpy(idx_fw,this%exch_fw_idx,info)
    if (info == 0) call psb_safe_cpy(idx_bk,this%exch_bk_idx,info)
    if (info == 0) call psb_realloc(psb_itd_data_size_,this%itd_data,info) 
    if (info == 0) then
      call psb_cd_set_map_kind(map_kind, this)
      call psb_cd_set_map_data(psb_map_double_, this)
!!$      call psb_cd_set_fw_tmp_sz(map_fw%k, this)
!!$      call psb_cd_set_bk_tmp_sz(map_bk%k, this)
    end if
    if (info /= 0) then
      write(0,*) trim(name),' Invalid descriptor input'
      return
    end if   
    
    psb_d_inter_desc = this

  end function psb_d_inter_desc
  
  function psb_d_inter_desc_noidx(map_kind,desc1, desc2, map_fw, map_bk)
    use psb_spmat_type
    use psb_descriptor_type
    use psb_serial_mod
    use psi_mod
    implicit none 
    type(psb_inter_desc_type)         :: psb_d_inter_desc_noidx    
    type(psb_desc_type), target       :: desc1, desc2
    type(psb_dspmat_type), intent(in) :: map_fw, map_bk
    integer, intent(in)               :: map_kind
    !
    type(psb_inter_desc_type)    :: this
    integer                      :: info
    character(len=20), parameter :: name='psb_inter_desc'
    
    info = 0 
    select case(map_kind) 
    case (psb_map_aggr_)
      ! OK
    case default
      write(0,*) 'Bad map kind into psb_inter_desc ',map_kind
      info = 1
    end select    
    
    if (psb_is_ok_desc(desc1)) then 
      this%desc_1=>desc1
    else
      info = 2
    endif
    if (psb_is_ok_desc(desc2)) then 
      this%desc_2=>desc2
    else
      info = 3
    endif

    if (info == 0) call psb_sp_clone(map_fw,this%dmap%map_fw,info)
    if (info == 0) call psb_sp_clone(map_bk,this%dmap%map_bk,info)
    if (info == 0) call psb_realloc(psb_itd_data_size_,this%itd_data,info) 
    if (info == 0) then
      call psb_cd_set_map_kind(map_kind, this)
      call psb_cd_set_map_data(psb_map_double_, this)
!!$      call psb_cd_set_fw_tmp_sz(map_fw%k, this)
!!$      call psb_cd_set_bk_tmp_sz(map_bk%k, this)
    end if
    if (info /= 0) then
      write(0,*) trim(name),' Invalid descriptor input'
      return
    end if   
    
    psb_d_inter_desc_noidx = this

  end function psb_d_inter_desc_noidx

  function psb_z_inter_desc(map_kind,desc1, desc2, map_fw, map_bk, idx_fw, idx_bk)
    use psb_spmat_type
    use psb_descriptor_type
    use psb_serial_mod
    use psi_mod
    implicit none 
    type(psb_inter_desc_type)         :: psb_z_inter_desc    
    type(psb_desc_type), target       :: desc1, desc2
    type(psb_zspmat_type), intent(in) :: map_fw, map_bk
    integer, intent(in)               :: map_kind,idx_fw(:), idx_bk(:)
    !
    type(psb_inter_desc_type)    :: this
    integer                      :: info
    character(len=20), parameter :: name='psb_inter_desc'
    
    info = 0 
    if (psb_is_ok_desc(desc1)) then 
      this%desc_1=>desc1
    else
      info = 2
    endif
    if (psb_is_ok_desc(desc2)) then 
      this%desc_2=>desc2
    else
      info = 3
    endif

    if (info == 0) call psb_sp_clone(map_fw,this%zmap%map_fw,info)
    if (info == 0) call psb_sp_clone(map_bk,this%zmap%map_bk,info)
    if (info == 0) call psb_safe_cpy(idx_fw,this%exch_fw_idx,info)
    if (info == 0) call psb_safe_cpy(idx_bk,this%exch_bk_idx,info)
    if (info == 0) call psb_realloc(psb_itd_data_size_,this%itd_data,info) 
    if (info == 0) then
      call psb_cd_set_map_kind(map_kind, this)
      call psb_cd_set_map_data(psb_map_complex_, this)
!!$      call psb_cd_set_fw_tmp_sz(map_fw%k, this)
!!$      call psb_cd_set_bk_tmp_sz(map_bk%k, this)
    end if
    if (info /= 0) then
      write(0,*) trim(name),' Invalid descriptor input'
      return
    end if   
    
    psb_z_inter_desc = this

  end function psb_z_inter_desc
  
  function psb_z_inter_desc_noidx(map_kind,desc1, desc2, map_fw, map_bk)
    use psb_spmat_type
    use psb_descriptor_type
    use psb_serial_mod
    use psi_mod
    implicit none 
    type(psb_inter_desc_type)         :: psb_z_inter_desc_noidx    
    type(psb_desc_type), target       :: desc1, desc2
    type(psb_zspmat_type), intent(in) :: map_fw, map_bk
    integer, intent(in)               :: map_kind
    !
    type(psb_inter_desc_type)    :: this
    integer                      :: info
    character(len=20), parameter :: name='psb_inter_desc'
    
    info = 0 
    select case(map_kind) 
    case (psb_map_aggr_)
      ! OK
    case default
      write(0,*) 'Bad map kind into psb_inter_desc ',map_kind
      info = 1
    end select    
    
    if (psb_is_ok_desc(desc1)) then 
      this%desc_1=>desc1
    else
      info = 2
    endif
    if (psb_is_ok_desc(desc2)) then 
      this%desc_2=>desc2
    else
      info = 3
    endif

    if (info == 0) call psb_sp_clone(map_fw,this%zmap%map_fw,info)
    if (info == 0) call psb_sp_clone(map_bk,this%zmap%map_bk,info)
    if (info == 0) call psb_realloc(psb_itd_data_size_,this%itd_data,info) 
    if (info == 0) then
      call psb_cd_set_map_kind(map_kind, this)
      call psb_cd_set_map_data(psb_map_complex_, this)
!!$      call psb_cd_set_fw_tmp_sz(map_fw%k, this)
!!$      call psb_cd_set_bk_tmp_sz(map_bk%k, this)
    end if
    if (info /= 0) then
      write(0,*) trim(name),' Invalid descriptor input'
      return
    end if   
    
    psb_z_inter_desc_noidx = this

  end function psb_z_inter_desc_noidx
 



  !
  ! Takes a vector X from space desc%desc_1 and maps it onto
  ! desc%desc_2 under desc%map_fw possibly with communication
  ! due to exch_fw_idx
  !
  subroutine psb_d_forward_map(alpha,x,beta,y,desc,info,work)
    use psb_spmat_type
    use psb_descriptor_type
    use psb_comm_mod
    use psb_serial_mod
    use psi_mod
    implicit none 
    type(psb_inter_desc_type), intent(in) :: desc
    real(psb_dpk_), intent(in)     :: alpha,beta
    real(psb_dpk_), intent(inout)  :: x(:)
    real(psb_dpk_), intent(out)    :: y(:)
    integer, intent(out)             :: info 
    real(psb_dpk_), optional       :: work(:)

    !
    real(psb_dpk_), allocatable :: xt(:)
    integer                       :: itsz, i, j,totxch,totsnd,totrcv,&
         &  map_kind, map_data
    character(len=20), parameter  :: name='psb_forward_map'

    info = 0
    if (.not.psb_is_asb_desc(desc)) then 
      write(0,*) trim(name),' Invalid descriptor inupt'
      info = 1
      return 
    end if

    itsz     = psb_cd_get_fw_tmp_sz(desc)
    map_kind = psb_cd_get_map_kind(desc)
    map_data = psb_cd_get_map_data(desc)
    if (map_data /= psb_map_double_) then 
      write(0,*) trim(name),' Invalid descriptor inupt: map_data', &
           & map_data,psb_map_double_
      info = 1
      return 
    endif

    select case(map_kind)
    case(psb_map_aggr_)
      ! Ok, we just need to call a halo update on the base desc
      ! and a matrix-vector product. 
      call psb_halo(x,desc%desc_1,info,work=work)
      if (info == 0) call psb_csmm(alpha,desc%dmap%map_fw,x,beta,y,info)
        
      if (info /= 0) then 
        write(0,*) trim(name),' Error from inner routines',info
        info = -1
      end if

    case(psb_map_gen_linear_)

      call psb_linmap(alpha,x,beta,y,desc%dmap%map_fw,&
           & desc%desc_fw,desc%desc_1,desc%desc_2)
        
      if (info /= 0) then 
        write(0,*) trim(name),' Error from inner routines',info
        info = -1
      end if
      
      
    case default
      write(0,*) trim(name),' Invalid descriptor inupt'
      info = 1
      return 
    end select

  end subroutine psb_d_forward_map


  !
  ! Takes a vector X from space desc%desc_2 and maps it onto
  ! desc%desc_1 under desc%map_bk possibly with communication
  ! due to exch_bk_idx
  !
  subroutine psb_d_backward_map(alpha,x,beta,y,desc,info,work)
    use psb_spmat_type
    use psb_descriptor_type
    use psb_comm_mod
    use psb_serial_mod
    use psi_mod
    implicit none 
    type(psb_inter_desc_type), intent(in) :: desc
    real(psb_dpk_), intent(in)     :: alpha,beta
    real(psb_dpk_), intent(inout)  :: x(:)
    real(psb_dpk_), intent(out)    :: y(:)
    integer, intent(out)             :: info 
    real(psb_dpk_), optional       :: work(:)

    !
    real(psb_dpk_), allocatable :: xt(:)
    integer                       :: itsz, i, j,totxch,totsnd,totrcv,&
         & map_kind, map_data
    character(len=20), parameter  :: name='psb_backward_map'

    info = 0
    if (.not.psb_is_asb_desc(desc)) then 
      write(0,*) trim(name),' Invalid descriptor inupt'
      info = 1
      return 
    end if

    itsz     = psb_cd_get_bk_tmp_sz(desc)
    map_kind = psb_cd_get_map_kind(desc)
    map_data = psb_cd_get_map_data(desc)
    if (map_data /= psb_map_double_) then 
      write(0,*) trim(name),' Invalid descriptor inupt: map_data',&
           & map_data,psb_map_double_
      info = 1
      return 
    endif

    select case(map_kind)
    case(psb_map_aggr_)
      ! Ok, we just need to call a halo update and a matrix-vector product. 
      call psb_halo(x,desc%desc_2,info,work=work)
      if (info == 0) call psb_csmm(alpha,desc%dmap%map_bk,x,beta,y,info)
        
      if (info /= 0) then 
        write(0,*) trim(name),' Error from inner routines',info
        info = -1
      end if
      

    case(psb_map_gen_linear_)
      call psb_linmap(alpha,x,beta,y,desc%dmap%map_bk,&
           & desc%desc_bk,desc%desc_2,desc%desc_1)
      if (info /= 0) then 
        write(0,*) trim(name),' Error from inner routines',info
        info = -1
      end if
      
    case default
      write(0,*) trim(name),' Invalid descriptor inupt'
      info = 1
      return 
    end select

  end subroutine psb_d_backward_map


  !
  ! Takes a vector X from space desc%desc_1 and maps it onto
  ! desc%desc_2 under desc%map_fw possibly with communication
  ! due to exch_fw_idx
  !
  subroutine psb_z_forward_map(alpha,x,beta,y,desc,info,work)
    use psb_spmat_type
    use psb_descriptor_type
    use psb_comm_mod
    use psb_serial_mod
    use psi_mod
    implicit none 
    type(psb_inter_desc_type), intent(in) :: desc
    complex(psb_dpk_), intent(in)       :: alpha,beta
    complex(psb_dpk_), intent(inout)    :: x(:)
    complex(psb_dpk_), intent(out)      :: y(:)
    integer, intent(out)                  :: info 
    complex(psb_dpk_), optional         :: work(:)

    !
    complex(psb_dpk_), allocatable :: xt(:)
    integer                       :: itsz, i, j,totxch,totsnd,totrcv,&
         & map_kind, map_data
    character(len=20), parameter  :: name='psb_forward_map'

    info = 0
    if (.not.psb_is_asb_desc(desc)) then 
      write(0,*) trim(name),' Invalid descriptor inupt'
      info = 1
      return 
    end if

    itsz     = psb_cd_get_fw_tmp_sz(desc)
    map_kind = psb_cd_get_map_kind(desc)
    map_data = psb_cd_get_map_data(desc)
    if (map_data /= psb_map_complex_) then 
      write(0,*) trim(name),' Invalid descriptor inupt: map_data',&
           & map_data,psb_map_complex_
      info = 1
      return 
    endif

    select case(map_kind)
    case(psb_map_aggr_)
      ! Ok, we just need to call a halo update and a matrix-vector product. 
      call psb_halo(x,desc%desc_1,info,work=work)
      if (info == 0) call psb_csmm(alpha,desc%zmap%map_fw,x,beta,y,info)
        
      if (info /= 0) then 
        write(0,*) trim(name),' Error from inner routines',info
        info = -1
      end if
      
    case(psb_map_gen_linear_)
      call psb_linmap(alpha,x,beta,y,desc%zmap%map_fw,&
           & desc%desc_fw,desc%desc_1,desc%desc_2)
        
      if (info /= 0) then 
        write(0,*) trim(name),' Error from inner routines',info
        info = -1
      end if
      
    case default
      write(0,*) trim(name),' Invalid descriptor inupt'
      info = 1
      return 
    end select

  end subroutine psb_z_forward_map


  !
  ! Takes a vector X from space desc%desc_2 and maps it onto
  ! desc%desc_1 under desc%map_bk possibly with communication
  ! due to exch_bk_idx
  !
  subroutine psb_z_backward_map(alpha,x,beta,y,desc,info,work)
    use psb_spmat_type
    use psb_descriptor_type
    use psb_comm_mod
    use psb_serial_mod
    use psi_mod
    implicit none 
    type(psb_inter_desc_type), intent(in) :: desc
    complex(psb_dpk_), intent(in)       :: alpha,beta
    complex(psb_dpk_), intent(inout)    :: x(:)
    complex(psb_dpk_), intent(out)      :: y(:)
    integer, intent(out)                  :: info 
    complex(psb_dpk_), optional         :: work(:)

    !
    complex(psb_dpk_), allocatable :: xt(:)
    integer                       :: itsz, i, j,totxch,totsnd,totrcv,&
         & map_kind, map_data
    character(len=20), parameter  :: name='psb_backward_map'

    info = 0
    if (.not.psb_is_asb_desc(desc)) then 
      write(0,*) trim(name),' Invalid descriptor inupt'
      info = 1
      return 
    end if

    itsz     = psb_cd_get_bk_tmp_sz(desc)
    map_kind = psb_cd_get_map_kind(desc)
    map_data = psb_cd_get_map_data(desc)
    if (map_data /= psb_map_complex_) then 
      write(0,*) trim(name),' Invalid descriptor inupt: map_data',&
           & map_data,psb_map_complex_
      info = 1
      return 
    endif

    select case(map_kind)
    case(psb_map_aggr_)
      ! Ok, we just need to call a halo update and a matrix-vector product. 
      call psb_halo(x,desc%desc_2,info,work=work)
      if (info == 0) call psb_csmm(alpha,desc%zmap%map_bk,x,beta,y,info)
        
      if (info /= 0) then 
        write(0,*) trim(name),' Error from inner routines',info
        info = -1
      end if
      

    case(psb_map_gen_linear_)
      call psb_linmap(alpha,x,beta,y,desc%zmap%map_bk,&
           & desc%desc_bk,desc%desc_1,desc%desc_2)
        
      if (info /= 0) then 
        write(0,*) trim(name),' Error from inner routines',info
        info = -1
      end if
      
    case default
      write(0,*) trim(name),' Invalid descriptor inupt'
      info = 1
      return 
    end select

  end subroutine psb_z_backward_map



  subroutine psb_d_apply_linmap(alpha,x,beta,y,a_map,cd_xt,descin,descout)
    use psb_spmat_type
    use psb_descriptor_type
    use psb_comm_mod
    use psb_serial_mod
    use psi_mod
    implicit none 
    real(kind(1.d0)), intent(in)      :: alpha,beta
    real(kind(1.d0)), intent(inout)   :: x(:),y(:)
    type(psb_dspmat_type), intent(in) :: a_map
    type(psb_desc_type), intent(in)   :: cd_xt,descin, descout 

    integer :: nrt, nct, info
    real(kind(1.d0)), allocatable :: tmp(:)

    nrt = psb_cd_get_local_rows(cd_xt)
    nct = psb_cd_get_local_cols(cd_xt)
    allocate(tmp(nct),stat=info)
    if (info == 0) tmp(1:nrt) = x(1:nrt)
    if (info == 0) call psb_halo(tmp,cd_xt,info) 
    if (info == 0) call psb_csmm(alpha,a_map,tmp,beta,y,info)
    if (info /= 0) then 
      write(0,*) 'Error in apply_map'
    endif
    
  end subroutine psb_d_apply_linmap


  subroutine psb_z_apply_linmap(alpha,x,beta,y,a_map,cd_xt,descin,descout)
    use psb_spmat_type
    use psb_descriptor_type
    use psb_comm_mod
    use psb_serial_mod
    use psi_mod
    implicit none 
    complex(kind(1.d0)), intent(in)      :: alpha,beta
    complex(kind(1.d0)), intent(inout)   :: x(:),y(:)
    type(psb_zspmat_type), intent(in) :: a_map
    type(psb_desc_type), intent(in)   :: cd_xt,descin, descout 

    integer :: nrt, nct, info
    complex(kind(1.d0)), allocatable :: tmp(:)

    nrt = psb_cd_get_local_rows(cd_xt)
    nct = psb_cd_get_local_cols(cd_xt)
    allocate(tmp(nct),stat=info)
    if (info == 0) tmp(1:nrt) = x(1:nrt)
    if (info == 0) call psb_halo(tmp,cd_xt,info) 
    if (info == 0) call psb_csmm(alpha,a_map,tmp,beta,y,info)
    if (info /= 0) then 
      write(0,*) 'Error in apply_map'
    endif
    
  end subroutine psb_z_apply_linmap


end module psb_inter_descriptor_type