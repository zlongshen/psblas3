C
C             Parallel Sparse BLAS  version 2.2
C   (C) Copyright 2006/2007/2008
C                      Salvatore Filippone    University of Rome Tor Vergata
C                      Alfredo Buttari        University of Rome Tor Vergata
C
C Redistribution and use in source and binary forms, with or without
C modification, are permitted provided that the following conditions
C are met:
C   1. Redistributions of source code must retain the above copyright
C      notice, this list of conditions and the following disclaimer.
C   2. Redistributions in binary form must reproduce the above copyright
C      notice, this list of conditions, and the following disclaimer in the
C      documentation and/or other materials provided with the distribution.
C   3. The name of the PSBLAS group or the names of its contributors may
C      not be used to endorse or promote products derived from this
C      software without specific written permission.
C
C THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
C ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
C TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
C PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE PSBLAS GROUP OR ITS CONTRIBUTORS
C BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
C CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
C SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
C INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
C CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
C ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
C POSSIBILITY OF SUCH DAMAGE.
C
C 
      SUBROUTINE DCRCO(TRANS,M,N,UNITD,D,DESCRA,AR,IA1,IA2,INFO,
     *   IP1,DESCRN,ARN,IAN1,IAN2,INFON,IP2,LARN,LIAN1,
     *   LIAN2,AUX,LAUX,IERROR)

      use psb_const_mod
      use psb_spmat_type
      use psb_string_mod
      use psb_error_mod
      IMPLICIT NONE

C
C     .. Scalar Arguments ..
      INTEGER            LARN, LAUX, LIAN1, LIAN2, M, N, IERROR
      CHARACTER          TRANS,UNITD
C     .. Array Arguments ..
      DOUBLE PRECISION   AR(*), ARN(*), D(*), AUX(LAUX)
      INTEGER            IA1(*), IA2(*), INFO(*), IAN1(*), IAN2(*),
     *   INFON(*), IP1(*), IP2(*)
      CHARACTER          DESCRA*11, DESCRN*11
C     .. Local Scalars ..
      INTEGER            NNZ, K, ROW, J
      INTEGER            ELEM, ERR_ACT
      LOGICAL            SCALE
      INTEGER MAX_NNZERO
c     .. Local Arrays ..
      CHARACTER*20       NAME
      INTEGER            INT_VAL(5)
      integer              :: debug_level, debug_unit
C     .. External Subroutines ..
      EXTERNAL           MAX_NNZERO
C     .. Executable Statements ..
C

      NAME = 'DCRCO'
      IERROR = 0
      CALL FCPSB_ERRACTIONSAVE(ERR_ACT)
      debug_unit  = psb_get_debug_unit()
      debug_level = psb_get_debug_level()

      IF (toupper(TRANS).EQ.'N') THEN
         SCALE  = (toupper(UNITD).EQ.'L') ! meaningless
         IP1(1) = 0
         IP2(1) = 0
         NNZ = IA2(M+1)-1
         if (debug_level >= psb_debug_serial_)
     +     write(debug_unit,*) trim(name),': entry',m,n,nnz,
     +     ' : ',descra,' : ',descrn

         IF (LARN.LT.NNZ) THEN
          IERROR = 60
          INT_VAL(1) = 18
          INT_VAL(2) = NNZ
          INT_VAL(3) = LARN
         ELSE IF (LIAN1.LT.NNZ) THEN
          IERROR = 60
          INT_VAL(1) = 19
          INT_VAL(2) = NNZ
          INT_VAL(3) = LIAN1
         ELSE IF (LIAN2.LT.NNZ) THEN
          IERROR = 60
          INT_VAL(1) = 20
          INT_VAL(2) = NNZ
          INT_VAL(3) = LIAN2
         ENDIF
         
         IF(IERROR.NE.0) THEN
            CALL FCPSB_ERRPUSH(IERROR,NAME,INT_VAL)
            GOTO 9999
         END IF
         
         IF (toupper(DESCRA(1:1)).EQ.'G') THEN
