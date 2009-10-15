
subroutine c_coo_cssm_impl(alpha,a,x,beta,y,info,trans) 
  use psb_const_mod
  use psb_error_mod
  use psb_string_mod
  use psb_c_base_mat_mod, psb_protect_name => c_coo_cssm_impl
  implicit none 
  class(psb_c_coo_sparse_mat), intent(in) :: a
  complex(psb_spk_), intent(in)          :: alpha, beta, x(:,:)
  complex(psb_spk_), intent(inout)       :: y(:,:)
  integer, intent(out)                :: info
  character, optional, intent(in)     :: trans

  character :: trans_
  integer   :: i,j,k,m,n, nnz, ir, jc, nc
  complex(psb_spk_) :: acc
  complex(psb_spk_), allocatable :: tmp(:,:)
  logical   :: tra, ctra
  Integer :: err_act
  character(len=20)  :: name='c_base_cssm'
  logical, parameter :: debug=.false.

  info = 0
  call psb_erractionsave(err_act)

  if (.not.a%is_asb()) then 
    info = 1121
    call psb_errpush(info,name)
    goto 9999
  endif


  if (.not. (a%is_triangle())) then 
    info = 1121
    call psb_errpush(info,name)
    goto 9999
  end if

  if (present(trans)) then
    trans_ = trans
  else
    trans_ = 'N'
  end if
  tra  = (psb_toupper(trans_)=='T')
  ctra = (psb_toupper(trans_)=='C')
  m   = a%get_nrows()
  nc  = min(size(x,2) , size(y,2)) 
  nnz = a%get_nzeros()

  if (alpha == zzero) then
    if (beta == zzero) then
      do i = 1, m
        y(i,1:nc) = zzero
      enddo
    else
      do  i = 1, m
        y(i,1:nc) = beta*y(i,1:nc)
      end do
    endif
    return
  end if

  if (beta == zzero) then 
    call inner_coosm(tra,ctra,a%is_lower(),a%is_unit(),a%is_sorted(),&
         & m,nc,nnz,a%ia,a%ja,a%val,&
         & x,size(x,1),y,size(y,1),info)
    do  i = 1, m
      y(i,1:nc) = alpha*y(i,1:nc)
    end do
  else 
    allocate(tmp(m,nc), stat=info) 
    if(info /= 0) then
      info=4010
      call psb_errpush(info,name,a_err='allocate')
      goto 9999
    end if

    call inner_coosm(tra,ctra,a%is_lower(),a%is_unit(),a%is_sorted(),&
         & m,nc,nnz,a%ia,a%ja,a%val,&
         & x,size(x,1),tmp,size(tmp,1),info)
    do  i = 1, m
      y(i,1:nc) = alpha*tmp(i,1:nc) + beta*y(i,1:nc)
    end do
  end if

  if(info /= 0) then
    info=4010
    call psb_errpush(info,name,a_err='inner_coosm')
    goto 9999
  end if

  call psb_erractionrestore(err_act)
  return


9999 continue
  call psb_erractionrestore(err_act)

  if (err_act == psb_act_abort_) then
    call psb_error()
    return
  end if
  return


contains 

  subroutine inner_coosm(tra,ctra,lower,unit,sorted,nr,nc,nz,&
       & ia,ja,val,x,ldx,y,ldy,info) 
    implicit none 
    logical, intent(in)                 :: tra,ctra,lower,unit,sorted
    integer, intent(in)                 :: nr,nc,nz,ldx,ldy,ia(*),ja(*)
    complex(psb_spk_), intent(in)       :: val(*), x(ldx,*)
    complex(psb_spk_), intent(out)      :: y(ldy,*)
    integer, intent(out)                :: info

    integer :: i,j,k,m, ir, jc
    complex(psb_spk_), allocatable  :: acc(:)

    info = 0
    allocate(acc(nc), stat=info)
    if(info /= 0) then
      info=4010
      return
    end if


    if (.not.sorted) then 
      info = 1121
      return
    end if

    nnz = nz

    if ((.not.tra).and.(.not.ctra)) then 

      if (lower) then 
        if (unit) then 
          j = 1
          do i=1, nr
            acc(1:nc) = zzero
            do 
              if (j > nnz) exit
              if (ia(j) > i) exit
              acc(1:nc) = acc(1:nc) + val(j)*y(ja(j),1:nc)
              j   = j + 1
            end do
            y(i,1:nc) = x(i,1:nc) - acc(1:nc)
          end do
        else if (.not.unit) then 
          j = 1
          do i=1, nr
            acc(1:nc) = zzero
            do 
              if (j > nnz) exit
              if (ia(j) > i) exit
              if (ja(j) == i) then 
                y(i,1:nc) = (x(i,1:nc) - acc(1:nc))/val(j)
                j = j + 1
                exit
              end if
              acc(1:nc) = acc(1:nc) + val(j)*y(ja(j),1:nc)
              j   = j + 1
            end do
          end do
        end if

      else if (.not.lower) then 
        if (unit) then 
          j = nnz
          do i=nr, 1, -1 
            acc(1:nc) = zzero 
            do 
              if (j < 1) exit
              if (ia(j) < i) exit
              acc(1:nc) = acc(1:nc) + val(j)*x(ja(j),1:nc)
              j   = j - 1
            end do
            y(i,1:nc) = x(i,1:nc) - acc(1:nc)
          end do

        else if (.not.unit) then 

          j = nnz
          do i=nr, 1, -1 
            acc(1:nc) = zzero 
            do 
              if (j < 1) exit
              if (ia(j) < i) exit
              if (ja(j) == i) then 
                y(i,1:nc) = (x(i,1:nc) - acc(1:nc))/val(j)
                j = j - 1
                exit
              end if
              acc(1:nc) = acc(1:nc) + val(j)*y(ja(j),1:nc)
              j   = j - 1
            end do
          end do
        end if

      end if

    else if (tra) then 

      do i=1, nr
        y(i,1:nc) = x(i,1:nc)
      end do

      if (lower) then 
        if (unit) then 
          j = nnz
          do i=nr, 1, -1
            acc(1:nc) = y(i,1:nc) 
            do
              if (j < 1) exit
              if (ia(j) < i) exit
              jc    = ja(j)
              y(jc,1:nc) = y(jc,1:nc) - val(j)*acc(1:nc) 
              j     = j - 1 
            end do
          end do
        else if (.not.unit) then 
          j = nnz
          do i=nr, 1, -1
            if (ja(j) == i) then 
              y(i,1:nc) = y(i,1:nc) /val(j)
              j    = j - 1
            end if
            acc(1:nc)  = y(i,1:nc) 
            do 
              if (j < 1) exit
              if (ia(j) < i) exit
              jc    = ja(j)
              y(jc,1:nc) = y(jc,1:nc) - val(j)*acc(1:nc) 
              j     = j - 1
            end do
          end do

        else if (.not.lower) then 
          if (unit) then 
            j = 1
            do i=1, nr
              acc(1:nc) = y(i,1:nc)
              do 
                if (j > nnz) exit
                if (ia(j) > i) exit
                jc    = ja(j)
                y(jc,1:nc) = y(jc,1:nc) - val(j)*acc(1:nc) 
                j   = j + 1
              end do
            end do
          else if (.not.unit) then 
            j = 1
            do i=1, nr
              if (ja(j) == i) then 
                y(i,1:nc) = y(i,1:nc) /val(j)
                j    = j + 1
              end if
              acc(1:nc) = y(i,1:nc)
              do 
                if (j > nnz) exit
                if (ia(j) > i) exit
                jc    = ja(j)
                y(jc,1:nc) = y(jc,1:nc) - val(j)*acc(1:nc) 
                j   = j + 1
              end do
            end do
          end if
        end if
      end if

    else if (ctra) then 

      do i=1, nr
        y(i,1:nc) = x(i,1:nc)
      end do

      if (lower) then 
        if (unit) then 
          j = nnz
          do i=nr, 1, -1
            acc(1:nc) = y(i,1:nc) 
            do
              if (j < 1) exit
              if (ia(j) < i) exit
              jc    = ja(j)
              y(jc,1:nc) = y(jc,1:nc) - conjg(val(j))*acc(1:nc) 
              j     = j - 1 
            end do
          end do
        else if (.not.unit) then 
          j = nnz
          do i=nr, 1, -1
            if (ja(j) == i) then 
              y(i,1:nc) = y(i,1:nc) /conjg(val(j))
              j    = j - 1
            end if
            acc(1:nc)  = y(i,1:nc) 
            do 
              if (j < 1) exit
              if (ia(j) < i) exit
              jc    = ja(j)
              y(jc,1:nc) = y(jc,1:nc) - conjg(val(j))*acc(1:nc) 
              j     = j - 1
            end do
          end do

        else if (.not.lower) then 
          if (unit) then 
            j = 1
            do i=1, nr
              acc(1:nc) = y(i,1:nc)
              do 
                if (j > nnz) exit
                if (ia(j) > i) exit
                jc    = ja(j)
                y(jc,1:nc) = y(jc,1:nc) - conjg(val(j))*acc(1:nc) 
                j   = j + 1
              end do
            end do
          else if (.not.unit) then 
            j = 1
            do i=1, nr
              if (ja(j) == i) then 
                y(i,1:nc) = y(i,1:nc) /conjg(val(j))
                j    = j + 1
              end if
              acc(1:nc) = y(i,1:nc)
              do 
                if (j > nnz) exit
                if (ia(j) > i) exit
                jc    = ja(j)
                y(jc,1:nc) = y(jc,1:nc) - conjg(val(j))*acc(1:nc) 
                j   = j + 1
              end do
            end do
          end if
        end if
      end if
    end if
  end subroutine inner_coosm

