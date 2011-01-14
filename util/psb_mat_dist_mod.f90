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
module psb_mat_dist_mod

  interface psb_matdist
    subroutine smatdist(a_glob, a, ictxt, desc_a,&
         & b_glob, b, info, parts, v, inroot,fmt,mold)
      !
      ! an utility subroutine to distribute a matrix among processors
      ! according to a user defined data distribution, using
      ! sparse matrix subroutines.
      !
      !  type(d_spmat)                            :: a_glob
      !     on entry: this contains the global sparse matrix as follows:
      !        a%fida == 'csr'
      !        a%aspk for coefficient values
      !        a%ia1  for column indices
      !        a%ia2  for row pointers
      !        a%m    for number of global matrix rows
      !        a%k    for number of global matrix columns
      !     on exit : undefined, with unassociated pointers.
      !
      !  type(d_spmat)                            :: a
      !     on entry: fresh variable.
      !     on exit : this will contain the local sparse matrix.
      !
      !       interface parts
      !         !   .....user passed subroutine.....
      !         subroutine parts(global_indx,n,np,pv,nv)
      !           implicit none
      !           integer, intent(in)  :: global_indx, n, np
      !           integer, intent(out) :: nv
      !           integer, intent(out) :: pv(*)
      !
      !       end subroutine parts
      !       end interface
      !     on entry:  subroutine providing user defined data distribution.
      !        for each global_indx the subroutine should return
      !        the list  pv of all processes owning the row with
      !        that index; the list will contain nv entries.
      !        usually nv=1; if nv >1 then we have an overlap in the data
      !        distribution.
      !
      !  integer                                  :: ictxt
      !     on entry: blacs context.
      !     on exit : unchanged.
      !
      !  type (desc_type)                  :: desc_a
      !     on entry: fresh variable.
      !     on exit : the updated array descriptor
      !
      !  real(psb_dpk_),  optional      :: b_glob(:)
      !     on entry: this contains right hand side.
      !     on exit :
      !
      !  real(psb_dpk_), allocatable, optional      :: b(:)
      !     on entry: fresh variable.
      !     on exit : this will contain the local right hand side.
      !
      !  integer, optional    :: inroot
      !     on entry: specifies processor holding a_glob. default: 0
      !     on exit : unchanged.
      !
      use psb_sparse_mod, only : psb_sspmat_type, psb_desc_type, psb_spk_,&
           & psb_s_base_sparse_mat
      implicit none

      ! parameters
      type(psb_sspmat_type)      :: a_glob
      real(psb_spk_)             :: b_glob(:)
      integer                    :: ictxt
      type(psb_sspmat_type)      :: a
      real(psb_spk_), allocatable  :: b(:)
      type(psb_desc_type)        :: desc_a
      integer, intent(out)       :: info
      integer, optional          :: inroot
      character(len=*), optional :: fmt
      class(psb_s_base_sparse_mat), optional :: mold
 
      integer                    :: v(:)
      interface 
        subroutine parts(global_indx,n,np,pv,nv)
          implicit none
          integer, intent(in)  :: global_indx, n, np
          integer, intent(out) :: nv
          integer, intent(out) :: pv(*) 
        end subroutine parts
      end interface
      optional                  :: parts, v

    end subroutine smatdist
    subroutine dmatdist(a_glob, a, ictxt, desc_a,&
         & b_glob, b, info, parts, v, inroot,fmt,mold)
      !
      ! an utility subroutine to distribute a matrix among processors
      ! according to a user defined data distribution, using
      ! sparse matrix subroutines.
      !
      !  type(d_spmat)                            :: a_glob
      !     on entry: this contains the global sparse matrix as follows:
      !        a%fida == 'csr'
      !        a%aspk for coefficient values
      !        a%ia1  for column indices
      !        a%ia2  for row pointers
      !        a%m    for number of global matrix rows
      !        a%k    for number of global matrix columns
      !     on exit : undefined, with unassociated pointers.
      !
      !  type(d_spmat)                            :: a
      !     on entry: fresh variable.
      !     on exit : this will contain the local sparse matrix.
      !
      !       interface parts
      !         !   .....user passed subroutine.....
      !         subroutine parts(global_indx,n,np,pv,nv)
      !           implicit none
      !           integer, intent(in)  :: global_indx, n, np
      !           integer, intent(out) :: nv
      !           integer, intent(out) :: pv(*)
      !
      !       end subroutine parts
      !       end interface
      !     on entry:  subroutine providing user defined data distribution.
      !        for each global_indx the subroutine should return
      !        the list  pv of all processes owning the row with
      !        that index; the list will contain nv entries.
      !        usually nv=1; if nv >1 then we have an overlap in the data
      !        distribution.
      !
      !  integer                                  :: ictxt
      !     on entry: blacs context.
      !     on exit : unchanged.
      !
      !  type (desc_type)                  :: desc_a
      !     on entry: fresh variable.
      !     on exit : the updated array descriptor
      !
      !  real(psb_dpk_),  optional      :: b_glob(:)
      !     on entry: this contains right hand side.
      !     on exit :
      !
      !  real(psb_dpk_), allocatable, optional      :: b(:)
      !     on entry: fresh variable.
      !     on exit : this will contain the local right hand side.
      !
      !  integer, optional    :: inroot
      !     on entry: specifies processor holding a_glob. default: 0
      !     on exit : unchanged.
      !
      use psb_sparse_mod, only : psb_dspmat_type, psb_dpk_, psb_desc_type,&
           & psb_d_base_sparse_mat
      implicit none

      ! parameters
      type(psb_dspmat_type)      :: a_glob
      real(psb_dpk_)             :: b_glob(:)
      integer                    :: ictxt
      type(psb_dspmat_type)      :: a
      real(psb_dpk_), allocatable  :: b(:)
      type(psb_desc_type)        :: desc_a
      integer, intent(out)       :: info
      integer, optional          :: inroot
      character(len=*), optional :: fmt
      class(psb_d_base_sparse_mat), optional :: mold

      integer                    :: v(:)
      interface 
        subroutine parts(global_indx,n,np,pv,nv)
          implicit none
          integer, intent(in)  :: global_indx, n, np
          integer, intent(out) :: nv
          integer, intent(out) :: pv(*) 
        end subroutine parts
      end interface
      optional                  :: parts, v

    end subroutine dmatdist

    subroutine cmatdist(a_glob, a, ictxt, desc_a,&
         & b_glob, b, info, parts, v, inroot,fmt,mold)
      !
      ! an utility subroutine to distribute a matrix among processors
      ! according to a user defined data distribution, using
      ! sparse matrix subroutines.
      !
      !  type(d_spmat)                            :: a_glob
      !     on entry: this contains the global sparse matrix as follows:
      !        a%fida == 'csr'
      !        a%aspk for coefficient values
      !        a%ia1  for column indices
      !        a%ia2  for row pointers
      !        a%m    for number of global matrix rows
      !        a%k    for number of global matrix columns
      !     on exit : undefined, with unassociated pointers.
      !
      !  type(d_spmat)                            :: a
      !     on entry: fresh variable.
      !     on exit : this will contain the local sparse matrix.
      !
      !       interface parts
      !         !   .....user passed subroutine.....
      !         subroutine parts(global_indx,n,np,pv,nv)
      !           implicit none
      !           integer, intent(in)  :: global_indx, n, np
      !           integer, intent(out) :: nv
      !           integer, intent(out) :: pv(*)
      !
      !       end subroutine parts
      !       end interface
      !     on entry:  subroutine providing user defined data distribution.
      !        for each global_indx the subroutine should return
      !        the list  pv of all processes owning the row with
      !        that index; the list will contain nv entries.
      !        usually nv=1; if nv >1 then we have an overlap in the data
      !        distribution.
      !
      !  integer                                  :: ictxt
      !     on entry: blacs context.
      !     on exit : unchanged.
      !
      !  type (desc_type)                  :: desc_a
      !     on entry: fresh variable.
      !     on exit : the updated array descriptor
      !
      !  real(psb_dpk_),  optional      :: b_glob(:)
      !     on entry: this contains right hand side.
      !     on exit :
      !
      !  real(psb_dpk_), allocatable, optional      :: b(:)
      !     on entry: fresh variable.
      !     on exit : this will contain the local right hand side.
      !
      !  integer, optional    :: inroot
      !     on entry: specifies processor holding a_glob. default: 0
      !     on exit : unchanged.
      !
      use psb_sparse_mod, only : psb_cspmat_type, psb_spk_, psb_desc_type,&
           & psb_c_base_sparse_mat
      implicit none

      ! parameters
      type(psb_cspmat_type)      :: a_glob
      complex(psb_spk_)          :: b_glob(:)
      integer                    :: ictxt
      type(psb_cspmat_type)      :: a
      complex(psb_spk_), allocatable  :: b(:)
      type(psb_desc_type)        :: desc_a
      integer, intent(out)       :: info
      integer, optional          :: inroot
      character(len=*), optional :: fmt
      class(psb_c_base_sparse_mat), optional :: mold

      integer                    :: v(:)
      interface 
        subroutine parts(global_indx,n,np,pv,nv)
          implicit none
          integer, intent(in)  :: global_indx, n, np
          integer, intent(out) :: nv
          integer, intent(out) :: pv(*) 
        end subroutine parts
      end interface
      optional                  :: parts, v

    end subroutine cmatdist

    subroutine zmatdist(a_glob, a, ictxt, desc_a,&
         & b_glob, b, info, parts, v, inroot,fmt,mold)
      !
      ! an utility subroutine to distribute a matrix among processors
      ! according to a user defined data distribution, using
      ! sparse matrix subroutines.
      !
      !  type(d_spmat)                            :: a_glob
      !     on entry: this contains the global sparse matrix as follows:
      !        a%fida == 'csr'
      !        a%aspk for coefficient values
      !        a%ia1  for column indices
      !        a%ia2  for row pointers
      !        a%m    for number of global matrix rows
      !        a%k    for number of global matrix columns
      !     on exit : undefined, with unassociated pointers.
      !
      !  type(d_spmat)                            :: a
      !     on entry: fresh variable.
      !     on exit : this will contain the local sparse matrix.
      !
      !       interface parts
      !         !   .....user passed subroutine.....
      !         subroutine parts(global_indx,n,np,pv,nv)
      !           implicit none
      !           integer, intent(in)  :: global_indx, n, np
      !           integer, intent(out) :: nv
      !           integer, intent(out) :: pv(*)
      !
      !       end subroutine parts
      !       end interface
      !     on entry:  subroutine providing user defined data distribution.
      !        for each global_indx the subroutine should return
      !        the list  pv of all processes owning the row with
      !        that index; the list will contain nv entries.
      !        usually nv=1; if nv >1 then we have an overlap in the data
      !        distribution.
      !
      !  integer                                  :: ictxt
      !     on entry: blacs context.
      !     on exit : unchanged.
      !
      !  type (desc_type)                  :: desc_a
      !     on entry: fresh variable.
      !     on exit : the updated array descriptor
      !
      !  real(psb_dpk_),  optional      :: b_glob(:)
      !     on entry: this contains right hand side.
      !     on exit :
      !
      !  real(psb_dpk_), allocatable, optional      :: b(:)
      !     on entry: fresh variable.
      !     on exit : this will contain the local right hand side.
      !
      !  integer, optional    :: inroot
      !     on entry: specifies processor holding a_glob. default: 0
      !     on exit : unchanged.
      !
      use psb_sparse_mod, only : psb_zspmat_type, psb_dpk_, psb_desc_type,&
           & psb_z_base_sparse_mat
      implicit none

      ! parameters
      type(psb_zspmat_type)      :: a_glob
      complex(psb_dpk_)          :: b_glob(:)
      integer                    :: ictxt
      type(psb_zspmat_type)      :: a
      complex(psb_dpk_), allocatable  :: b(:)
      type(psb_desc_type)        :: desc_a
      integer, intent(out)       :: info
      integer, optional          :: inroot
      character(len=*), optional :: fmt
      class(psb_z_base_sparse_mat), optional :: mold

      integer                    :: v(:)
      interface 
        subroutine parts(global_indx,n,np,pv,nv)
          implicit none
          integer, intent(in)  :: global_indx, n, np
          integer, intent(out) :: nv
          integer, intent(out) :: pv(*) 
        end subroutine parts
      end interface
      optional                  :: parts, v


    end subroutine zmatdist
  end interface

end module psb_mat_dist_mod