C        ... Construct COO Representation...
            ELEM = 0

            DO ROW = 1, M
               DO J = IA2(ROW), IA2(ROW+1)-1
                  ELEM = ELEM + 1
                  IAN1(ELEM) = ROW
                  IAN2(ELEM) = IA1(J)
                  ARN(ELEM) = AR(J)
               ENDDO
            ENDDO
            INFON(psb_nnz_) = elem

            if (debug_level >= psb_debug_serial_)
     +        write(debug_unit,*)  trim(name),': endloop',m,elem

         ELSE IF (toupper(DESCRA(1:1)).EQ.'S' .AND.
     +        toupper(DESCRA(2:2)).EQ.'U') THEN

            DO 20 K = 1, M
               IP2(K) = K
 20         CONTINUE

            ierror = 3021
            call fcpsb_errpush(ierror,name,int_val)
            goto 9999
c$$$            CALL DVSSG(M,IA1,IA2,IP2,IAN2(PNG),IP1,IP2,AUX(IWLEN),
c$$$     *                 AUX(IWORK1))
c$$$            CALL DVSMR(M,AR,IA1,IA2,IAN2(PNG),AUX(IWLEN),IP1,IP2,
c$$$     *                 IAN2(PIA),IAN2(PJA),IAN1,ARN,AUX(IWORK1),
c$$$     *                 AUX(IWORK2),NJA,IER,SCALE)
C
         ELSE IF (toupper(DESCRA(1:1)).EQ.'T' .AND.
     +        toupper(DESCRA(2:2)).EQ.'U') THEN
           ierror = 3021
           call fcpsb_errpush(ierror,name,int_val)
           goto 9999

c$$$            CALL DVTFG('U',M,IA1,IA2,IAN2(PNG),IP1,IP2,AUX(IWLEN),
c$$$c    *                 AUX(IWORK1),AUX(IWORK2),IAN1(M+1))
c$$$     *                 AUX(IWORK1),IAN1(1),IAN1(M+5))
c$$$            CALL DVTMR(M,AR,IA1,IA2,ISTROW,IAN2(PNG),AUX(IWLEN),IP1,IP2,
c$$$     *                 IAN2(PIA),IAN2(PJA),IAN1,ARN,NJA,IER,SCALE)
C

         ELSE IF (toupper(DESCRA(1:1)).EQ.'T' .AND.
     +       toupper(DESCRA(2:2)).EQ.'L') THEN
           ierror = 3021
           call fcpsb_errpush(ierror,name,int_val)
           goto 9999

c$$$            CALL DVTFG('L',M,IA1,IA2,IAN2(PNG),IP1,IP2,AUX(IWLEN),
c$$$c     *                 AUX(IWORK1),AUX(IWORK2),IAN1(M+1))
c$$$     *                 AUX(IWORK1),IAN1(1),IAN1(M+5))
c$$$            CALL DVTMR(M,AR,IA1,IA2,ISTROW,IAN2(PNG),AUX(IWLEN),IP1,IP2,
c$$$     *                 IAN2(PIA),IAN2(PJA),IAN1,ARN,NJA,IER,SCALE)
         else
           ierror = 3021
           call fcpsb_errpush(ierror,name,int_val)
           goto 9999

         END IF
C
      ELSE IF (toupper(TRANS).NE.'N') THEN
C
C           TO DO
C     
         IERROR = 3021
         CALL FCPSB_ERRPUSH(IERROR,NAME,INT_VAL)
         GOTO 9999
       else
         ierror = 3021
         call fcpsb_errpush(ierror,name,int_val)
         goto 9999


      END IF

      CALL FCPSB_ERRACTIONRESTORE(ERR_ACT)
      RETURN

 9999 CONTINUE
      CALL FCPSB_ERRACTIONRESTORE(ERR_ACT)

      IF ( ERR_ACT .NE. 0 ) THEN 
         CALL FCPSB_SERROR()
         RETURN
      ENDIF

      RETURN
      END