end subroutine c_coo_cssm_impl



subroutine c_coo_cssv_impl(alpha,a,x,beta,y,info,trans) 
  use psb_const_mod
  use psb_error_mod
  use psb_string_mod
  use psb_c_base_mat_mod, psb_protect_name => c_coo_cssv_impl
  implicit none 
  class(psb_c_coo_sparse_mat), intent(in) :: a
  complex(psb_spk_), intent(in)          :: alpha, beta, x(:)
  complex(psb_spk_), intent(inout)       :: y(:)
  integer, intent(out)                :: info
  character, optional, intent(in)     :: trans

  character :: trans_
  integer   :: i,j,k,m,n, nnz, ir, jc
  complex(psb_spk_) :: acc
  complex(psb_spk_), allocatable :: tmp(:)
  logical   :: tra, ctra
  Integer :: err_act
  character(len=20)  :: name='c_coo_cssv_impl'
  logical, parameter :: debug=.false.

  info = 0
  call psb_erractionsave(err_act)

  if (present(trans)) then
    trans_ = trans
  else
    trans_ = 'N'
  end if
  if (.not.a%is_asb()) then 
    info = 1121
    call psb_errpush(info,name)
    goto 9999
  endif

  tra  = (psb_toupper(trans_)=='T')
  ctra = (psb_toupper(trans_)=='C')
  m = a%get_nrows()

  if (.not. (a%is_triangle())) then 
    info = 1121
    call psb_errpush(info,name)
    goto 9999
  end if


  if (alpha == zzero) then
    if (beta == zzero) then
      do i = 1, m
        y(i) = zzero
      enddo
    else
      do  i = 1, m
        y(i) = beta*y(i)
      end do
    endif
    return
  end if

  if (beta == zzero) then 
    call inner_coosv(tra,ctra,a%is_lower(),a%is_unit(),a%is_sorted(),&
         & a%get_nrows(),a%get_nzeros(),a%ia,a%ja,a%val,&
         & x,y,info)
    if (info /= 0) then 
      call psb_errpush(info,name)
      goto 9999
    end if
    do  i = 1, m
      y(i) = alpha*y(i)
    end do
  else 
    allocate(tmp(m), stat=info) 
    if (info /= 0) then 
      info=4010
      call psb_errpush(info,name,a_err='allocate')
      goto 9999
    end if

    call inner_coosv(tra,ctra,a%is_lower(),a%is_unit(),a%is_sorted(),&
         & a%get_nrows(),a%get_nzeros(),a%ia,a%ja,a%val,&
         & x,tmp,info)
    if (info /= 0) then 
      call psb_errpush(info,name)
      goto 9999
    end if
    do  i = 1, m
      y(i) = alpha*tmp(i) + beta*y(i)
    end do
  end if

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)

  if (err_act == psb_act_abort_) then
    call psb_error()
    return
  end if
  return

contains 

  subroutine inner_coosv(tra,ctra,lower,unit,sorted,nr,nz,&
       & ia,ja,val,x,y,info) 
    implicit none 
    logical, intent(in)                 :: tra,ctra,lower,unit,sorted
    integer, intent(in)                 :: nr,nz,ia(*),ja(*)
    complex(psb_spk_), intent(in)       :: val(*), x(*)
    complex(psb_spk_), intent(out)      :: y(*)
    integer, intent(out)                :: info

    integer :: i,j,k,m, ir, jc, nnz
    complex(psb_spk_) :: acc

    info = 0
    if (.not.sorted) then 
      info = 1121
      return
    end if

    nnz = nz

    if ((.not.tra).and.(.not.ctra)) then 

      if (lower) then 
        if (unit) then 
          j = 1
          do i=1, nr
            acc = zzero
            do 
              if (j > nnz) exit
              if (ia(j) > i) exit
              acc = acc + val(j)*y(ja(j))
              j   = j + 1
            end do
            y(i) = x(i) - acc
          end do
        else if (.not.unit) then 
          j = 1
          do i=1, nr
            acc = zzero
            do 
              if (j > nnz) exit
              if (ia(j) > i) exit
              if (ja(j) == i) then 
                y(i) = (x(i) - acc)/val(j)
                j = j + 1
                exit
              end if
              acc = acc + val(j)*y(ja(j))
              j   = j + 1
            end do
          end do
        end if

      else if (.not.lower) then 
        if (unit) then 
          j = nnz
          do i=nr, 1, -1 
            acc = zzero 
            do 
              if (j < 1) exit
              if (ia(j) < i) exit
              acc = acc + val(j)*y(ja(j))
              j   = j - 1
            end do
            y(i) = x(i) - acc
          end do

        else if (.not.unit) then 

          j = nnz
          do i=nr, 1, -1 
            acc = zzero 
            do 
              if (j < 1) exit
              if (ia(j) < i) exit
              if (ja(j) == i) then 
                y(i) = (x(i) - acc)/val(j)
                j = j - 1
                exit
              end if
              acc = acc + val(j)*y(ja(j))
              j   = j - 1
            end do
          end do
        end if

      end if

    else if (tra) then 

      do i=1, nr
        y(i) = x(i)
      end do

      if (lower) then 
        if (unit) then 
          j = nnz
          do i=nr, 1, -1
            acc = y(i) 
            do
              if (j < 1) exit
              if (ia(j) < i) exit
              jc    = ja(j)
              y(jc) = y(jc) - val(j)*acc 
              j     = j - 1 
            end do
          end do
        else if (.not.unit) then 
          j = nnz
          do i=nr, 1, -1
            if (ja(j) == i) then 
              y(i) = y(i) /val(j)
              j    = j - 1
            end if
            acc  = y(i) 
            do 
              if (j < 1) exit
              if (ia(j) < i) exit
              jc    = ja(j)
              y(jc) = y(jc) - val(j)*acc 
              j     = j - 1
            end do
          end do

        else if (.not.lower) then 
          if (unit) then 
            j = 1
            do i=1, nr
              acc = y(i)
              do 
                if (j > nnz) exit
                if (ia(j) > i) exit
                jc    = ja(j)
                y(jc) = y(jc) - val(j)*acc 
                j   = j + 1
              end do
            end do
          else if (.not.unit) then 
            j = 1
            do i=1, nr
              if (ja(j) == i) then 
                y(i) = y(i) /val(j)
                j    = j + 1
              end if
              acc = y(i)
              do 
                if (j > nnz) exit
                if (ia(j) > i) exit
                jc    = ja(j)
                y(jc) = y(jc) - val(j)*acc 
                j   = j + 1
              end do
            end do
          end if
        end if
      end if

    else if (ctra) then 

      do i=1, nr
        y(i) = x(i)
      end do

      if (lower) then 
        if (unit) then 
          j = nnz
          do i=nr, 1, -1
            acc = y(i) 
            do
              if (j < 1) exit
              if (ia(j) < i) exit
              jc    = ja(j)
              y(jc) = y(jc) - conjg(val(j))*acc 
              j     = j - 1 
            end do
          end do
        else if (.not.unit) then 
          j = nnz
          do i=nr, 1, -1
            if (ja(j) == i) then 
              y(i) = y(i) /conjg(val(j))
              j    = j - 1
            end if
            acc  = y(i) 
            do 
              if (j < 1) exit
              if (ia(j) < i) exit
              jc    = ja(j)
              y(jc) = y(jc) - conjg(val(j))*acc 
              j     = j - 1
            end do
          end do

        else if (.not.lower) then 
          if (unit) then 
            j = 1
            do i=1, nr
              acc = y(i)
              do 
                if (j > nnz) exit
                if (ia(j) > i) exit
                jc    = ja(j)
                y(jc) = y(jc) - conjg(val(j))*acc 
                j   = j + 1
              end do
            end do
          else if (.not.unit) then 
            j = 1
            do i=1, nr
              if (ja(j) == i) then 
                y(i) = y(i) /conjg(val(j))
                j    = j + 1
              end if
              acc = y(i)
              do 
                if (j > nnz) exit
                if (ia(j) > i) exit
                jc    = ja(j)
                y(jc) = y(jc) - conjg(val(j))*acc 
                j   = j + 1
              end do
            end do
          end if
        end if
      end if
    end if

  end subroutine inner_coosv


