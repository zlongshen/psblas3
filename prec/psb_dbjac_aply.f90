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
subroutine psb_dbjac_aply(alpha,prec,x,beta,y,desc_data,trans,work,info)
  !
  !  Compute   Y <-  beta*Y + alpha*K^-1 X 
  !  where K is a a Block Jacobi  preconditioner stored in prec
  !  Note that desc_data may or may not be the same as prec%desc_data,
  !  but since both are INTENT(IN) this should be legal. 
  ! 

  use psb_base_mod
  use psb_prec_mod, psb_protect_name => psb_dbjac_aply
  implicit none 

  type(psb_desc_type), intent(in)    :: desc_data
  type(psb_dprec_type), intent(in)   :: prec
  real(psb_dpk_),intent(in)        :: x(:)
  real(psb_dpk_),intent(inout)     :: y(:)
  real(psb_dpk_),intent(in)        :: alpha,beta
  character(len=1)                   :: trans
  real(psb_dpk_),target            :: work(:)
  integer, intent(out)               :: info

  ! Local variables
  integer :: n_row,n_col
  real(psb_dpk_), pointer :: ww(:), aux(:)
  integer :: ictxt,np,me, err_act, int_err(5)
  integer            :: debug_level, debug_unit
  character          :: trans_
  character(len=20)  :: name, ch_err

  name='psb_bjac_aply'
  info = 0
  call psb_erractionsave(err_act)
  debug_unit  = psb_get_debug_unit()
  debug_level = psb_get_debug_level()
  ictxt       = psb_cd_get_context(desc_data)
  call psb_info(ictxt, me, np)

  
  trans_ = psb_toupper(trans)
  select case(trans_)
  case('N','T','C')
    ! Ok
  case default
    call psb_errpush(40,name)
    goto 9999
  end select


  n_row=desc_data%matrix_data(psb_n_row_)
  n_col=desc_data%matrix_data(psb_n_col_)

  if (n_col <= size(work)) then 
    ww => work(1:n_col)
    if ((4*n_col+n_col) <= size(work)) then 
      aux => work(n_col+1:)
    else
      allocate(aux(4*n_col),stat=info)
      if (info /= 0) then 
        call psb_errpush(4010,name,a_err='Allocate')
        goto 9999      
      end if

    endif
  else
    allocate(ww(n_col),aux(4*n_col),stat=info)
    if (info /= 0) then 
      call psb_errpush(4010,name,a_err='Allocate')
      goto 9999      
    end if
  endif


  select case(prec%iprcparm(psb_f_type_))
  case(psb_f_ilu_n_) 

    select case(trans_)
    case('N')

      call psb_spsm(done,prec%av(psb_l_pr_),x,dzero,ww,desc_data,info,&
           & trans=trans_,unit='L',diag=prec%d,choice=psb_none_,work=aux)
      if(info /=0) goto 9999
      call psb_spsm(alpha,prec%av(psb_u_pr_),ww,beta,y,desc_data,info,&
           & trans=trans_,unit='U',choice=psb_none_, work=aux)
      if(info /=0) goto 9999

    case('T','C')
      call psb_spsm(done,prec%av(psb_u_pr_),x,dzero,ww,desc_data,info,&
           & trans=trans_,unit='L',diag=prec%d,choice=psb_none_, work=aux)
      if(info /=0) goto 9999
      call psb_spsm(alpha,prec%av(psb_l_pr_),ww,beta,y,desc_data,info,&
           & trans=trans_,unit='U',choice=psb_none_,work=aux)
      if(info /=0) goto 9999

    end select
    

  case default
    info = 4001
    call psb_errpush(info,name,a_err='Invalid factorization')
    goto 9999
  end select

  call psb_halo(y,desc_data,info,data=psb_comm_mov_)

  if (n_col <= size(work)) then 
    if ((4*n_col+n_col) <= size(work)) then 
    else
      deallocate(aux)
    endif
  else
    deallocate(ww,aux)
  endif


  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_errpush(info,name,i_err=int_err,a_err=ch_err)
  call psb_erractionrestore(err_act)
  if (err_act == psb_act_abort_) then
    call psb_error()
    return
  end if
  return

end subroutine psb_dbjac_aply
