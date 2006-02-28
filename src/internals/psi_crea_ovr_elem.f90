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
subroutine psi_crea_ovr_elem(desc_overlap,ovr_elem)

  use psb_realloc_mod
  implicit none

  !     ...parameter arrays....      
  integer          :: desc_overlap(:)
  integer, pointer :: ovr_elem(:)
  !     ...local scalars...
  integer :: i,pnt_new_elem,ret,j, info
  integer :: dim_ovr_elem

  !     ...external function...
  integer  :: psi_exist_ovr_elem,dim
  external :: psi_exist_ovr_elem

  logical, parameter :: usetree=.true.

  dim_ovr_elem=size(ovr_elem)
  i=1
  pnt_new_elem=1
  if (usetree)   call initpairsearchtree(info)
  do while (desc_overlap(i).ne.-1)
     !        ...loop over all procs of desc_overlap list....

     i=i+1
     do j=1,desc_overlap(i)
        !           ....loop over all overlap indices referred to act proc.....
        if (usetree) then 
           call searchinskeyval(desc_overlap(i+j),pnt_new_elem,&
                & ret,info)
           if (ret == pnt_new_elem) ret=-1
        else
           ret=psi_exist_ovr_elem(ovr_elem,pnt_new_elem-2,&
                & desc_overlap(i+j))
        endif
        if (ret.eq.-1) then

           !            ...this point not exist in ovr_elem list:
           !               add to it.............................
           ovr_elem(pnt_new_elem)=desc_overlap(i+j)  
           ovr_elem(pnt_new_elem+1)=2             
           pnt_new_elem=pnt_new_elem+2              

           !              ...check if overflow element_d array......
           if (pnt_new_elem.gt.dim_ovr_elem) then
              dim_ovr_elem=(3*size(ovr_elem))/2+2
              write(0,*) 'calling realloc crea_ovr_elem',dim
              call psb_realloc(dim_ovr_elem,ovr_elem,info)
           endif
        else
           !              ....this point already exist in ovr_elem list
           !                  its position is ret............................
           ovr_elem(ret+1)=ovr_elem(ret+1)+1
        endif
     enddo
     i=i+2*desc_overlap(i)+2
  enddo

  !     ...add -1 at the end of output list......
  ovr_elem(pnt_new_elem)=-1
  if (usetree)   call freepairsearchtree()

end subroutine psi_crea_ovr_elem