end subroutine c_coo_cssv_impl

subroutine c_coo_csmv_impl(alpha,a,x,beta,y,info,trans) 
  use psb_const_mod
  use psb_error_mod
  use psb_string_mod
  use psb_c_base_mat_mod, psb_protect_name => c_coo_csMv_impl
  implicit none 

  class(psb_c_coo_sparse_mat), intent(in) :: a
  complex(psb_spk_), intent(in)          :: alpha, beta, x(:)
  complex(psb_spk_), intent(inout)       :: y(:)
  integer, intent(out)                :: info
  character, optional, intent(in)     :: trans

  character :: trans_
  integer   :: i,j,k,m,n, nnz, ir, jc
  complex(psb_spk_) :: acc
  logical   :: tra, ctra
  Integer :: err_act
  character(len=20)  :: name='c_coo_csmv_impl'
  logical, parameter :: debug=.false.

  info = 0
  call psb_erractionsave(err_act)

  if (.not.a%is_asb()) then 
    info = 1121
    call psb_errpush(info,name)
    goto 9999
  endif


  if (present(trans)) then
    trans_ = trans
  else
    trans_ = 'N'
  end if

  tra  = (psb_toupper(trans_)=='T')
  ctra = (psb_toupper(trans_)=='C')



  if (tra) then 
    m = a%get_ncols()
    n = a%get_nrows()
  else
    n = a%get_ncols()
    m = a%get_nrows()
  end if
  nnz = a%get_nzeros()

  if (alpha == zzero) then
    if (beta == zzero) then
      do i = 1, m
        y(i) = zzero
      enddo
    else
      do  i = 1, m
        y(i) = beta*y(i)
      end do
    endif
    return
  else 
    if (a%is_triangle().and.a%is_unit()) then 
      if (beta == zzero) then
        do i = 1, min(m,n)
          y(i) = alpha*x(i)
        enddo
        do i = min(m,n)+1, m
          y(i) = zzero
        enddo
      else
        do  i = 1, min(m,n) 
          y(i) = beta*y(i) + alpha*x(i)
        end do
        do i = min(m,n)+1, m
          y(i) = beta*y(i)
        enddo
      endif
    else
      if (beta == zzero) then
        do i = 1, m
          y(i) = zzero
        enddo
      else
        do  i = 1, m
          y(i) = beta*y(i)
        end do
      endif

    endif

  end if

  if ((.not.tra).and.(.not.ctra)) then 
    i    = 1
    j    = i
    if (nnz > 0) then 
      ir   = a%ia(1) 
      acc  = zzero
      do 
        if (i>nnz) then 
          y(ir) = y(ir) + alpha * acc
          exit
        endif
        if (a%ia(i) /= ir) then 
          y(ir) = y(ir) + alpha * acc
          ir    = a%ia(i) 
          acc   = zzero
        endif
        acc     = acc + a%val(i) * x(a%ja(i))
        i       = i + 1               
      enddo
    end if

  else if (tra) then 

    if (alpha == zone) then
      i    = 1
      do i=1,nnz
        ir = a%ja(i)
        jc = a%ia(i)
        y(ir) = y(ir) +  a%val(i)*x(jc)
      enddo

    else if (alpha == -zone) then

      do i=1,nnz
        ir = a%ja(i)
        jc = a%ia(i)
        y(ir) = y(ir) - a%val(i)*x(jc)
      enddo

    else                    

      do i=1,nnz
        ir = a%ja(i)
        jc = a%ia(i)
        y(ir) = y(ir) + alpha*a%val(i)*x(jc)
      enddo

    end if                  !.....end testing on alpha

  else if (ctra) then 

    if (alpha == zone) then
      i    = 1
      do i=1,nnz
        ir = a%ja(i)
        jc = a%ia(i)
        y(ir) = y(ir) +  conjg(a%val(i))*x(jc)
      enddo

    else if (alpha == -zone) then

      do i=1,nnz
        ir = a%ja(i)
        jc = a%ia(i)
        y(ir) = y(ir) - conjg(a%val(i))*x(jc)
      enddo

    else                    

      do i=1,nnz
        ir = a%ja(i)
        jc = a%ia(i)
        y(ir) = y(ir) + alpha*conjg(a%val(i))*x(jc)
      enddo

    end if                  !.....end testing on alpha

  endif

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)

  if (err_act == psb_act_abort_) then
    call psb_error()
    return
  end if
  return

end subroutine c_coo_csmv_impl


subroutine c_coo_csmm_impl(alpha,a,x,beta,y,info,trans) 
  use psb_const_mod
  use psb_error_mod
  use psb_string_mod
  use psb_c_base_mat_mod, psb_protect_name => c_coo_csmm_impl
  implicit none 
  class(psb_c_coo_sparse_mat), intent(in) :: a
  complex(psb_spk_), intent(in)          :: alpha, beta, x(:,:)
  complex(psb_spk_), intent(inout)       :: y(:,:)
  integer, intent(out)                :: info
  character, optional, intent(in)     :: trans

  character :: trans_
  integer   :: i,j,k,m,n, nnz, ir, jc, nc
  complex(psb_spk_), allocatable  :: acc(:)
  logical   :: tra, ctra
  Integer :: err_act
  character(len=20)  :: name='c_coo_csmm_impl'
  logical, parameter :: debug=.false.

  info = 0
  call psb_erractionsave(err_act)


  if (.not.a%is_asb()) then 
    info = 1121
    call psb_errpush(info,name)
    goto 9999
  endif


  if (present(trans)) then
    trans_ = trans
  else
    trans_ = 'N'
  end if


  tra  = (psb_toupper(trans_)=='T')
  ctra = (psb_toupper(trans_)=='C')


  if (tra) then 
    m = a%get_ncols()
    n = a%get_nrows()
  else
    n = a%get_ncols()
    m = a%get_nrows()
  end if
  nnz = a%get_nzeros()

  nc = min(size(x,2), size(y,2))
  allocate(acc(nc),stat=info)
  if(info /= 0) then
    info=4010
    call psb_errpush(info,name,a_err='allocate')
    goto 9999
  end if


  if (alpha == zzero) then
    if (beta == zzero) then
      do i = 1, m
        y(i,1:nc) = zzero
      enddo
    else
      do  i = 1, m
        y(i,1:nc) = beta*y(i,1:nc)
      end do
    endif
    return
  else 
    if (a%is_triangle().and.a%is_unit()) then 
      if (beta == zzero) then
        do i = 1, min(m,n)
          y(i,1:nc) = alpha*x(i,1:nc)
        enddo
        do i = min(m,n)+1, m
          y(i,1:nc) = zzero
        enddo
      else
        do  i = 1, min(m,n) 
          y(i,1:nc) = beta*y(i,1:nc) + alpha*x(i,1:nc)
        end do
        do i = min(m,n)+1, m
          y(i,1:nc) = beta*y(i,1:nc)
        enddo
      endif
    else
      if (beta == zzero) then
        do i = 1, m
          y(i,1:nc) = zzero
        enddo
      else
        do  i = 1, m
          y(i,1:nc) = beta*y(i,1:nc)
        end do
      endif

    endif

  end if

  if ((.not.tra).and.(.not.ctra)) then 
    i    = 1
    j    = i
    if (nnz > 0) then 
      ir   = a%ia(1) 
      acc  = zzero
      do 
        if (i>nnz) then 
          y(ir,1:nc) = y(ir,1:nc) + alpha * acc
          exit
        endif
        if (a%ia(i) /= ir) then 
          y(ir,1:nc) = y(ir,1:nc) + alpha * acc
          ir    = a%ia(i) 
          acc   = zzero
        endif
        acc     = acc + a%val(i) * x(a%ja(i),1:nc)
        i       = i + 1               
      enddo
    end if

  else if (tra) then 
    if (alpha == zone) then
      i    = 1
      do i=1,nnz
        ir = a%ja(i)
        jc = a%ia(i)
        y(ir,1:nc) = y(ir,1:nc) +  a%val(i)*x(jc,1:nc)
      enddo

    else if (alpha == -zone) then

      do i=1,nnz
        ir = a%ja(i)
        jc = a%ia(i)
        y(ir,1:nc) = y(ir,1:nc) - a%val(i)*x(jc,1:nc)
      enddo

    else                    

      do i=1,nnz
        ir = a%ja(i)
        jc = a%ia(i)
        y(ir,1:nc) = y(ir,1:nc) + alpha*a%val(i)*x(jc,1:nc)
      enddo

    end if                  !.....end testing on alpha

  else if (ctra) then 

    if (alpha == zone) then
      i    = 1
      do i=1,nnz
        ir = a%ja(i)
        jc = a%ia(i)
        y(ir,1:nc) = y(ir,1:nc) +  conjg(a%val(i))*x(jc,1:nc)
      enddo

    else if (alpha == -zone) then

      do i=1,nnz
        ir = a%ja(i)
        jc = a%ia(i)
        y(ir,1:nc) = y(ir,1:nc) - conjg(a%val(i))*x(jc,1:nc)
      enddo

    else                    

      do i=1,nnz
        ir = a%ja(i)
        jc = a%ia(i)
        y(ir,1:nc) = y(ir,1:nc) + alpha*conjg(a%val(i))*x(jc,1:nc)
      enddo

    end if                  !.....end testing on alpha

  endif

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)

  if (err_act == psb_act_abort_) then
    call psb_error()
    return
  end if
  return

