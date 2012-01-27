module psb_z_nullprec

  use psb_z_base_prec_mod
  
  type, extends(psb_z_base_prec_type) :: psb_z_null_prec_type
  contains
    procedure, pass(prec) :: c_apply_v => psb_z_null_apply_vect
    procedure, pass(prec) :: c_apply   => psb_z_null_apply
    procedure, pass(prec) :: precbld   => psb_z_null_precbld
    procedure, pass(prec) :: precinit  => psb_z_null_precinit
    procedure, pass(prec) :: precseti  => psb_z_null_precseti
    procedure, pass(prec) :: precsetr  => psb_z_null_precsetr
    procedure, pass(prec) :: precsetc  => psb_z_null_precsetc
    procedure, pass(prec) :: precfree  => psb_z_null_precfree
    procedure, pass(prec) :: precdescr => psb_z_null_precdescr
    procedure, pass(prec) :: sizeof    => psb_z_null_sizeof
  end type psb_z_null_prec_type

  private :: psb_z_null_precbld, psb_z_null_precseti,&
       & psb_z_null_precsetr, psb_z_null_precsetc, psb_z_null_sizeof,&
       & psb_z_null_precinit, psb_z_null_precfree, psb_z_null_precdescr
  

  interface
    subroutine psb_z_null_apply_vect(alpha,prec,x,beta,y,desc_data,info,trans,work)
      import :: psb_ipk_, psb_desc_type, psb_z_null_prec_type, psb_z_vect_type, psb_dpk_
      type(psb_desc_type),intent(in)       :: desc_data
      class(psb_z_null_prec_type), intent(inout)  :: prec
      type(psb_z_vect_type),intent(inout)  :: x
      complex(psb_dpk_),intent(in)         :: alpha, beta
      type(psb_z_vect_type),intent(inout)  :: y
      integer(psb_ipk_), intent(out)                 :: info
      character(len=1), optional           :: trans
      complex(psb_dpk_),intent(inout), optional, target :: work(:)
    end subroutine psb_z_null_apply_vect
  end interface
  
  interface
    subroutine psb_z_null_apply(alpha,prec,x,beta,y,desc_data,info,trans,work)
      import :: psb_ipk_, psb_desc_type, psb_z_null_prec_type, psb_dpk_
      type(psb_desc_type),intent(in)       :: desc_data
      class(psb_z_null_prec_type), intent(in)  :: prec
      complex(psb_dpk_),intent(inout)      :: x(:)
      complex(psb_dpk_),intent(in)         :: alpha, beta
      complex(psb_dpk_),intent(inout)      :: y(:)
      integer(psb_ipk_), intent(out)                 :: info
      character(len=1), optional           :: trans
      complex(psb_dpk_),intent(inout), optional, target :: work(:)
    end subroutine psb_z_null_apply
  end interface
  
  
contains
  

  subroutine psb_z_null_precinit(prec,info)
    
    Implicit None
    
    class(psb_z_null_prec_type),intent(inout) :: prec
    integer(psb_ipk_), intent(out)                     :: info
    integer(psb_ipk_) :: err_act, nrow
    character(len=20)  :: name='z_null_precinit'

    call psb_erractionsave(err_act)

    info = psb_success_

    
    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error()
      return
    end if
    return
  end subroutine psb_z_null_precinit

  subroutine psb_z_null_precbld(a,desc_a,prec,info,upd,amold,afmt,vmold)
    
    Implicit None
    
    type(psb_zspmat_type), intent(in), target :: a
    type(psb_desc_type), intent(in), target   :: desc_a
    class(psb_z_null_prec_type),intent(inout) :: prec
    integer(psb_ipk_), intent(out)                      :: info
    character, intent(in), optional           :: upd
    character(len=*), intent(in), optional    :: afmt
    class(psb_z_base_sparse_mat), intent(in), optional :: amold
    class(psb_z_base_vect_type), intent(in), optional  :: vmold
    integer(psb_ipk_) :: err_act, nrow
    character(len=20)  :: name='z_null_precbld'

    call psb_erractionsave(err_act)

    info = psb_success_

    
    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error()
      return
    end if
    return
  end subroutine psb_z_null_precbld

  subroutine psb_z_null_precseti(prec,what,val,info)
    
    Implicit None
    
    class(psb_z_null_prec_type),intent(inout) :: prec
    integer(psb_ipk_), intent(in)                      :: what 
    integer(psb_ipk_), intent(in)                      :: val 
    integer(psb_ipk_), intent(out)                     :: info
    integer(psb_ipk_) :: err_act, nrow
    character(len=20)  :: name='z_null_precset'

    call psb_erractionsave(err_act)

    info = psb_success_
    
    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error()
      return
    end if
    return
  end subroutine psb_z_null_precseti

  subroutine psb_z_null_precsetr(prec,what,val,info)
    
    Implicit None
    
    class(psb_z_null_prec_type),intent(inout) :: prec
    integer(psb_ipk_), intent(in)                      :: what 
    real(psb_dpk_), intent(in)               :: val 
    integer(psb_ipk_), intent(out)                     :: info
    integer(psb_ipk_) :: err_act, nrow
    character(len=20)  :: name='z_null_precset'

    call psb_erractionsave(err_act)

    info = psb_success_
    
    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error()
      return
    end if
    return
  end subroutine psb_z_null_precsetr

  subroutine psb_z_null_precsetc(prec,what,val,info)
    
    Implicit None
    
    class(psb_z_null_prec_type),intent(inout) :: prec
    integer(psb_ipk_), intent(in)                      :: what 
    character(len=*), intent(in)             :: val
    integer(psb_ipk_), intent(out)                     :: info
    integer(psb_ipk_) :: err_act, nrow
    character(len=20)  :: name='z_null_precset'

    call psb_erractionsave(err_act)

    info = psb_success_
    
    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error()
      return
    end if
    return
  end subroutine psb_z_null_precsetc

  subroutine psb_z_null_precfree(prec,info)
    
    Implicit None

    class(psb_z_null_prec_type), intent(inout) :: prec
    integer(psb_ipk_), intent(out)                :: info
    
    integer(psb_ipk_) :: err_act, nrow
    character(len=20)  :: name='z_null_precset'
    
    call psb_erractionsave(err_act)
    
    info = psb_success_
    
    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error()
      return
    end if
    return
    
  end subroutine psb_z_null_precfree
  

  subroutine psb_z_null_precdescr(prec,iout)
    
    Implicit None

    class(psb_z_null_prec_type), intent(in) :: prec
    integer(psb_ipk_), intent(in), optional    :: iout

    integer(psb_ipk_) :: err_act, nrow, info
    character(len=20)  :: name='z_null_precset'
    integer(psb_ipk_) :: iout_

    call psb_erractionsave(err_act)

    info = psb_success_
   
    if (present(iout)) then 
      iout_ = iout
    else
      iout_ = 6 
    end if

    write(iout_,*) 'No preconditioning'

    call psb_erractionrestore(err_act)
    return

9999 continue
    call psb_erractionrestore(err_act)
    if (err_act == psb_act_abort_) then
      call psb_error()
      return
    end if
    return
    
  end subroutine psb_z_null_precdescr

  function psb_z_null_sizeof(prec) result(val)

    class(psb_z_null_prec_type), intent(in) :: prec
    integer(psb_long_int_k_) :: val
    
    val = 0

    return
  end function psb_z_null_sizeof

end module psb_z_nullprec
