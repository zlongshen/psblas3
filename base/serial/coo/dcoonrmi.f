C
C             Parallel Sparse BLAS  v2.0
C   (C) Copyright 2006 Salvatore Filippone    University of Rome Tor Vergata
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
C     ... Compute Infinity norm for sparse matrix in CSR Format ...
      DOUBLE PRECISION FUNCTION DCOONRMI(TRANS,M,N,DESCRA,A,IA1,IA2,
     +   INFOA,IERROR)
      IMPLICIT NONE
C     .. Scalar Arguments ..
      INTEGER           M,N, IERROR
      CHARACTER         TRANS
C     .. Array Arguments ..
      INTEGER           IA1(*),IA2(*),INFOA(*)
      CHARACTER         DESCRA*11
      DOUBLE PRECISION  A(*)
C     .. Local scalars ..
      INTEGER I, J, K, NNZ
      DOUBLE PRECISION NRMI, SUM

      IERROR=0
      NRMI = 0.0
      NNZ  = INFOA(1)
      I    = 1
      J    = I
      DO WHILE (I.LE.NNZ)

        DO WHILE ((IA1(J).EQ.IA1(I)).AND.
     +     (J.LE.NNZ))
          J = J+1
        ENDDO
        
        SUM = 0.0
        DO K = I, J-1
          SUM = SUM + ABS(A(K))
        ENDDO        
        IF (SUM.GT.NRMI) THEN
          NRMI = SUM
        ENDIF
        I = J 
      ENDDO

      DCOONRMI = NRMI
      END