end subroutine c_coo_csmm_impl

function c_coo_csnmi_impl(a) result(res)
  use psb_error_mod
  use psb_c_base_mat_mod, psb_protect_name => c_coo_csnmi_impl
  implicit none 
  class(psb_c_coo_sparse_mat), intent(in) :: a
  real(psb_spk_)         :: res

  integer   :: i,j,k,m,n, nnz, ir, jc, nc
  real(psb_spk_) :: acc
  logical   :: tra
  Integer :: err_act
  character(len=20)  :: name='c_base_csnmi'
  logical, parameter :: debug=.false.


  res = dzero 
  nnz = a%get_nzeros()
  i   = 1
  j   = i
  do while (i<=nnz) 
    do while ((a%ia(j) == a%ia(i)).and. (j <= nnz))
      j = j+1
    enddo
    acc = dzero
    do k=i, j-1
      acc = acc + abs(a%val(k))
    end do
    res = max(res,acc)
    i = j
  end do

end function c_coo_csnmi_impl



!====================================
!
!
!
! Data management
!
!
!
!
!
!====================================



subroutine c_coo_csgetptn_impl(imin,imax,a,nz,ia,ja,info,&
     & jmin,jmax,iren,append,nzin,rscale,cscale)
  ! Output is always in  COO format 
  use psb_error_mod
  use psb_const_mod
  use psb_error_mod
  use psb_c_base_mat_mod, psb_protect_name => c_coo_csgetptn_impl
  implicit none

  class(psb_c_coo_sparse_mat), intent(in) :: a
  integer, intent(in)                  :: imin,imax
  integer, intent(out)                 :: nz
  integer, allocatable, intent(inout)  :: ia(:), ja(:)
  integer,intent(out)                  :: info
  logical, intent(in), optional        :: append
  integer, intent(in), optional        :: iren(:)
  integer, intent(in), optional        :: jmin,jmax, nzin
  logical, intent(in), optional        :: rscale,cscale

  logical :: append_, rscale_, cscale_ 
  integer :: nzin_, jmin_, jmax_, err_act, i
  character(len=20)  :: name='csget'
  logical, parameter :: debug=.false.

  call psb_erractionsave(err_act)
  info = 0

  if (present(jmin)) then
    jmin_ = jmin
  else
    jmin_ = 1
  endif
  if (present(jmax)) then
    jmax_ = jmax
  else
    jmax_ = a%get_ncols()
  endif

  if ((imax<imin).or.(jmax_<jmin_)) then 
    nz = 0
    return
  end if

  if (present(append)) then
    append_=append
  else
    append_=.false.
  endif
  if ((append_).and.(present(nzin))) then 
    nzin_ = nzin
  else
    nzin_ = 0
  endif
  if (present(rscale)) then 
    rscale_ = rscale
  else
    rscale_ = .false.
  endif
  if (present(cscale)) then 
    cscale_ = cscale
  else
    cscale_ = .false.
  endif
  if ((rscale_.or.cscale_).and.(present(iren))) then 
    info = 583
    call psb_errpush(info,name,a_err='iren (rscale.or.cscale)')
    goto 9999
  end if

  call coo_getptn(imin,imax,jmin_,jmax_,a,nz,ia,ja,nzin_,append_,info,&
       & iren)
  
  if (rscale_) then 
    do i=nzin_+1, nzin_+nz
      ia(i) = ia(i) - imin + 1
    end do
  end if
  if (cscale_) then 
    do i=nzin_+1, nzin_+nz
      ja(i) = ja(i) - jmin_ + 1
    end do
  end if

  if (info /= 0) goto 9999

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)

  if (err_act == psb_act_abort_) then
    call psb_error()
    return
  end if
  return

contains

  subroutine coo_getptn(imin,imax,jmin,jmax,a,nz,ia,ja,nzin,append,info,&
       & iren)

    use psb_const_mod
    use psb_error_mod
    use psb_realloc_mod
    use psb_sort_mod
    implicit none

    class(psb_c_coo_sparse_mat), intent(in)    :: a
    integer                              :: imin,imax,jmin,jmax
    integer, intent(out)                 :: nz
    integer, allocatable, intent(inout)  :: ia(:), ja(:)
    integer, intent(in)                  :: nzin
    logical, intent(in)                  :: append
    integer                              :: info
    integer, optional                    :: iren(:)
    integer  :: nzin_, nza, idx,ip,jp,i,k, nzt, irw, lrw
    integer  :: debug_level, debug_unit
    character(len=20) :: name='coo_getptn'

    debug_unit  = psb_get_debug_unit()
    debug_level = psb_get_debug_level()

    nza = a%get_nzeros()
    irw = imin
    lrw = imax
    if (irw<0) then 
      info = 2
      return
    end if

    if (append) then 
      nzin_ = nzin
    else
      nzin_ = 0
    endif

    if (a%is_sorted()) then 
      ! In this case we can do a binary search. 
      if (debug_level >= psb_debug_serial_)&
           & write(debug_unit,*) trim(name), ': srtdcoo '
      do
        ip = psb_ibsrch(irw,nza,a%ia)
        if (ip /= -1) exit
        irw = irw + 1
        if (irw > imax) then
          write(debug_unit,*)  trim(name),&
               & 'Warning : did not find any rows. Is this an error? ',&
               & irw,lrw,imin
          exit
        end if
      end do

      if (ip /= -1) then 
        ! expand [ip,jp] to contain all row entries.
        do 
          if (ip < 2) exit
          if (a%ia(ip-1) == irw) then  
            ip = ip -1 
          else 
            exit
          end if
        end do

      end if

      do
        jp = psb_ibsrch(lrw,nza,a%ia)
        if (jp /= -1) exit
        lrw = lrw - 1
        if (irw > lrw) then
          write(debug_unit,*) trim(name),&
               & 'Warning : did not find any rows. Is this an error?'
          exit
        end if
      end do

      if (jp /= -1) then 
        ! expand [ip,jp] to contain all row entries.
        do 
          if (jp == nza) exit
          if (a%ia(jp+1) == lrw) then  
            jp = jp + 1
          else 
            exit
          end if
        end do
      end if
      if (debug_level >= psb_debug_serial_) &
           & write(debug_unit,*)  trim(name),': ip jp',ip,jp,nza
      if ((ip /= -1) .and.(jp /= -1)) then 
        ! Now do the copy.
        nzt = jp - ip +1 
        nz = 0 

        call psb_ensure_size(nzin_+nzt,ia,info)
        if (info==0) call psb_ensure_size(nzin_+nzt,ja,info)
        if (info /= 0) return

        if (present(iren)) then 
          do i=ip,jp
            if ((jmin <= a%ja(i)).and.(a%ja(i)<=jmax)) then 
              nzin_ = nzin_ + 1
              nz    = nz + 1
              ia(nzin_)  = iren(a%ia(i))
              ja(nzin_)  = iren(a%ja(i))
            end if
          enddo
        else
          do i=ip,jp
            if ((jmin <= a%ja(i)).and.(a%ja(i)<=jmax)) then 
              nzin_ = nzin_ + 1
              nz    = nz + 1
              ia(nzin_)  = a%ia(i)
              ja(nzin_)  = a%ja(i)
            end if
          enddo
        end if
      else 
        nz = 0 
      end if

    else
      if (debug_level >= psb_debug_serial_) &
           & write(debug_unit,*)  trim(name),': unsorted '

      nzt = (nza*(lrw-irw+1))/max(a%get_nrows(),1)
      call psb_ensure_size(nzin_+nzt,ia,info)
      if (info==0) call psb_ensure_size(nzin_+nzt,ja,info)
      if (info /= 0) return

      if (present(iren)) then 
        k = 0 
        do i=1, a%get_nzeros()
          if ((a%ia(i)>=irw).and.(a%ia(i)<=lrw).and.&
               & (jmin <= a%ja(i)).and.(a%ja(i)<=jmax)) then 
            k = k + 1 
            if (k > nzt) then
              nzt = k 
              call psb_ensure_size(nzin_+nzt,ia,info)
              if (info==0) call psb_ensure_size(nzin_+nzt,ja,info)
              if (info /= 0) return
            end if
            ia(nzin_+k)  = iren(a%ia(i))
            ja(nzin_+k)  = iren(a%ja(i))
          endif
        enddo
      else
        k = 0 
        do i=1,a%get_nzeros()
          if ((a%ia(i)>=irw).and.(a%ia(i)<=lrw).and.&
               & (jmin <= a%ja(i)).and.(a%ja(i)<=jmax)) then 
            k = k + 1 
            if (k > nzt) then
              nzt = k 
              call psb_ensure_size(nzin_+nzt,ia,info)
              if (info==0) call psb_ensure_size(nzin_+nzt,ja,info)
              if (info /= 0) return

            end if
            ia(nzin_+k)  = (a%ia(i))
            ja(nzin_+k)  = (a%ja(i))
          endif
        enddo
        nzin_=nzin_+k
      end if
      nz = k 
    end if

  end subroutine coo_getptn

