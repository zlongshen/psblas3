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
! package: psb_c_base_mat_mod
!
! This module contains the definition of the psb_c_base_sparse_mat
! type, derived from the psb_base_sparse_mat one to define a middle
! level definition of a complex(psb_spk_) sparse matrix
! object.This class object itself does not have any additional members
! with respect to those of the base class. No methods can be fully
! implemented at this level, but we can define the interface for the
! computational methods requiring the knowledge of the underlying
! field, such as the matrix-vector product; this interface is defined,
! but is supposed to be overridden at the leaf level.
!
! This module also contains the implementation of the
! psb_c_coo_sparse_mat type and the related methods. This is the
! reference type for all the format transitions, copies and mv unless
! methods are implemented that allow the direct transition from one
! format to another. The psb_c_coo_sparse_mat type extends 
! psb_c_base_sparse_mat. 
!
! About the method MOLD: this has been defined for those compilers
! not yet supporting ALLOCATE( ...,MOLD=...); it's otherwise silly to
! duplicate "by hand" what is specified in the language (in this case F2008)
!
module psb_c_base_mat_mod
  
  use psb_base_mat_mod
  use psb_c_base_vect_mod

  type, extends(psb_base_sparse_mat) :: psb_c_base_sparse_mat
  contains
    !
    ! Data management methods: defined here, but (mostly) not implemented.
    !    
    procedure, pass(a) :: csput         => psb_c_base_csput  
    procedure, pass(a) :: c_csgetrow  => psb_c_base_csgetrow
    procedure, pass(a) :: c_csgetblk  => psb_c_base_csgetblk
    procedure, pass(a) :: get_diag      => psb_c_base_get_diag
    generic, public    :: csget         => c_csgetrow, c_csgetblk 
    procedure, pass(a) :: csclip        => psb_c_base_csclip 
    procedure, pass(a) :: mold          => psb_c_base_mold 
    procedure, pass(a) :: cp_to_coo     => psb_c_base_cp_to_coo   
    procedure, pass(a) :: cp_from_coo   => psb_c_base_cp_from_coo 
    procedure, pass(a) :: cp_to_fmt     => psb_c_base_cp_to_fmt   
    procedure, pass(a) :: cp_from_fmt   => psb_c_base_cp_from_fmt 
    procedure, pass(a) :: mv_to_coo     => psb_c_base_mv_to_coo   
    procedure, pass(a) :: mv_from_coo   => psb_c_base_mv_from_coo 
    procedure, pass(a) :: mv_to_fmt     => psb_c_base_mv_to_fmt   
    procedure, pass(a) :: mv_from_fmt   => psb_c_base_mv_from_fmt 
    procedure, pass(a) :: c_base_cp_from
    generic, public    :: cp_from => c_base_cp_from
    procedure, pass(a) :: c_base_mv_from
    generic, public    :: mv_from => c_base_mv_from
    
    !
    ! Transpose methods: defined here but not implemented. 
    !    
    procedure, pass(a) :: transp_1mat => psb_c_base_transp_1mat
    procedure, pass(a) :: transp_2mat => psb_c_base_transp_2mat
    procedure, pass(a) :: transc_1mat => psb_c_base_transc_1mat
    procedure, pass(a) :: transc_2mat => psb_c_base_transc_2mat
    
    !
    ! Computational methods: defined here but not implemented. 
    !    
    procedure, pass(a) :: c_sp_mv      => psb_c_base_vect_mv
    procedure, pass(a) :: c_csmv       => psb_c_base_csmv
    procedure, pass(a) :: c_csmm       => psb_c_base_csmm
    generic, public    :: csmm         => c_csmm, c_csmv, c_sp_mv
    procedure, pass(a) :: c_in_sv      => psb_c_base_inner_vect_sv
    procedure, pass(a) :: c_inner_cssv => psb_c_base_inner_cssv    
    procedure, pass(a) :: c_inner_cssm => psb_c_base_inner_cssm
    generic, public    :: inner_cssm   => c_inner_cssm, c_inner_cssv, c_in_sv
    procedure, pass(a) :: c_vect_cssv  => psb_c_base_vect_cssv
    procedure, pass(a) :: c_cssv       => psb_c_base_cssv
    procedure, pass(a) :: c_cssm       => psb_c_base_cssm
    generic, public    :: cssm         => c_cssm, c_cssv, c_vect_cssv
    procedure, pass(a) :: c_scals      => psb_c_base_scals
    procedure, pass(a) :: c_scal       => psb_c_base_scal
    generic, public    :: scal         => c_scals, c_scal 
    procedure, pass(a) :: maxval       => psb_c_base_maxval
    procedure, pass(a) :: csnmi        => psb_c_base_csnmi
    procedure, pass(a) :: csnm1        => psb_c_base_csnm1
    procedure, pass(a) :: rowsum       => psb_c_base_rowsum
    procedure, pass(a) :: arwsum       => psb_c_base_arwsum
    procedure, pass(a) :: colsum       => psb_c_base_colsum
    procedure, pass(a) :: aclsum       => psb_c_base_aclsum
  end type psb_c_base_sparse_mat
  
  private :: c_base_cp_from, c_base_mv_from
  
  
  type, extends(psb_c_base_sparse_mat) :: psb_c_coo_sparse_mat
    
    integer(psb_ipk_) :: nnz
    integer(psb_ipk_), allocatable :: ia(:), ja(:)
    complex(psb_spk_), allocatable :: val(:)
    
  contains
    !
    ! Data management methods. 
    !    
    procedure, pass(a) :: get_size     => c_coo_get_size
    procedure, pass(a) :: get_nzeros   => c_coo_get_nzeros
    procedure, nopass  :: get_fmt      => c_coo_get_fmt
    procedure, pass(a) :: sizeof       => c_coo_sizeof
    procedure, pass(a) :: reallocate_nz => psb_c_coo_reallocate_nz
    procedure, pass(a) :: allocate_mnnz => psb_c_coo_allocate_mnnz
    procedure, pass(a) :: cp_to_coo    => psb_c_cp_coo_to_coo
    procedure, pass(a) :: cp_from_coo  => psb_c_cp_coo_from_coo
    procedure, pass(a) :: cp_to_fmt    => psb_c_cp_coo_to_fmt
    procedure, pass(a) :: cp_from_fmt  => psb_c_cp_coo_from_fmt
    procedure, pass(a) :: mv_to_coo    => psb_c_mv_coo_to_coo
    procedure, pass(a) :: mv_from_coo  => psb_c_mv_coo_from_coo
    procedure, pass(a) :: mv_to_fmt    => psb_c_mv_coo_to_fmt
    procedure, pass(a) :: mv_from_fmt  => psb_c_mv_coo_from_fmt
    procedure, pass(a) :: csput        => psb_c_coo_csput
    procedure, pass(a) :: get_diag     => psb_c_coo_get_diag
    procedure, pass(a) :: c_csgetrow   => psb_c_coo_csgetrow
    procedure, pass(a) :: csgetptn     => psb_c_coo_csgetptn
    procedure, pass(a) :: reinit       => psb_c_coo_reinit
    procedure, pass(a) :: get_nz_row   => psb_c_coo_get_nz_row
    procedure, pass(a) :: fix          => psb_c_fix_coo
    procedure, pass(a) :: trim         => psb_c_coo_trim
    procedure, pass(a) :: print        => psb_c_coo_print
    procedure, pass(a) :: free         => c_coo_free
    procedure, pass(a) :: mold         => psb_c_coo_mold
    procedure, pass(a) :: psb_c_coo_cp_from
    generic, public    :: cp_from => psb_c_coo_cp_from
    procedure, pass(a) :: psb_c_coo_mv_from
    generic, public    :: mv_from => psb_c_coo_mv_from
    !
    ! This is COO specific
    !
    procedure, pass(a) :: set_nzeros   => c_coo_set_nzeros
    
    !
    ! Transpose methods. These are the base of all
    ! indirection in transpose, together with conversions
    ! they are sufficient for all cases. 
    !
    procedure, pass(a) :: transp_1mat => c_coo_transp_1mat
    procedure, pass(a) :: transc_1mat => c_coo_transc_1mat

    !
    ! Computational methods. 
    !    
    procedure, pass(a) :: c_csmm       => psb_c_coo_csmm
    procedure, pass(a) :: c_csmv       => psb_c_coo_csmv
    procedure, pass(a) :: c_inner_cssm => psb_c_coo_cssm
    procedure, pass(a) :: c_inner_cssv => psb_c_coo_cssv
    procedure, pass(a) :: c_scals      => psb_c_coo_scals
    procedure, pass(a) :: c_scal       => psb_c_coo_scal
    procedure, pass(a) :: maxval       => psb_c_coo_maxval
    procedure, pass(a) :: csnmi        => psb_c_coo_csnmi
    procedure, pass(a) :: csnm1        => psb_c_coo_csnm1
    procedure, pass(a) :: rowsum       => psb_c_coo_rowsum
    procedure, pass(a) :: arwsum       => psb_c_coo_arwsum
    procedure, pass(a) :: colsum       => psb_c_coo_colsum
    procedure, pass(a) :: aclsum       => psb_c_coo_aclsum
    
  end type psb_c_coo_sparse_mat
  
  private :: c_coo_get_nzeros, c_coo_set_nzeros, &
       & c_coo_get_fmt,  c_coo_free, c_coo_sizeof, &
       & c_coo_transp_1mat, c_coo_transc_1mat
  
  
  
  ! == =================
  !
  ! BASE interfaces
  !
  ! == =================

  !
  !   CSPUT: Hand over a set of values to A. 
  !   Simple description: 
  !   A(IA(1:nz),JA(1:nz)) = VAL(1:NZ)
  !
  !   Catches:
  !     1. If A is in the BUILD state, then this method
  !        can only be called for COO matrice, in which case it
  !        is more like queueing coefficients for later processing;
  !     2. If A is in the UPDATE state, then every derived class must
  !        implement it;
  !     3. In the UPDATE state, depending on the value of DUPL flag 
  !        inside A, it will be A=VAL or A = A + VAL
  !
  !
  interface 
    subroutine psb_c_base_csput(nz,ia,ja,val,a,imin,imax,jmin,jmax,info,gtl) 
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(inout) :: a
      complex(psb_spk_), intent(in)      :: val(:)
      integer(psb_ipk_), intent(in)             :: nz, ia(:), ja(:), imin,imax,jmin,jmax
      integer(psb_ipk_), intent(out)            :: info
      integer(psb_ipk_), intent(in), optional   :: gtl(:)
    end subroutine psb_c_base_csput
  end interface
  
  !
  ! CSGET methods: getrow, getblk, clip.
  !   getrow is the basic method, the other two are
  !   basically convenient wrappers/shorthand. 
  ! 
  !    out(:) = A(imin:imax,:)
  ! 
  !  The two methods differ on the output format
  !  
  ! GETROW returns as the set
  !      NZ, IA(1:nz), JA(1:nz), VAL(1:NZ)
  !
  ! Optional arguments:
  !    JMIN,JMAX: get A(IMIN:IMAX,JMIN:JMAX),
  !       default 1:ncols
  !    APPEND: append at the end of data, in which case
  !            # used entries must be in NZ
  !    RSCALE, CSCALE: scale output indices at base 1. 
  !
  ! GETROW must be overridden by all data formats.
  !
  
  interface 
    subroutine psb_c_base_csgetrow(imin,imax,a,nz,ia,ja,val,info,&
         & jmin,jmax,iren,append,nzin,rscale,cscale)
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(in) :: a
      integer(psb_ipk_), intent(in)                  :: imin,imax
      integer(psb_ipk_), intent(out)                 :: nz
      integer(psb_ipk_), allocatable, intent(inout)  :: ia(:), ja(:)
      complex(psb_spk_), allocatable,  intent(inout)    :: val(:)
      integer(psb_ipk_),intent(out)                  :: info
      logical, intent(in), optional        :: append
      integer(psb_ipk_), intent(in), optional        :: iren(:)
      integer(psb_ipk_), intent(in), optional        :: jmin,jmax, nzin
      logical, intent(in), optional        :: rscale,cscale
    end subroutine psb_c_base_csgetrow
  end interface
  
  !
  ! CSGET methods: getrow, getblk.
  !    out(:) = A(imin:imax,:)
  ! 
  ! GETBLK returns a pbs_c_coo_sparse_mat with
  !      the same contents.
  !      Default implementation at base level
  !      in terms of (derived) GETROW
  !
  interface 
    subroutine psb_c_base_csgetblk(imin,imax,a,b,info,&
         & jmin,jmax,iren,append,rscale,cscale)
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(in) :: a
      class(psb_c_coo_sparse_mat), intent(inout) :: b
      integer(psb_ipk_), intent(in)                  :: imin,imax
      integer(psb_ipk_),intent(out)                  :: info
      logical, intent(in), optional        :: append
      integer(psb_ipk_), intent(in), optional        :: iren(:)
      integer(psb_ipk_), intent(in), optional        :: jmin,jmax
      logical, intent(in), optional        :: rscale,cscale
    end subroutine psb_c_base_csgetblk
  end interface
  
  !
  ! CLIP: extract a subset
  !  B(:,:) = A(imin:imax,jmin:jmax)
  !  control: rscale,cscale as in getblk above.
  !  
  !  Default implementation at base level in terms of
  !  GETBLK. 
  !
  interface 
    subroutine psb_c_base_csclip(a,b,info,&
         & imin,imax,jmin,jmax,rscale,cscale)
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(in) :: a
      class(psb_c_coo_sparse_mat), intent(out) :: b
      integer(psb_ipk_),intent(out)                  :: info
      integer(psb_ipk_), intent(in), optional        :: imin,imax,jmin,jmax
      logical, intent(in), optional        :: rscale,cscale
    end subroutine psb_c_base_csclip
  end interface
  
  !
  ! GET_DIAG method
  ! 
  !   D(i) = A(i:i), i=1:min(nrows,ncols)
  ! 
  interface 
    subroutine psb_c_base_get_diag(a,d,info) 
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(in) :: a
      complex(psb_spk_), intent(out)     :: d(:)
      integer(psb_ipk_), intent(out)            :: info
    end subroutine psb_c_base_get_diag
  end interface
  
  !
  ! MOLD: make B have the same dinamyc type
  !       as A.
  !       For compilers not supporting
  !          allocate(  mold=  )
  ! 
  interface 
    subroutine psb_c_base_mold(a,b,info) 
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_long_int_k_
      class(psb_c_base_sparse_mat), intent(in)               :: a
      class(psb_c_base_sparse_mat), intent(out), allocatable :: b
      integer(psb_ipk_), intent(out)                                 :: info
    end subroutine psb_c_base_mold
  end interface
  
  
  !
  ! These are the methods implementing the MEDIATOR pattern
  ! to allow switch between arbitrary.
  ! Indeed, the TO/FROM FMT can be implemented at the base level
  ! in terms of the TO/FROM COO per the MEDIATOR design pattern.
  ! This does not prevent most of the derived classes to
  ! provide their own versions with shortcuts.
  !  A%{MV|CP}_{TO|FROM}_{FMT|COO}
  !  MV|CP: copy versus move, i.e. deallocate
  !  TO|FROM: invoked from source or target object
  !
  !
  interface 
    subroutine psb_c_base_cp_to_coo(a,b,info) 
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(in) :: a
      class(psb_c_coo_sparse_mat), intent(inout) :: b
      integer(psb_ipk_), intent(out)            :: info
    end subroutine psb_c_base_cp_to_coo
  end interface
  
  interface 
    subroutine psb_c_base_cp_from_coo(a,b,info) 
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(inout) :: a
      class(psb_c_coo_sparse_mat), intent(in) :: b
      integer(psb_ipk_), intent(out)            :: info
    end subroutine psb_c_base_cp_from_coo
  end interface
  
  interface 
    subroutine psb_c_base_cp_to_fmt(a,b,info) 
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(in) :: a
      class(psb_c_base_sparse_mat), intent(inout) :: b
      integer(psb_ipk_), intent(out)            :: info
    end subroutine psb_c_base_cp_to_fmt
  end interface
  
  interface 
    subroutine psb_c_base_cp_from_fmt(a,b,info) 
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(inout) :: a
      class(psb_c_base_sparse_mat), intent(in) :: b
      integer(psb_ipk_), intent(out)            :: info
    end subroutine psb_c_base_cp_from_fmt
  end interface
  
  interface 
    subroutine psb_c_base_mv_to_coo(a,b,info) 
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(inout) :: a
      class(psb_c_coo_sparse_mat), intent(inout) :: b
      integer(psb_ipk_), intent(out)            :: info
    end subroutine psb_c_base_mv_to_coo
  end interface
  
  interface 
    subroutine psb_c_base_mv_from_coo(a,b,info) 
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(inout) :: a
      class(psb_c_coo_sparse_mat), intent(inout) :: b
      integer(psb_ipk_), intent(out)            :: info
    end subroutine psb_c_base_mv_from_coo
  end interface
  
  interface 
    subroutine psb_c_base_mv_to_fmt(a,b,info) 
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(inout) :: a
      class(psb_c_base_sparse_mat), intent(inout) :: b
      integer(psb_ipk_), intent(out)            :: info
    end subroutine psb_c_base_mv_to_fmt
  end interface
  
  interface 
    subroutine psb_c_base_mv_from_fmt(a,b,info) 
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(inout) :: a
      class(psb_c_base_sparse_mat), intent(inout) :: b
      integer(psb_ipk_), intent(out)            :: info
    end subroutine psb_c_base_mv_from_fmt
  end interface
  
  !
  ! Transpose methods.
  ! You can always default to COO to do the actual
  ! transpose work. 
  !
  interface 
    subroutine psb_c_base_transp_2mat(a,b)
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(in) :: a
      class(psb_base_sparse_mat), intent(out)    :: b
    end subroutine psb_c_base_transp_2mat
  end interface
  
  interface  
    subroutine psb_c_base_transc_2mat(a,b)
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(in) :: a
      class(psb_base_sparse_mat), intent(out)    :: b
    end subroutine psb_c_base_transc_2mat
  end interface
  
  interface 
    subroutine psb_c_base_transp_1mat(a)
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(inout) :: a
    end subroutine psb_c_base_transp_1mat
  end interface
  
  interface 
    subroutine psb_c_base_transc_1mat(a)
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(inout) :: a
    end subroutine psb_c_base_transc_1mat
  end interface
  
  !
  ! Matrix-vector products. 
  !  Y = alpha*A*X + beta*Y
  !  
  !  vect_mv relies on csmv for those data types
  !  not specifically using the encapsulation to handle
  !  foreign data. 
  !
  !
  interface 
    subroutine psb_c_base_csmm(alpha,a,x,beta,y,info,trans)
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(in) :: a
      complex(psb_spk_), intent(in)    :: alpha, beta, x(:,:)
      complex(psb_spk_), intent(inout) :: y(:,:)
      integer(psb_ipk_), intent(out)            :: info
      character, optional, intent(in) :: trans
    end subroutine psb_c_base_csmm
  end interface
  
  interface 
    subroutine psb_c_base_csmv(alpha,a,x,beta,y,info,trans) 
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(in) :: a
      complex(psb_spk_), intent(in)    :: alpha, beta, x(:)
      complex(psb_spk_), intent(inout) :: y(:)
      integer(psb_ipk_), intent(out)            :: info
      character, optional, intent(in) :: trans
    end subroutine psb_c_base_csmv
  end interface
  
  interface 
    subroutine psb_c_base_vect_mv(alpha,a,x,beta,y,info,trans) 
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_, psb_c_base_vect_type
      class(psb_c_base_sparse_mat), intent(in) :: a
      complex(psb_spk_), intent(in)       :: alpha, beta
      class(psb_c_base_vect_type), intent(inout) :: x
      class(psb_c_base_vect_type), intent(inout) :: y
      integer(psb_ipk_), intent(out)             :: info
      character, optional, intent(in)  :: trans
    end subroutine psb_c_base_vect_mv
  end interface
  
  !
  ! Triangular system solve.
  ! The CSSM/CSSV/VECT_SV outer methods are implemented at the base
  ! level, and they take care of the SCALE and D control arguments.
  ! So the derived classes need to override only the INNER_ methods.
  !
  interface 
    subroutine psb_c_base_inner_cssm(alpha,a,x,beta,y,info,trans) 
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(in) :: a
      complex(psb_spk_), intent(in)    :: alpha, beta, x(:,:)
      complex(psb_spk_), intent(inout) :: y(:,:)
      integer(psb_ipk_), intent(out)            :: info
      character, optional, intent(in) :: trans
    end subroutine psb_c_base_inner_cssm
  end interface
  
  interface 
    subroutine psb_c_base_inner_cssv(alpha,a,x,beta,y,info,trans) 
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(in) :: a
      complex(psb_spk_), intent(in)    :: alpha, beta, x(:)
      complex(psb_spk_), intent(inout) :: y(:)
      integer(psb_ipk_), intent(out)            :: info
      character, optional, intent(in) :: trans
    end subroutine psb_c_base_inner_cssv
  end interface
  
  interface 
    subroutine psb_c_base_inner_vect_sv(alpha,a,x,beta,y,info,trans) 
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_,  psb_c_base_vect_type
      class(psb_c_base_sparse_mat), intent(in) :: a
      complex(psb_spk_), intent(in)       :: alpha, beta
      class(psb_c_base_vect_type), intent(inout) :: x, y
      integer(psb_ipk_), intent(out)             :: info
      character, optional, intent(in)  :: trans
    end subroutine psb_c_base_inner_vect_sv
  end interface
  
  interface 
    subroutine psb_c_base_cssm(alpha,a,x,beta,y,info,trans,scale,d)
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(in) :: a
      complex(psb_spk_), intent(in)    :: alpha, beta, x(:,:)
      complex(psb_spk_), intent(inout) :: y(:,:)
      integer(psb_ipk_), intent(out)            :: info
      character, optional, intent(in) :: trans, scale
      complex(psb_spk_), intent(in), optional :: d(:)
    end subroutine psb_c_base_cssm
  end interface
  
  interface 
    subroutine psb_c_base_cssv(alpha,a,x,beta,y,info,trans,scale,d)
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(in) :: a
      complex(psb_spk_), intent(in)    :: alpha, beta, x(:)
      complex(psb_spk_), intent(inout) :: y(:)
      integer(psb_ipk_), intent(out)            :: info
      character, optional, intent(in) :: trans, scale
      complex(psb_spk_), intent(in), optional :: d(:)
    end subroutine psb_c_base_cssv
  end interface
  
  interface 
    subroutine psb_c_base_vect_cssv(alpha,a,x,beta,y,info,trans,scale,d)
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_,psb_c_base_vect_type
      class(psb_c_base_sparse_mat), intent(in) :: a
      complex(psb_spk_), intent(in)       :: alpha, beta
      class(psb_c_base_vect_type), intent(inout) :: x,y
      integer(psb_ipk_), intent(out)             :: info
      character, optional, intent(in)  :: trans, scale
      class(psb_c_base_vect_type), optional, intent(inout)   :: d
    end subroutine psb_c_base_vect_cssv
  end interface
  
  !
  ! Scale a matrix by a scalar or by a vector.
  ! Should we handle scale on the columns?? 
  !
  interface 
    subroutine psb_c_base_scals(d,a,info) 
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(inout) :: a
      complex(psb_spk_), intent(in)      :: d
      integer(psb_ipk_), intent(out)            :: info
    end subroutine psb_c_base_scals
  end interface
  
  interface 
    subroutine psb_c_base_scal(d,a,info) 
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(inout) :: a
      complex(psb_spk_), intent(in)      :: d(:)
      integer(psb_ipk_), intent(out)            :: info
    end subroutine psb_c_base_scal
  end interface
  
  !
  ! Maximum coefficient absolute value norm
  !
  interface 
    function psb_c_base_maxval(a) result(res)
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(in) :: a
      real(psb_spk_)         :: res
    end function psb_c_base_maxval
  end interface
  
  !
  ! Operator infinity norm
  !
  interface 
    function psb_c_base_csnmi(a) result(res)
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(in) :: a
      real(psb_spk_)         :: res
    end function psb_c_base_csnmi
  end interface

  !
  ! Operator 1-norm
  !
  interface 
    function psb_c_base_csnm1(a) result(res)
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(in) :: a
      real(psb_spk_)         :: res
    end function psb_c_base_csnm1
  end interface

  !
  ! Compute sums along the rows, either
  ! natural or absolute value
  !
  interface 
    subroutine psb_c_base_rowsum(d,a) 
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(in) :: a
      complex(psb_spk_), intent(out)              :: d(:)
    end subroutine psb_c_base_rowsum
  end interface

  interface 
    subroutine psb_c_base_arwsum(d,a) 
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(in) :: a
      real(psb_spk_), intent(out)              :: d(:)
    end subroutine psb_c_base_arwsum
  end interface
  
  !
  ! Compute sums along the columns, either
  ! natural or absolute value
  !
  interface 
    subroutine psb_c_base_colsum(d,a) 
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(in) :: a
      complex(psb_spk_), intent(out)              :: d(:)
    end subroutine psb_c_base_colsum
  end interface

  interface 
    subroutine psb_c_base_aclsum(d,a) 
      import :: psb_ipk_, psb_c_base_sparse_mat, psb_spk_
      class(psb_c_base_sparse_mat), intent(in) :: a
      real(psb_spk_), intent(out)              :: d(:)
    end subroutine psb_c_base_aclsum
  end interface

  
  ! == ===============
  !
  ! COO interfaces
  !
  ! == ===============
  
  interface
    subroutine  psb_c_coo_reallocate_nz(nz,a) 
      import :: psb_ipk_, psb_c_coo_sparse_mat
      integer(psb_ipk_), intent(in) :: nz
      class(psb_c_coo_sparse_mat), intent(inout) :: a
    end subroutine psb_c_coo_reallocate_nz
  end interface
  
  interface 
    subroutine psb_c_coo_reinit(a,clear)
      import :: psb_ipk_, psb_c_coo_sparse_mat
      class(psb_c_coo_sparse_mat), intent(inout) :: a   
      logical, intent(in), optional :: clear
    end subroutine psb_c_coo_reinit
  end interface
  
  interface
    subroutine  psb_c_coo_trim(a)
      import :: psb_ipk_, psb_c_coo_sparse_mat
      class(psb_c_coo_sparse_mat), intent(inout) :: a
    end subroutine psb_c_coo_trim
  end interface
  
  interface
    subroutine  psb_c_coo_allocate_mnnz(m,n,a,nz) 
      import :: psb_ipk_, psb_c_coo_sparse_mat
      integer(psb_ipk_), intent(in) :: m,n
      class(psb_c_coo_sparse_mat), intent(inout) :: a
      integer(psb_ipk_), intent(in), optional :: nz
    end subroutine psb_c_coo_allocate_mnnz
  end interface

  interface 
    subroutine psb_c_coo_mold(a,b,info) 
      import :: psb_ipk_, psb_c_coo_sparse_mat, psb_c_base_sparse_mat, psb_long_int_k_
      class(psb_c_coo_sparse_mat), intent(in)               :: a
      class(psb_c_base_sparse_mat), intent(out), allocatable :: b
      integer(psb_ipk_), intent(out)                                 :: info
    end subroutine psb_c_coo_mold
  end interface

  
  interface
    subroutine psb_c_coo_print(iout,a,iv,head,ivr,ivc)
      import :: psb_ipk_, psb_c_coo_sparse_mat
      integer(psb_ipk_), intent(in)               :: iout
      class(psb_c_coo_sparse_mat), intent(in) :: a   
      integer(psb_ipk_), intent(in), optional     :: iv(:)
      character(len=*), optional        :: head
      integer(psb_ipk_), intent(in), optional     :: ivr(:), ivc(:)
    end subroutine psb_c_coo_print
  end interface
  
  
  interface 
    function  psb_c_coo_get_nz_row(idx,a) result(res)
      import :: psb_ipk_, psb_c_coo_sparse_mat
      class(psb_c_coo_sparse_mat), intent(in) :: a
      integer(psb_ipk_), intent(in)                  :: idx
      integer(psb_ipk_) :: res
    end function psb_c_coo_get_nz_row
  end interface
  
  
  !
  ! Fix: make sure that
  !   1. The coefficients are sorted
  !   2. Handle duplicates if necessary.
  !   Optional: IDIR: sort by rows or columns.
  !
  interface 
    subroutine psb_c_fix_coo_inner(nzin,dupl,ia,ja,val,nzout,info,idir) 
      import :: psb_ipk_, psb_spk_
      integer(psb_ipk_), intent(in)           :: nzin,dupl
      integer(psb_ipk_), intent(inout)        :: ia(:), ja(:)
      complex(psb_spk_), intent(inout) :: val(:)
      integer(psb_ipk_), intent(out)          :: nzout, info
      integer(psb_ipk_), intent(in), optional :: idir
    end subroutine psb_c_fix_coo_inner
  end interface
  
  interface 
    subroutine psb_c_fix_coo(a,info,idir) 
      import :: psb_ipk_, psb_c_coo_sparse_mat
      class(psb_c_coo_sparse_mat), intent(inout) :: a
      integer(psb_ipk_), intent(out)                :: info
      integer(psb_ipk_), intent(in), optional :: idir
    end subroutine psb_c_fix_coo
  end interface
  
  interface 
    subroutine psb_c_cp_coo_to_coo(a,b,info) 
      import :: psb_ipk_, psb_c_coo_sparse_mat
      class(psb_c_coo_sparse_mat), intent(in) :: a
      class(psb_c_coo_sparse_mat), intent(inout) :: b
      integer(psb_ipk_), intent(out)            :: info
    end subroutine psb_c_cp_coo_to_coo
  end interface
  
  interface 
    subroutine psb_c_cp_coo_from_coo(a,b,info) 
      import :: psb_ipk_, psb_c_coo_sparse_mat
      class(psb_c_coo_sparse_mat), intent(inout) :: a
      class(psb_c_coo_sparse_mat), intent(in)    :: b
      integer(psb_ipk_), intent(out)                        :: info
    end subroutine psb_c_cp_coo_from_coo
  end interface
  
  interface 
    subroutine psb_c_cp_coo_to_fmt(a,b,info) 
      import :: psb_ipk_, psb_c_coo_sparse_mat, psb_c_base_sparse_mat
      class(psb_c_coo_sparse_mat), intent(in)   :: a
      class(psb_c_base_sparse_mat), intent(inout) :: b
      integer(psb_ipk_), intent(out)                       :: info
    end subroutine psb_c_cp_coo_to_fmt
  end interface
  
  interface 
    subroutine psb_c_cp_coo_from_fmt(a,b,info) 
      import :: psb_ipk_, psb_c_coo_sparse_mat, psb_c_base_sparse_mat
      class(psb_c_coo_sparse_mat), intent(inout) :: a
      class(psb_c_base_sparse_mat), intent(in)   :: b
      integer(psb_ipk_), intent(out)                        :: info
    end subroutine psb_c_cp_coo_from_fmt
  end interface
  
  interface 
    subroutine psb_c_mv_coo_to_coo(a,b,info) 
      import :: psb_ipk_, psb_c_coo_sparse_mat
      class(psb_c_coo_sparse_mat), intent(inout) :: a
      class(psb_c_coo_sparse_mat), intent(inout)   :: b
      integer(psb_ipk_), intent(out)            :: info
    end subroutine psb_c_mv_coo_to_coo
  end interface
  
  interface 
    subroutine psb_c_mv_coo_from_coo(a,b,info) 
      import :: psb_ipk_, psb_c_coo_sparse_mat
      class(psb_c_coo_sparse_mat), intent(inout) :: a
      class(psb_c_coo_sparse_mat), intent(inout) :: b
      integer(psb_ipk_), intent(out)                        :: info
    end subroutine psb_c_mv_coo_from_coo
  end interface
  
  interface 
    subroutine psb_c_mv_coo_to_fmt(a,b,info) 
      import :: psb_ipk_, psb_c_coo_sparse_mat, psb_c_base_sparse_mat
      class(psb_c_coo_sparse_mat), intent(inout) :: a
      class(psb_c_base_sparse_mat), intent(inout)  :: b
      integer(psb_ipk_), intent(out)                        :: info
    end subroutine psb_c_mv_coo_to_fmt
  end interface
  
  interface 
    subroutine psb_c_mv_coo_from_fmt(a,b,info) 
      import :: psb_ipk_, psb_c_coo_sparse_mat, psb_c_base_sparse_mat
      class(psb_c_coo_sparse_mat), intent(inout)  :: a
      class(psb_c_base_sparse_mat), intent(inout) :: b
      integer(psb_ipk_), intent(out)                         :: info
    end subroutine psb_c_mv_coo_from_fmt
  end interface
  
  interface 
    subroutine psb_c_coo_cp_from(a,b)
      import :: psb_ipk_, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_coo_sparse_mat), intent(inout) :: a
      type(psb_c_coo_sparse_mat), intent(in)   :: b
    end subroutine psb_c_coo_cp_from
  end interface
  
  interface 
    subroutine psb_c_coo_mv_from(a,b)
      import :: psb_ipk_, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_coo_sparse_mat), intent(inout)  :: a
      type(psb_c_coo_sparse_mat), intent(inout) :: b
    end subroutine psb_c_coo_mv_from
  end interface
  
  
  interface 
    subroutine psb_c_coo_csput(nz,ia,ja,val,a,imin,imax,jmin,jmax,info,gtl) 
      import :: psb_ipk_, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_coo_sparse_mat), intent(inout) :: a
      complex(psb_spk_), intent(in)      :: val(:)
      integer(psb_ipk_), intent(in)             :: nz,ia(:), ja(:),&
           &  imin,imax,jmin,jmax
      integer(psb_ipk_), intent(out)            :: info
      integer(psb_ipk_), intent(in), optional   :: gtl(:)
    end subroutine psb_c_coo_csput
  end interface
  
  interface 
    subroutine psb_c_coo_csgetptn(imin,imax,a,nz,ia,ja,info,&
         & jmin,jmax,iren,append,nzin,rscale,cscale)
      import :: psb_ipk_, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_coo_sparse_mat), intent(in) :: a
      integer(psb_ipk_), intent(in)                  :: imin,imax
      integer(psb_ipk_), intent(out)                 :: nz
      integer(psb_ipk_), allocatable, intent(inout)  :: ia(:), ja(:)
      integer(psb_ipk_),intent(out)                  :: info
      logical, intent(in), optional        :: append
      integer(psb_ipk_), intent(in), optional        :: iren(:)
      integer(psb_ipk_), intent(in), optional        :: jmin,jmax, nzin
      logical, intent(in), optional        :: rscale,cscale
    end subroutine psb_c_coo_csgetptn
  end interface
  
  interface 
    subroutine psb_c_coo_csgetrow(imin,imax,a,nz,ia,ja,val,info,&
         & jmin,jmax,iren,append,nzin,rscale,cscale)
      import :: psb_ipk_, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_coo_sparse_mat), intent(in) :: a
      integer(psb_ipk_), intent(in)                  :: imin,imax
      integer(psb_ipk_), intent(out)                 :: nz
      integer(psb_ipk_), allocatable, intent(inout)  :: ia(:), ja(:)
      complex(psb_spk_), allocatable,  intent(inout)    :: val(:)
      integer(psb_ipk_),intent(out)                  :: info
      logical, intent(in), optional        :: append
      integer(psb_ipk_), intent(in), optional        :: iren(:)
      integer(psb_ipk_), intent(in), optional        :: jmin,jmax, nzin
      logical, intent(in), optional        :: rscale,cscale
    end subroutine psb_c_coo_csgetrow
  end interface
  
  interface 
    subroutine psb_c_coo_cssv(alpha,a,x,beta,y,info,trans) 
      import :: psb_ipk_, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_coo_sparse_mat), intent(in) :: a
      complex(psb_spk_), intent(in)          :: alpha, beta, x(:)
      complex(psb_spk_), intent(inout)       :: y(:)
      integer(psb_ipk_), intent(out)                :: info
      character, optional, intent(in)     :: trans
    end subroutine psb_c_coo_cssv
    subroutine psb_c_coo_cssm(alpha,a,x,beta,y,info,trans) 
      import :: psb_ipk_, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_coo_sparse_mat), intent(in) :: a
      complex(psb_spk_), intent(in)          :: alpha, beta, x(:,:)
      complex(psb_spk_), intent(inout)       :: y(:,:)
      integer(psb_ipk_), intent(out)                :: info
      character, optional, intent(in)     :: trans
    end subroutine psb_c_coo_cssm
  end interface
  
  interface 
    subroutine psb_c_coo_csmv(alpha,a,x,beta,y,info,trans) 
      import :: psb_ipk_, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_coo_sparse_mat), intent(in) :: a
      complex(psb_spk_), intent(in)          :: alpha, beta, x(:)
      complex(psb_spk_), intent(inout)       :: y(:)
      integer(psb_ipk_), intent(out)                :: info
      character, optional, intent(in)     :: trans
    end subroutine psb_c_coo_csmv
    subroutine psb_c_coo_csmm(alpha,a,x,beta,y,info,trans) 
      import :: psb_ipk_, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_coo_sparse_mat), intent(in) :: a
      complex(psb_spk_), intent(in)          :: alpha, beta, x(:,:)
      complex(psb_spk_), intent(inout)       :: y(:,:)
      integer(psb_ipk_), intent(out)                :: info
      character, optional, intent(in)     :: trans
    end subroutine psb_c_coo_csmm
  end interface
  
    
  interface 
    function psb_c_coo_maxval(a) result(res)
      import :: psb_ipk_, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_coo_sparse_mat), intent(in) :: a
      real(psb_spk_)         :: res
    end function psb_c_coo_maxval
  end interface

  interface 
    function psb_c_coo_csnmi(a) result(res)
      import :: psb_ipk_, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_coo_sparse_mat), intent(in) :: a
      real(psb_spk_)         :: res
    end function psb_c_coo_csnmi
  end interface
  
  interface 
    function psb_c_coo_csnm1(a) result(res)
      import :: psb_ipk_, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_coo_sparse_mat), intent(in) :: a
      real(psb_spk_)         :: res
    end function psb_c_coo_csnm1
  end interface

  interface 
    subroutine psb_c_coo_rowsum(d,a) 
      import :: psb_ipk_, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_coo_sparse_mat), intent(in) :: a
      complex(psb_spk_), intent(out)              :: d(:)
    end subroutine psb_c_coo_rowsum
  end interface

  interface 
    subroutine psb_c_coo_arwsum(d,a) 
      import :: psb_ipk_, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_coo_sparse_mat), intent(in) :: a
      real(psb_spk_), intent(out)              :: d(:)
    end subroutine psb_c_coo_arwsum
  end interface
  
  interface 
    subroutine psb_c_coo_colsum(d,a) 
      import :: psb_ipk_, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_coo_sparse_mat), intent(in) :: a
      complex(psb_spk_), intent(out)              :: d(:)
    end subroutine psb_c_coo_colsum
  end interface

  interface 
    subroutine psb_c_coo_aclsum(d,a) 
      import :: psb_ipk_, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_coo_sparse_mat), intent(in) :: a
      real(psb_spk_), intent(out)              :: d(:)
    end subroutine psb_c_coo_aclsum
  end interface
  
  interface 
    subroutine psb_c_coo_get_diag(a,d,info) 
      import :: psb_ipk_, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_coo_sparse_mat), intent(in) :: a
      complex(psb_spk_), intent(out)     :: d(:)
      integer(psb_ipk_), intent(out)            :: info
    end subroutine psb_c_coo_get_diag
  end interface
  
  interface 
    subroutine psb_c_coo_scal(d,a,info) 
      import :: psb_ipk_, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_coo_sparse_mat), intent(inout) :: a
      complex(psb_spk_), intent(in)      :: d(:)
      integer(psb_ipk_), intent(out)            :: info
    end subroutine psb_c_coo_scal
  end interface
  
  interface
    subroutine psb_c_coo_scals(d,a,info) 
      import :: psb_ipk_, psb_c_coo_sparse_mat, psb_spk_
      class(psb_c_coo_sparse_mat), intent(inout) :: a
      complex(psb_spk_), intent(in)      :: d
      integer(psb_ipk_), intent(out)            :: info
    end subroutine psb_c_coo_scals
  end interface
  
  
