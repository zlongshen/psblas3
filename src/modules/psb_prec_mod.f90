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

module psb_prec_mod
  use psb_prec_type

  interface psb_bldaggrmat
     subroutine psb_dbldaggrmat(a,desc_a,p,info)
       use psb_prec_type
       use psb_descriptor_type
       use psb_spmat_type
       type(psb_dspmat_type), intent(in), target :: a
       type(psb_dbase_prec), intent(inout)        :: p
       type(psb_desc_type), intent(in)           :: desc_a
       integer, intent(out)                      :: info
     end subroutine psb_dbldaggrmat
  end interface
  

interface psb_genaggrmap
   subroutine psb_dgenaggrmap(aggr_type,a,desc_a,nlaggr,ilaggr,info)
     use psb_spmat_type
     use psb_descriptor_type
     implicit none
     integer, intent(in)               :: aggr_type
     type(psb_dspmat_type), intent(in) :: a
     type(psb_desc_type), intent(in)   :: desc_a
     integer, pointer                  :: ilaggr(:),nlaggr(:)
     integer, intent(out)              :: info
   end subroutine psb_dgenaggrmap
end interface

  interface psb_precbld
    subroutine psb_dprecbld(a,prec,desc_a,ierr,upd)
      use psb_descriptor_type
      use psb_prec_type
      implicit none
      integer, intent(out)                       :: ierr
      type(psb_dspmat_type), intent(in), target  :: a
      type(psb_dprec_type), intent(inout)        :: prec
      type(psb_desc_type), intent(in)            :: desc_a
      character, intent(in),optional             :: upd
    end subroutine psb_dprecbld
  end interface

  interface psb_precset
    subroutine psb_dprecset(prec,ptype,iv,rs,rv,ierr)
      use psb_serial_mod
      use psb_descriptor_type
      use psb_prec_type
      implicit none
      type(psb_dprec_type), intent(inout)    :: prec
      character(len=*), intent(in)           :: ptype
      integer, optional, intent(in)          :: iv(:)
      real(kind(1.d0)), optional, intent(in) :: rs
      real(kind(1.d0)), optional, intent(in) :: rv(:)
      integer, optional, intent(out)         :: ierr
    end subroutine psb_dprecset
  end interface
  

  interface psb_precfree
     subroutine psb_dprecfree(p,info)
       use psb_descriptor_type
       use psb_serial_mod
       use psb_const_mod
       use psb_prec_type
       type(psb_dprec_type), intent(inout) :: p
       integer, intent(out)                :: info
     end subroutine psb_dprecfree
  end interface

  interface psb_cslu
     subroutine psb_dcslu(a,desc_data,p,upd,info)
       use psb_serial_mod
       use psb_descriptor_type
       use psb_prec_type
       integer, intent(out) :: info
       type(psb_dspmat_type), intent(in), target :: a
       type(psb_desc_type),intent(in)            :: desc_data
       type(psb_dbase_prec), intent(inout)       :: p
       character, intent(in)                     :: upd
     end subroutine psb_dcslu
  end interface

  interface psb_csrsetup
    Subroutine psb_dcsrsetup(ptype,novr,a,blk,desc_data,upd,desc_p,info,outfmt)
      use psb_serial_mod
      Use psb_descriptor_type
      Use psb_prec_type
      integer, intent(in)                  :: ptype,novr
      Type(psb_dspmat_type), Intent(in)    ::  a
      Type(psb_dspmat_type), Intent(inout) ::  blk
      Type(psb_desc_type), Intent(inout)   :: desc_p
      Type(psb_desc_type), Intent(in)      :: desc_data 
      Character, Intent(in)                :: upd
      integer, intent(out)                 :: info
      character(len=5), optional           :: outfmt
    end Subroutine psb_dcsrsetup
 end interface

  interface psb_prcaply
     subroutine psb_dprecaply(prec,x,y,desc_data,info,trans,work)
       use psb_serial_mod
       use psb_descriptor_type
       use psb_prec_type
       type(psb_desc_type),intent(in)    :: desc_data
       type(psb_dprec_type), intent(in)  :: prec
       real(kind(0.d0)),intent(inout)    :: x(:), y(:)
       integer, intent(out)              :: info
       character(len=1), optional        :: trans
       real(kind(0.d0)),intent(inout), optional, target :: work(:)
     end subroutine psb_dprecaply
     subroutine psb_dprecaply1(prec,x,desc_data,info,trans)
       use psb_serial_mod
       use psb_descriptor_type
       use psb_prec_type
       type(psb_desc_type),intent(in)    :: desc_data
       type(psb_dprec_type), intent(in)  :: prec
       real(kind(0.d0)),intent(inout)    :: x(:)
       integer, intent(out)              :: info
       character(len=1), optional        :: trans
     end subroutine psb_dprecaply1
  end interface


  interface psb_splu
     subroutine psb_dsplu(a,l,u,d,info,blck)
       use psb_spmat_type
       integer, intent(out)                ::     info
       type(psb_dspmat_type),intent(in)    :: a
       type(psb_dspmat_type),intent(inout) :: l,u
       type(psb_dspmat_type),intent(in), optional, target :: blck
       real(kind(1.d0)), intent(inout)     ::  d(:)
     end subroutine psb_dsplu
  end interface
  
end module psb_prec_mod