end subroutine c_coo_csgetptn_impl


subroutine c_coo_csgetrow_impl(imin,imax,a,nz,ia,ja,val,info,&
     & jmin,jmax,iren,append,nzin,rscale,cscale)
  ! Output is always in  COO format 
  use psb_error_mod
  use psb_const_mod
  use psb_error_mod
  use psb_c_base_mat_mod, psb_protect_name => c_coo_csgetrow_impl
  implicit none

  class(psb_c_coo_sparse_mat), intent(in) :: a
  integer, intent(in)                  :: imin,imax
  integer, intent(out)                 :: nz
  integer, allocatable, intent(inout)  :: ia(:), ja(:)
  complex(psb_spk_), allocatable,  intent(inout)    :: val(:)
  integer,intent(out)                  :: info
  logical, intent(in), optional        :: append
  integer, intent(in), optional        :: iren(:)
  integer, intent(in), optional        :: jmin,jmax, nzin
  logical, intent(in), optional        :: rscale,cscale

  logical :: append_, rscale_, cscale_ 
  integer :: nzin_, jmin_, jmax_, err_act, i
  character(len=20)  :: name='csget'
  logical, parameter :: debug=.false.

  call psb_erractionsave(err_act)
  info = 0

  if (present(jmin)) then
    jmin_ = jmin
  else
    jmin_ = 1
  endif
  if (present(jmax)) then
    jmax_ = jmax
  else
    jmax_ = a%get_ncols()
  endif

  if ((imax<imin).or.(jmax_<jmin_)) then 
    nz = 0
    return
  end if

  if (present(append)) then
    append_=append
  else
    append_=.false.
  endif
  if ((append_).and.(present(nzin))) then 
    nzin_ = nzin
  else
    nzin_ = 0
  endif
  if (present(rscale)) then 
    rscale_ = rscale
  else
    rscale_ = .false.
  endif
  if (present(cscale)) then 
    cscale_ = cscale
  else
    cscale_ = .false.
  endif
  if ((rscale_.or.cscale_).and.(present(iren))) then 
    info = 583
    call psb_errpush(info,name,a_err='iren (rscale.or.cscale)')
    goto 9999
  end if

  call coo_getrow(imin,imax,jmin_,jmax_,a,nz,ia,ja,val,nzin_,append_,info,&
       & iren)
  
  if (rscale_) then 
    do i=nzin_+1, nzin_+nz
      ia(i) = ia(i) - imin + 1
    end do
  end if
  if (cscale_) then 
    do i=nzin_+1, nzin_+nz
      ja(i) = ja(i) - jmin_ + 1
    end do
  end if

  if (info /= 0) goto 9999

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)

  if (err_act == psb_act_abort_) then
    call psb_error()
    return
  end if
  return

contains

  subroutine coo_getrow(imin,imax,jmin,jmax,a,nz,ia,ja,val,nzin,append,info,&
       & iren)

    use psb_const_mod
    use psb_error_mod
    use psb_realloc_mod
    use psb_sort_mod
    implicit none

    class(psb_c_coo_sparse_mat), intent(in)    :: a
    integer                              :: imin,imax,jmin,jmax
    integer, intent(out)                 :: nz
    integer, allocatable, intent(inout)  :: ia(:), ja(:)
    complex(psb_spk_), allocatable,  intent(inout)    :: val(:)
    integer, intent(in)                  :: nzin
    logical, intent(in)                  :: append
    integer                              :: info
    integer, optional                    :: iren(:)
    integer  :: nzin_, nza, idx,ip,jp,i,k, nzt, irw, lrw
    integer  :: debug_level, debug_unit
    character(len=20) :: name='coo_getrow'

    debug_unit  = psb_get_debug_unit()
    debug_level = psb_get_debug_level()

    nza = a%get_nzeros()
    irw = imin
    lrw = imax
    if (irw<0) then 
      info = 2
      return
    end if

    if (append) then 
      nzin_ = nzin
    else
      nzin_ = 0
    endif

    if (a%is_sorted()) then 
      ! In this case we can do a binary search. 
      if (debug_level >= psb_debug_serial_)&
           & write(debug_unit,*) trim(name), ': srtdcoo '
      do
        ip = psb_ibsrch(irw,nza,a%ia)
        if (ip /= -1) exit
        irw = irw + 1
        if (irw > imax) then
          write(debug_unit,*)  trim(name),&
               & 'Warning : did not find any rows. Is this an error? ',&
               & irw,lrw,imin
          exit
        end if
      end do

      if (ip /= -1) then 
        ! expand [ip,jp] to contain all row entries.
        do 
          if (ip < 2) exit
          if (a%ia(ip-1) == irw) then  
            ip = ip -1 
          else 
            exit
          end if
        end do

      end if

      do
        jp = psb_ibsrch(lrw,nza,a%ia)
        if (jp /= -1) exit
        lrw = lrw - 1
        if (irw > lrw) then
          write(debug_unit,*) trim(name),&
               & 'Warning : did not find any rows. Is this an error?'
          exit
        end if
      end do

      if (jp /= -1) then 
        ! expand [ip,jp] to contain all row entries.
        do 
          if (jp == nza) exit
          if (a%ia(jp+1) == lrw) then  
            jp = jp + 1
          else 
            exit
          end if
        end do
      end if
      if (debug_level >= psb_debug_serial_) &
           & write(debug_unit,*)  trim(name),': ip jp',ip,jp,nza
      if ((ip /= -1) .and.(jp /= -1)) then 
        ! Now do the copy.
        nzt = jp - ip +1 
        nz = 0 

        call psb_ensure_size(nzin_+nzt,ia,info)
        if (info==0) call psb_ensure_size(nzin_+nzt,ja,info)
        if (info==0) call psb_ensure_size(nzin_+nzt,val,info)
        if (info /= 0) return

        if (present(iren)) then 
          do i=ip,jp
            if ((jmin <= a%ja(i)).and.(a%ja(i)<=jmax)) then 
              nzin_ = nzin_ + 1
              nz    = nz + 1
              val(nzin_) = a%val(i)
              ia(nzin_)  = iren(a%ia(i))
              ja(nzin_)  = iren(a%ja(i))
            end if
          enddo
        else
          do i=ip,jp
            if ((jmin <= a%ja(i)).and.(a%ja(i)<=jmax)) then 
              nzin_ = nzin_ + 1
              nz    = nz + 1
              val(nzin_) = a%val(i)
              ia(nzin_)  = a%ia(i)
              ja(nzin_)  = a%ja(i)
            end if
          enddo
        end if
      else 
        nz = 0 
      end if

    else
      if (debug_level >= psb_debug_serial_) &
           & write(debug_unit,*)  trim(name),': unsorted '

      nzt = (nza*(lrw-irw+1))/max(a%get_nrows(),1)
      call psb_ensure_size(nzin_+nzt,ia,info)
      if (info==0) call psb_ensure_size(nzin_+nzt,ja,info)
      if (info==0) call psb_ensure_size(nzin_+nzt,val,info)
      if (info /= 0) return

      if (present(iren)) then 
        k = 0 
        do i=1, a%get_nzeros()
          if ((a%ia(i)>=irw).and.(a%ia(i)<=lrw).and.&
               & (jmin <= a%ja(i)).and.(a%ja(i)<=jmax)) then 
            k = k + 1 
            if (k > nzt) then
              nzt = k 
              call psb_ensure_size(nzin_+nzt,ia,info)
              if (info==0) call psb_ensure_size(nzin_+nzt,ja,info)
              if (info==0) call psb_ensure_size(nzin_+nzt,val,info)
              if (info /= 0) return
            end if
            val(nzin_+k) = a%val(i)
            ia(nzin_+k)  = iren(a%ia(i))
            ja(nzin_+k)  = iren(a%ja(i))
          endif
        enddo
      else
        k = 0 
        do i=1,a%get_nzeros()
          if ((a%ia(i)>=irw).and.(a%ia(i)<=lrw).and.&
               & (jmin <= a%ja(i)).and.(a%ja(i)<=jmax)) then 
            k = k + 1 
            if (k > nzt) then
              nzt = k 
              call psb_ensure_size(nzin_+nzt,ia,info)
              if (info==0) call psb_ensure_size(nzin_+nzt,ja,info)
              if (info==0) call psb_ensure_size(nzin_+nzt,val,info)
              if (info /= 0) return

            end if
            val(nzin_+k) = a%val(i)
            ia(nzin_+k)  = (a%ia(i))
            ja(nzin_+k)  = (a%ja(i))
          endif
        enddo
        nzin_=nzin_+k
      end if
      nz = k 
    end if

  end subroutine coo_getrow