contains 
  
  
  subroutine c_base_mv_from(a,b)
    
    implicit none 
    
    class(psb_c_base_sparse_mat), intent(out)   :: a
    type(psb_c_base_sparse_mat), intent(inout) :: b
    
    
    ! No new things here, very easy
    call a%psb_base_sparse_mat%mv_from(b%psb_base_sparse_mat)
    
    return
    
  end subroutine c_base_mv_from
  
  subroutine c_base_cp_from(a,b)
    implicit none 
    
    class(psb_c_base_sparse_mat), intent(out) :: a
    type(psb_c_base_sparse_mat), intent(in)  :: b
    
    ! No new things here, very easy
    call a%psb_base_sparse_mat%cp_from(b%psb_base_sparse_mat)
    
    return
    
  end subroutine c_base_cp_from
  
 
  
  ! == ==================================
  !
  !
  !
  ! Getters 
  !
  !
  !
  !
  !
  ! == ==================================
  
  
  
  function c_coo_sizeof(a) result(res)
    implicit none 
    class(psb_c_coo_sparse_mat), intent(in) :: a
    integer(psb_long_int_k_) :: res
    res = 8 + 1
    res = res + (2*psb_sizeof_sp)  * size(a%val)
    res = res + psb_sizeof_int * size(a%ia)
    res = res + psb_sizeof_int * size(a%ja)
    
  end function c_coo_sizeof
  
  
  function c_coo_get_fmt() result(res)
    implicit none 
    character(len=5) :: res
    res = 'COO'
  end function c_coo_get_fmt
  
  
  function c_coo_get_size(a) result(res)
    implicit none 
    class(psb_c_coo_sparse_mat), intent(in) :: a
    integer(psb_ipk_) :: res
    res = -1
    
    if (allocated(a%ia)) res = size(a%ia)
    if (allocated(a%ja)) then 
      if (res >= 0) then 
        res = min(res,size(a%ja))
      else 
        res = size(a%ja)
      end if
    end if
    if (allocated(a%val)) then 
      if (res >= 0) then 
        res = min(res,size(a%val))
      else 
        res = size(a%val)
      end if
    end if
  end function c_coo_get_size
  
  
  function c_coo_get_nzeros(a) result(res)
    implicit none 
    class(psb_c_coo_sparse_mat), intent(in) :: a
    integer(psb_ipk_) :: res
    res  = a%nnz
  end function c_coo_get_nzeros
  
  
  ! == ==================================
  !
  !
  !
  ! Setters 
  !
  !
  !
  !
  !
  !
  ! == ==================================
  
  subroutine  c_coo_set_nzeros(nz,a)
    implicit none 
    integer(psb_ipk_), intent(in) :: nz
    class(psb_c_coo_sparse_mat), intent(inout) :: a
    
    a%nnz = nz
    
  end subroutine c_coo_set_nzeros
  
  ! == ==================================
  !
  !
  !
  ! Data management
  !
  !
  !
  !
  !
  ! == ==================================
  
  subroutine  c_coo_free(a) 
    implicit none 
    
    class(psb_c_coo_sparse_mat), intent(inout) :: a
    
    if (allocated(a%ia)) deallocate(a%ia)
    if (allocated(a%ja)) deallocate(a%ja)
    if (allocated(a%val)) deallocate(a%val)
    call a%set_null()
    call a%set_nrows(0)
    call a%set_ncols(0)
    call a%set_nzeros(0)
    
    return
    
  end subroutine c_coo_free
  
  
  
  ! == ==================================
  !
  !
  !
  ! Computational routines
  !
  !
  !
  !
  !
  !
  ! == ==================================
  subroutine c_coo_transp_1mat(a)
    implicit none 
    
    class(psb_c_coo_sparse_mat), intent(inout) :: a
    
    integer(psb_ipk_), allocatable :: itemp(:) 
    integer(psb_ipk_) :: info
    
    call a%psb_c_base_sparse_mat%psb_base_sparse_mat%transp()
    call move_alloc(a%ia,itemp)
    call move_alloc(a%ja,a%ia)
    call move_alloc(itemp,a%ja)
    
    call a%fix(info)
    
    return
    
  end subroutine c_coo_transp_1mat
  
  subroutine c_coo_transc_1mat(a)
    implicit none 
    
    class(psb_c_coo_sparse_mat), intent(inout) :: a
    
    call a%transp() 
    ! This will morph into conjg() for C and Z
    ! and into a no-op for S and D, so a conditional
    ! on a constant ought to take it out completely. 
    if (psb_c_is_complex_) a%val(:) = conjg(a%val(:))

  end subroutine c_coo_transc_1mat



end module psb_c_base_mat_mod