end subroutine c_coo_csgetrow_impl


subroutine c_coo_csput_impl(nz,ia,ja,val,a,imin,imax,jmin,jmax,info,gtl) 
  use psb_error_mod
  use psb_realloc_mod
  use psb_sort_mod
  use psb_c_base_mat_mod, psb_protect_name => c_coo_csput_impl
  implicit none 
    
  class(psb_c_coo_sparse_mat), intent(inout) :: a
  complex(psb_spk_), intent(in)      :: val(:)
  integer, intent(in)             :: nz, ia(:), ja(:), imin,imax,jmin,jmax
  integer, intent(out)            :: info
  integer, intent(in), optional   :: gtl(:)


  Integer            :: err_act
  character(len=20)  :: name='c_coo_csput_impl'
  logical, parameter :: debug=.false.
  integer            :: nza, i,j,k, nzl, isza, int_err(5)

  info = 0
  call psb_erractionsave(err_act)
  
  if (nz <= 0) then 
    info = 10
    int_err(1)=1
    call psb_errpush(info,name,i_err=int_err)
    goto 9999
  end if
  if (size(ia) < nz) then 
    info = 35
    int_err(1)=2
    call psb_errpush(info,name,i_err=int_err)
    goto 9999
  end if

  if (size(ja) < nz) then 
    info = 35
    int_err(1)=3
    call psb_errpush(info,name,i_err=int_err)
    goto 9999
  end if
  if (size(val) < nz) then 
    info = 35
    int_err(1)=4
    call psb_errpush(info,name,i_err=int_err)
    goto 9999
  end if

  if (nz == 0) return


  nza  = a%get_nzeros()
  isza = a%get_size()
  if (a%is_bld()) then 
    ! Build phase. Must handle reallocations in a sensible way.
    if (isza < (nza+nz)) then 
      call a%reallocate(max(nza+nz,int(1.5*isza)))
      isza = a%get_size()
    endif

    call psb_inner_ins(nz,ia,ja,val,nza,a%ia,a%ja,a%val,isza,&
         & imin,imax,jmin,jmax,info,gtl)
    call a%set_nzeros(nza)
    call a%set_sorted(.false.)
    

  else  if (a%is_upd()) then 

    call  c_coo_srch_upd(nz,ia,ja,val,a,&
         & imin,imax,jmin,jmax,info,gtl)
    if (info /= 0) then 
      info = 1121
    end if

  else 
    ! State is wrong.
    info = 1121
  end if
  if (info /= 0) then
    call psb_errpush(info,name)
    goto 9999
  end if

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)

  if (err_act == psb_act_abort_) then
    call psb_error()
    return
  end if
  return


contains

  subroutine psb_inner_ins(nz,ia,ja,val,nza,ia1,ia2,aspk,maxsz,&
       & imin,imax,jmin,jmax,info,gtl)
    implicit none 

    integer, intent(in) :: nz, imin,imax,jmin,jmax,maxsz
    integer, intent(in) :: ia(:),ja(:)
    integer, intent(inout) :: nza,ia1(:),ia2(:)
    complex(psb_spk_), intent(in) :: val(:)
    complex(psb_spk_), intent(inout) :: aspk(:)
    integer, intent(out) :: info
    integer, intent(in), optional  :: gtl(:)
    integer :: i,ir,ic,ng

    info = 0
    if (present(gtl)) then 
      ng = size(gtl) 

      do i=1, nz 
        ir = ia(i)
        ic = ja(i) 
        if ((ir >=1).and.(ir<=ng).and.(ic>=1).and.(ic<=ng)) then 
          ir = gtl(ir)
          ic = gtl(ic) 
          if ((ir >=imin).and.(ir<=imax).and.(ic>=jmin).and.(ic<=jmax)) then 
            nza = nza + 1 
            if (nza > maxsz) then 
              info = -91
              return
            endif
            ia1(nza) = ir
            ia2(nza) = ic
            aspk(nza) = val(i)
          end if
        end if
      end do
    else

      do i=1, nz 
        ir = ia(i)
        ic = ja(i) 
        if ((ir >=imin).and.(ir<=imax).and.(ic>=jmin).and.(ic<=jmax)) then 
          nza = nza + 1 
          if (nza > maxsz) then 
            info = -92
            return
          endif
          ia1(nza) = ir
          ia2(nza) = ic
          aspk(nza) = val(i)
        end if
      end do
    end if

  end subroutine psb_inner_ins


  subroutine c_coo_srch_upd(nz,ia,ja,val,a,&
       & imin,imax,jmin,jmax,info,gtl)

    use psb_const_mod
    use psb_realloc_mod
    use psb_string_mod
    implicit none 

    class(psb_c_coo_sparse_mat), intent(inout) :: a
    integer, intent(in) :: nz, imin,imax,jmin,jmax
    integer, intent(in) :: ia(:),ja(:)
    complex(psb_spk_), intent(in) :: val(:)
    integer, intent(out) :: info
    integer, intent(in), optional  :: gtl(:)
    integer  :: i,ir,ic, ilr, ilc, ip, &
         & i1,i2,nc,nnz,dupl,ng, nr
    integer              :: debug_level, debug_unit
    character(len=20)    :: name='c_coo_srch_upd'

    info = 0
    debug_unit  = psb_get_debug_unit()
    debug_level = psb_get_debug_level()

    dupl = a%get_dupl()

    if (.not.a%is_sorted()) then 
      info = -4
      return
    end if

    ilr = -1 
    ilc = -1 
    nnz = a%get_nzeros()
    nr = a%get_nrows()
    nc = a%get_ncols()


    if (present(gtl)) then
      ng = size(gtl)

      select case(dupl)
      case(psb_dupl_ovwrt_,psb_dupl_err_)
        ! Overwrite.
        ! Cannot test for error, should have been caught earlier.
        do i=1, nz
          ir = ia(i)
          ic = ja(i) 
          if ((ir >=1).and.(ir<=ng).and.(ic>=1).and.(ic<=ng)) then 
            ir = gtl(ir)
            if ((ir > 0).and.(ir <= nr)) then 
              ic = gtl(ic) 
              if (ir /= ilr) then 
                i1 = psb_ibsrch(ir,nnz,a%ia)
                i2 = i1
                do 
                  if (i2+1 > nnz) exit
                  if (a%ia(i2+1) /= a%ia(i2)) exit
                  i2 = i2 + 1
                end do
                do 
                  if (i1-1 < 1) exit
                  if (a%ia(i1-1) /= a%ia(i1)) exit
                  i1 = i1 - 1
                end do
                ilr = ir
              else
                i1 = 1
                i2 = 1
              end if
              nc = i2-i1+1
              ip = psb_issrch(ic,nc,a%ja(i1:i2))
              if (ip>0) then 
                a%val(i1+ip-1) = val(i)
              else
                info = i 
                return
              end if
            else
              if (debug_level >= psb_debug_serial_) &
                   & write(debug_unit,*) trim(name),&
                   & ': Discarding row that does not belong to us.'
            endif
          end if
        end do
      case(psb_dupl_add_)
        ! Add
        do i=1, nz
          ir = ia(i)
          ic = ja(i) 
          if ((ir >=1).and.(ir<=ng).and.(ic>=1).and.(ic<=ng)) then 
            ir = gtl(ir)
            ic = gtl(ic) 
            if ((ir > 0).and.(ir <= nr)) then 

              if (ir /= ilr) then 
                i1 = psb_ibsrch(ir,nnz,a%ia)
                i2 = i1
                do 
                  if (i2+1 > nnz) exit
                  if (a%ia(i2+1) /= a%ia(i2)) exit
                  i2 = i2 + 1
                end do
                do 
                  if (i1-1 < 1) exit
                  if (a%ia(i1-1) /= a%ia(i1)) exit
                  i1 = i1 - 1
                end do
                ilr = ir
              else
                i1 = 1
                i2 = 1
              end if
              nc = i2-i1+1
              ip = psb_issrch(ic,nc,a%ja(i1:i2))
              if (ip>0) then 
                a%val(i1+ip-1) = a%val(i1+ip-1) + val(i)
              else
                info = i 
                return
              end if
            else
              if (debug_level >= psb_debug_serial_) &
                   & write(debug_unit,*) trim(name),&
                   & ': Discarding row that does not belong to us.'              
            end if
          end if
        end do

      case default
        info = -3
        if (debug_level >= psb_debug_serial_) &
             & write(debug_unit,*) trim(name),&
             & ': Duplicate handling: ',dupl
      end select

    else

      select case(dupl)
      case(psb_dupl_ovwrt_,psb_dupl_err_)
        ! Overwrite.
        ! Cannot test for error, should have been caught earlier.
        do i=1, nz
          ir = ia(i)
          ic = ja(i) 
          if ((ir > 0).and.(ir <= nr)) then 

            if (ir /= ilr) then 
              i1 = psb_ibsrch(ir,nnz,a%ia)
              i2 = i1
              do 
                if (i2+1 > nnz) exit
                if (a%ia(i2+1) /= a%ia(i2)) exit
                i2 = i2 + 1
              end do
              do 
                if (i1-1 < 1) exit
                if (a%ia(i1-1) /= a%ia(i1)) exit
                i1 = i1 - 1
              end do
              ilr = ir
            else
              i1 = 1
              i2 = 1
            end if
            nc = i2-i1+1
            ip = psb_issrch(ic,nc,a%ja(i1:i2))
            if (ip>0) then 
              a%val(i1+ip-1) = val(i)
            else
              info = i 
              return
            end if
          end if
        end do

      case(psb_dupl_add_)
        ! Add
        do i=1, nz
          ir = ia(i)
          ic = ja(i) 
          if ((ir > 0).and.(ir <= nr)) then 

            if (ir /= ilr) then 
              i1 = psb_ibsrch(ir,nnz,a%ia)
              i2 = i1
              do 
                if (i2+1 > nnz) exit
                if (a%ia(i2+1) /= a%ia(i2)) exit
                i2 = i2 + 1
              end do
              do 
                if (i1-1 < 1) exit
                if (a%ia(i1-1) /= a%ia(i1)) exit
                i1 = i1 - 1
              end do
              ilr = ir
            else
              i1 = 1
              i2 = 1
            end if
            nc = i2-i1+1
            ip = psb_issrch(ic,nc,a%ja(i1:i2))
            if (ip>0) then 
              a%val(i1+ip-1) = a%val(i1+ip-1) + val(i)
            else
              info = i 
              return
            end if
          end if
        end do

      case default
        info = -3
        if (debug_level >= psb_debug_serial_) &
             & write(debug_unit,*) trim(name),&
             & ': Duplicate handling: ',dupl
      end select

    end if

  end subroutine c_coo_srch_upd

end subroutine c_coo_csput_impl


subroutine c_cp_coo_to_coo_impl(a,b,info) 
  use psb_error_mod
  use psb_realloc_mod
  use psb_c_base_mat_mod, psb_protect_name => c_cp_coo_to_coo_impl
  implicit none 
  class(psb_c_coo_sparse_mat), intent(in) :: a
  class(psb_c_coo_sparse_mat), intent(out) :: b
  integer, intent(out)            :: info

  Integer :: err_act
  character(len=20)  :: name='to_coo'
  logical, parameter :: debug=.false.


  call psb_erractionsave(err_act)
  info = 0
  call b%psb_c_base_sparse_mat%cp_from(a%psb_c_base_sparse_mat)

  call b%set_nzeros(a%get_nzeros())
  call b%reallocate(a%get_nzeros())

  b%ia(:)  = a%ia(:)
  b%ja(:)  = a%ja(:)
  b%val(:) = a%val(:)

  call b%fix(info)

  if (info /= 0) goto 9999

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)

  call psb_errpush(info,name)

  if (err_act /= psb_act_ret_) then
    call psb_error()
  end if
  return

end subroutine c_cp_coo_to_coo_impl
  
subroutine c_cp_coo_from_coo_impl(a,b,info) 
  use psb_error_mod
  use psb_realloc_mod
  use psb_c_base_mat_mod, psb_protect_name => c_cp_coo_from_coo_impl
  implicit none 
  class(psb_c_coo_sparse_mat), intent(out) :: a
  class(psb_c_coo_sparse_mat), intent(in) :: b
  integer, intent(out)            :: info

  Integer :: err_act
  character(len=20)  :: name='from_coo'
  logical, parameter :: debug=.false.
  integer :: m,n,nz


  call psb_erractionsave(err_act)
  info = 0
  call a%psb_c_base_sparse_mat%cp_from(b%psb_c_base_sparse_mat)
  call a%set_nzeros(b%get_nzeros())
  call a%reallocate(b%get_nzeros())

  a%ia(:)  = b%ia(:)
  a%ja(:)  = b%ja(:)
  a%val(:) = b%val(:)

  call a%fix(info)

  if (info /= 0) goto 9999

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)

  call psb_errpush(info,name)

  if (err_act /= psb_act_ret_) then
    call psb_error()
  end if
  return

end subroutine c_cp_coo_from_coo_impl


subroutine c_cp_coo_to_fmt_impl(a,b,info) 
  use psb_error_mod
  use psb_realloc_mod
  use psb_c_base_mat_mod, psb_protect_name => c_cp_coo_to_fmt_impl
  implicit none 
  class(psb_c_coo_sparse_mat), intent(in) :: a
  class(psb_c_base_sparse_mat), intent(out) :: b
  integer, intent(out)            :: info

  Integer :: err_act
  character(len=20)  :: name='to_coo'
  logical, parameter :: debug=.false.


  call psb_erractionsave(err_act)
  info = 0

  call b%cp_from_coo(a,info)

  if (info /= 0) goto 9999

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)

  call psb_errpush(info,name)

  if (err_act /= psb_act_ret_) then
    call psb_error()
  end if
  return

end subroutine c_cp_coo_to_fmt_impl
  
subroutine c_cp_coo_from_fmt_impl(a,b,info) 
  use psb_error_mod
  use psb_realloc_mod
  use psb_c_base_mat_mod, psb_protect_name => c_cp_coo_from_fmt_impl
  implicit none 
  class(psb_c_coo_sparse_mat), intent(inout) :: a
  class(psb_c_base_sparse_mat), intent(in) :: b
  integer, intent(out)            :: info

  Integer :: err_act
  character(len=20)  :: name='from_coo'
  logical, parameter :: debug=.false.
  integer :: m,n,nz


  call psb_erractionsave(err_act)
  info = 0

  call b%cp_to_coo(a,info)

  if (info /= 0) goto 9999

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)

  call psb_errpush(info,name)

  if (err_act /= psb_act_ret_) then
    call psb_error()
  end if
  return

end subroutine c_cp_coo_from_fmt_impl


subroutine c_fix_coo_impl(a,info,idir) 
  use psb_const_mod
  use psb_error_mod
  use psb_realloc_mod
  use psb_string_mod
  use psb_ip_reord_mod
  use psb_c_base_mat_mod, psb_protect_name => c_fix_coo_impl
  implicit none 

  class(psb_c_coo_sparse_mat), intent(inout) :: a
  integer, intent(out)                :: info
  integer, intent(in), optional :: idir
  integer, allocatable :: iaux(:)
  !locals
  Integer              :: nza, nzl,iret,idir_, dupl_
  integer              :: i,j, irw, icl, err_act
  integer              :: debug_level, debug_unit
  character(len=20)    :: name = 'psb_fixcoo'

  info  = 0

  call psb_erractionsave(err_act)
  debug_unit  = psb_get_debug_unit()
  debug_level = psb_get_debug_level()

  if(debug_level >= psb_debug_serial_) &
       & write(debug_unit,*)  trim(name),': start ',&
       & size(a%ia),size(a%ja)
  if (present(idir)) then 
    idir_ = idir
  else
    idir_ = 0
  endif

  nza = a%get_nzeros()
  if (nza < 2) return

  dupl_ = a%get_dupl()

  call c_fix_coo_inner(nza,dupl_,a%ia,a%ja,a%val,i,info,idir_)

  call a%set_sorted()
  call a%set_nzeros(i)
  call a%set_asb()
  

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)
  if (err_act == psb_act_abort_) then
    call psb_error()
    return
  end if
  return

end subroutine c_fix_coo_impl



subroutine c_fix_coo_inner(nzin,dupl,ia,ja,val,nzout,info,idir) 
  use psb_const_mod
  use psb_error_mod
  use psb_realloc_mod
  use psb_c_base_mat_mod, psb_protect_name => c_fix_coo_inner
  use psb_string_mod
  use psb_ip_reord_mod
  implicit none 
  
  integer, intent(in)           :: nzin, dupl
  integer, intent(inout)        :: ia(:), ja(:)
  complex(psb_spk_), intent(inout) :: val(:)
  integer, intent(out)          :: nzout, info
  integer, intent(in), optional :: idir
  !locals
  integer, allocatable :: iaux(:)
  Integer              :: nza, nzl,iret,idir_, dupl_
  integer              :: i,j, irw, icl, err_act
  integer              :: debug_level, debug_unit
  character(len=20)    :: name = 'psb_fixcoo'

  info  = 0

  call psb_erractionsave(err_act)
  debug_unit  = psb_get_debug_unit()
  debug_level = psb_get_debug_level()

  if(debug_level >= psb_debug_serial_) &
       & write(debug_unit,*)  trim(name),': start ',&
       & size(ia),size(ja)
  if (present(idir)) then 
    idir_ = idir
  else
    idir_ = 0
  endif


  if (nzin < 2) return

  dupl_ = dupl
  
  allocate(iaux(nzin+2),stat=info) 
  if (info /= 0) return


  select case(idir_) 

  case(0) !  Row major order

    call msort_up(nzin,ia(1),iaux(1),iret)
    if (iret == 0) &
         & call psb_ip_reord(nzin,val,ia,ja,iaux)
    i    = 1
    j    = i
    do while (i <= nzin)
      do while ((ia(j) == ia(i)))
        j = j+1
        if (j > nzin) exit
      enddo
      nzl = j - i
      call msort_up(nzl,ja(i),iaux(1),iret)
      if (iret == 0) &
           & call psb_ip_reord(nzl,val(i:i+nzl-1),&
           & ia(i:i+nzl-1),ja(i:i+nzl-1),iaux)
      i = j
    enddo

    i = 1
    irw = ia(i)
    icl = ja(i)
    j = 1

    select case(dupl_)
    case(psb_dupl_ovwrt_)

      do 
        j = j + 1
        if (j > nzin) exit
        if ((ia(j) == irw).and.(ja(j) == icl)) then 
          val(i) = val(j)
        else
          i = i+1
          val(i) = val(j)
          ia(i) = ia(j)
          ja(i) = ja(j)
          irw = ia(i) 
          icl = ja(i) 
        endif
      enddo

    case(psb_dupl_add_)

      do 
        j = j + 1
        if (j > nzin) exit
        if ((ia(j) == irw).and.(ja(j) == icl)) then 
          val(i) = val(i) + val(j)
        else
          i = i+1
          val(i) = val(j)
          ia(i) = ia(j)
          ja(i) = ja(j)
          irw = ia(i) 
          icl = ja(i) 
        endif
      enddo

    case(psb_dupl_err_)
      do 
        j = j + 1
        if (j > nzin) exit
        if ((ia(j) == irw).and.(ja(j) == icl)) then 
          call psb_errpush(130,name)          
          goto 9999
        else
          i = i+1
          val(i) = val(j)
          ia(i) = ia(j)
          ja(i) = ja(j)
          irw = ia(i) 
          icl = ja(i) 
        endif
      enddo
    case default
      write(0,*) 'Error in fix_coo: unsafe dupl',dupl_

    end select


    if(debug_level >= psb_debug_serial_)&
         & write(debug_unit,*)  trim(name),': end second loop'

  case(1) !  Col major order

    call msort_up(nzin,ja(1),iaux(1),iret)
    if (iret == 0) &
         & call psb_ip_reord(nzin,val,ia,ja,iaux)
    i    = 1
    j    = i
    do while (i <= nzin)
      do while ((ja(j) == ja(i)))
        j = j+1
        if (j > nzin) exit
      enddo
      nzl = j - i
      call msort_up(nzl,ia(i),iaux(1),iret)
      if (iret == 0) &
           & call psb_ip_reord(nzl,val(i:i+nzl-1),&
           & ia(i:i+nzl-1),ja(i:i+nzl-1),iaux)
      i = j
    enddo

    i = 1
    irw = ia(i)
    icl = ja(i)
    j = 1


    select case(dupl_)
    case(psb_dupl_ovwrt_)
      do 
        j = j + 1
        if (j > nzin) exit
        if ((ia(j) == irw).and.(ja(j) == icl)) then 
          val(i) = val(j)
        else
          i = i+1
          val(i) = val(j)
          ia(i) = ia(j)
          ja(i) = ja(j)
          irw = ia(i) 
          icl = ja(i) 
        endif
      enddo

    case(psb_dupl_add_)
      do 
        j = j + 1
        if (j > nzin) exit
        if ((ia(j) == irw).and.(ja(j) == icl)) then 
          val(i) = val(i) + val(j)
        else
          i = i+1
          val(i) = val(j)
          ia(i) = ia(j)
          ja(i) = ja(j)
          irw = ia(i) 
          icl = ja(i) 
        endif
      enddo

    case(psb_dupl_err_)
      do 
        j = j + 1
        if (j > nzin) exit
        if ((ia(j) == irw).and.(ja(j) == icl)) then 
          call psb_errpush(130,name)
          goto 9999
        else
          i = i+1
          val(i) = val(j)
          ia(i) = ia(j)
          ja(i) = ja(j)
          irw = ia(i) 
          icl = ja(i) 
        endif
      enddo
    case default
      write(0,*) 'Error in fix_coo: unsafe dupl',dupl_
    end select
    if (debug_level >= psb_debug_serial_)&
         & write(debug_unit,*)  trim(name),': end second loop'
  case default
    write(debug_unit,*) trim(name),': unknown direction ',idir_
  end select

  nzout = i 
  
  deallocate(iaux)

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)
  if (err_act == psb_act_abort_) then
    call psb_error()
    return
  end if
  return



end subroutine c_fix_coo_inner




subroutine c_mv_coo_to_coo_impl(a,b,info) 
  use psb_error_mod
  use psb_realloc_mod
  use psb_c_base_mat_mod, psb_protect_name => c_mv_coo_to_coo_impl
  implicit none 
  class(psb_c_coo_sparse_mat), intent(inout) :: a
  class(psb_c_coo_sparse_mat), intent(out) :: b
  integer, intent(out)            :: info

  Integer :: err_act
  character(len=20)  :: name='to_coo'
  logical, parameter :: debug=.false.


  call psb_erractionsave(err_act)
  info = 0
  call b%psb_c_base_sparse_mat%mv_from(a%psb_c_base_sparse_mat)
  call b%set_nzeros(a%get_nzeros())
  call b%reallocate(a%get_nzeros())

  call move_alloc(a%ia, b%ia)
  call move_alloc(a%ja, b%ja)
  call move_alloc(a%val, b%val)
  call a%free()

  call b%fix(info)

  if (info /= 0) goto 9999

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)

  call psb_errpush(info,name)

  if (err_act /= psb_act_ret_) then
    call psb_error()
  end if
  return

end subroutine c_mv_coo_to_coo_impl
  
subroutine c_mv_coo_from_coo_impl(a,b,info) 
  use psb_error_mod
  use psb_realloc_mod
  use psb_c_base_mat_mod, psb_protect_name => c_mv_coo_from_coo_impl
  implicit none 
  class(psb_c_coo_sparse_mat), intent(inout) :: a
  class(psb_c_coo_sparse_mat), intent(inout) :: b
  integer, intent(out)            :: info

  Integer :: err_act
  character(len=20)  :: name='from_coo'
  logical, parameter :: debug=.false.
  integer :: m,n,nz


  call psb_erractionsave(err_act)
  info = 0
  call a%psb_c_base_sparse_mat%mv_from(b%psb_c_base_sparse_mat)
  call a%set_nzeros(b%get_nzeros())
  call a%reallocate(b%get_nzeros())

  call move_alloc(b%ia , a%ia   )
  call move_alloc(b%ja , a%ja   )
  call move_alloc(b%val, a%val )
  call b%free()
  call a%fix(info)

  if (info /= 0) goto 9999

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)

  call psb_errpush(info,name)

  if (err_act /= psb_act_ret_) then
    call psb_error()
  end if
  return

end subroutine c_mv_coo_from_coo_impl


subroutine c_mv_coo_to_fmt_impl(a,b,info) 
  use psb_error_mod
  use psb_realloc_mod
  use psb_c_base_mat_mod, psb_protect_name => c_mv_coo_to_fmt_impl
  implicit none 
  class(psb_c_coo_sparse_mat), intent(inout) :: a
  class(psb_c_base_sparse_mat), intent(out) :: b
  integer, intent(out)            :: info

  Integer :: err_act
  character(len=20)  :: name='to_coo'
  logical, parameter :: debug=.false.


  call psb_erractionsave(err_act)
  info = 0

  call b%mv_from_coo(a,info)

  if (info /= 0) goto 9999

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)

  call psb_errpush(info,name)

  if (err_act /= psb_act_ret_) then
    call psb_error()
  end if
  return

end subroutine c_mv_coo_to_fmt_impl
  
subroutine c_mv_coo_from_fmt_impl(a,b,info) 
  use psb_error_mod
  use psb_realloc_mod
  use psb_c_base_mat_mod, psb_protect_name => c_mv_coo_from_fmt_impl
  implicit none 
  class(psb_c_coo_sparse_mat), intent(inout) :: a
  class(psb_c_base_sparse_mat), intent(inout) :: b
  integer, intent(out)            :: info

  Integer :: err_act
  character(len=20)  :: name='from_coo'
  logical, parameter :: debug=.false.
  integer :: m,n,nz


  call psb_erractionsave(err_act)
  info = 0

  call b%mv_to_coo(a,info)

  if (info /= 0) goto 9999

  call psb_erractionrestore(err_act)
  return

9999 continue
  call psb_erractionrestore(err_act)

  call psb_errpush(info,name)

  if (err_act /= psb_act_ret_) then
    call psb_error()
  end if
  return

end subroutine c_mv_coo_from_fmt_impl
