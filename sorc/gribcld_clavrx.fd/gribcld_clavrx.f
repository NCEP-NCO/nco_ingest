C.       ********************************************************
C.....   *      READ CLAVRx 0.5 degree archive data             *
c        * 15 records in the order described by LABL below      *
c>>>>>>  *     data point (1,1) is 0.25 EAST, 89.75-deg SOUTH   *
c        *       I=1 is near Greenwich (0.25E) going eastward   *
c        *       I=720 is near Greenwich (0.25W)                *
c        *       J=1 is for 89.75S lat                          *
c        *       J=360 is for 89.75N lat                        *
C        * GRID FLIPPED BEFORE archiving, so J=1 is 89.75N      *
C.       ********************************************************
c        *  NESDIS CLAVRx cloud data; -999=missing - Jul 2004   *
c        *    grib all except day and year,                     * 
c        *    THIS will be the NCEP archive !!                  *
C.       ********************************************************
c        *  log10 scaling of the 'hdf' data has been removed by *
c        *   the 'C' job, clavrx_hdf2binary                     *
c        *    for optical depth, particle size, LWP and IWP     *
C.       ********************************************************
      PARAMETER (IIAF=720,JJAF=360,IIJJ=IIAF*JJAF)
      DIMENSION CLD(IIJJ)
      DIMENSION clvrx(IIAF,JJAF)
      DIMENSION CLV(IIAF,JJAF)
CC     DIMENSION CLVXX(IIAF,JJAF,13)
      CHARACTER*1 INUM(10),lbly2k(22)
      DIMENSION JMON(12),NSYNOP(4)
      CHARACTER*12 LBL,LABL(15)
      DATA LABL /'..time...   ','.Day-of-yr. ',' ...year..  ',
     1           'Total cloud ','Water cloud ','ICE cloud   ',
     2           'Low cloud   ','Middl cloud ','High cloud  ',
     3           'Cld Temp    ','Cld emissiv ','-opticl dpth',
     4           'particl size','  - LWP -   ','  - IWP -   '/
      DATA JMON/31,28,31,30,31,30,31,31,30,31,30,31/
      DATA NSYNOP/0,6,12,18/
      DATA INUM/'1','2','3','4','5','6','7','8','9','0'/
      data (lbly2k(k),k=1,22)/
     1    'y','y','y','y','m','m','d','d','h','h',' ',' ',
     2    '0','0','0','0','0','0','0','0','0','0'/
C----    ************************************************************
c..      *   updated for the ibm...need to connect the script name  *
c        *     and iout so that baopen can work properly            *
c        ------------------------------------------------------------
c        *   use Fortran DIRECT ACCESS reads for input file         *
c        --------------------------------------------------------------
      DIMENSION IDATE(5)
      LOGICAL*1 LBMS(IIAF,JJAF)
cibmspecial
      character *2 ciu
      character*80 fname
cibmspecial
C....    BEGIN HERE ....
      imax = IIAF
      jmax = JJAF
      kf = IIJJ
      NB = IIJJ*4
      itp = 10
      OPEN(itp,STATUS="OLD",ACCESS="DIRECT",RECL=NB)
      iout = 70
cibmspecial
C  --- >     for OUTPUT
c..         put unit number (I2) into character*2
       write (ciu,'(i2)') iout
c..         get the script name for FORT'iout', by inserting the
c           numerical value of iout (adjustleft to remove blanks).
c           Place in character*80, fname...(e.g.FORT70)
       call get_environment_variable('FORT'//adjustl(ciu),fname)
c..         open the unit...using internal declaration (iout) and
c           script declaration (fname, which has blanks trimmed out)
       call baopen(iout,trim(fname),iret)
c         is needed for index file if its available externally., BUT
c         the index is created internally (IDX=0)
cibmspecial
      DO 55 nfile=1,3
        lbl=labl(nfile)
c     missing = negative values
c====>   NOW -999. for all variables
        READ (itp,REC=nfile) clvrx
        if (nfile.eq.1) then
         cmx = -1.e20
         cmn = 1.e20
         imx = 0
         jmx = 0
         imn = 0
         jmn = 0
         do j=1,JJAF
          do i=1,IIAF
c  ...   use the max/min of obs hour to get the 
c         valid synoptic hour
c         skip the missing data points!
           if (clvrx(i,j).gt.-99.) then
            if (clvrx(i,j).gt.cmx) then
             cmx=clvrx(i,j)
             imx = i
             jmx = j
            end if
            if (clvrx(i,j).lt.cmn) then
             cmn=clvrx(i,j)
             imn = i
             jmn = j
            end if
           end if
          end do
         end do
         print 1006
         print 1001,lbl
         print *,'MAX,i,j =   ',cmx,imx,jmx
         print *,'MIN,i,j =   ',cmn,imn,jmn
c...  determine the synoptic hour from the time of obs 
c      information (hours) in the first record.  If 
c      we have good data, then the algorithm, below, which uses
c      the above calculations of max/min of the 'time', will 
c      get the proper synoptic hour.  Note that it is hardwired 
c      for a 3-hour time window; plus/minus 1.5 hrs (xdt). 
C.... FIRST: initialize the synoptic hour as 99Z
         ihr = 99
c....  special case #1
c       The algorithm below had occassional trouble with 0Z, so simply
c        look for a max value of orbital time .gt. 23 hours
         if (cmx.ge.23.) then 
          ihr = 0
          go to 8
         end if
c...  obs time is within plus/minus 1.5 hrs
         xdt = 1.5
         synopx = cmx - xdt + 0.5
         synopn = cmn + xdt + 0.5
         isynx = synopx
         isynn = synopn
         if (isynx.eq.isynn) then
C...  max and min time are the same, so this is the value for the 
C        synoptic time (truncate number via use of integer storage).
          ihr = synopx
         else
c....  special case #2
c...  if a lot of missing data, then there may not be sufficient 
c      data to show max=synop+xdt or min=synop-xdt.  So be careful
c      with the logic:
c       In usual situations the difference between max and min values 
c        of 'time' will be approx 2*xdt (3 hour window) and synopx and
c        synopn will be equal.  However, for rare situations
c        when there is a great deal of missing orbital data, 
c        isynx may not equal isynn.  In fact there was a 12Z case where 
c        isynx=12 and isynn=14.  For these cases, one could   
c        declare the gridded data to be no good and give a synoptic
c        time of 99Z.  But, in an attempt to pick the proper time, 
c        compare the max and/or min to one of the hardwired synoptic
c        times:
          do kkt=2,4
           if (isynx.eq.nsynop(kkt)) then
             ihr = nsynop(kkt)
             go to 8
           end if
          end do         
          do kkt=2,4
           if (isynn.eq.nsynop(kkt)) then
             ihr = nsynop(kkt)
             go to 8
           end if
          end do
         end if
    8    print *,'synoptic hour = ',ihr
        end if
        if (nfile.eq.2) then
         cmx = -1.e20
         cmn = 1.e20
         imx = 0
         jmx = 0
         imn = 0
         jmn = 0
         do j=1,JJAF
          do i=1,IIAF
c  ...   for 00Z synoptic hour, need to worry about 2 diff da!
c         SO use the max of day  (for the other times max=min)
c         skip the missing data points!
           if (clvrx(i,j).gt.0.) then
            if (clvrx(i,j).gt.cmx) then
             cmx=clvrx(i,j)
             imx = i
             jmx = j
            end if
            if (clvrx(i,j).lt.cmn) then
             cmn=clvrx(i,j)
             imn = i
             jmn = j
            end if
           end if
          end do
         end do
         print 1006
         print 1001,lbl
         print *,'MAX,i,j =   ',cmx,imx,jmx
         print *,'MIN,i,j =   ',cmn,imn,jmn
         ida = cmx + 0.1
        end if
        if (nfile.eq.3) then
         cmx = -1.e20
         cmn = 1.e20
         imx = 0
         jmx = 0
         imn = 0
         jmn = 0
         do j=1,JJAF
          do i=1,IIAF
c  ...   for 00Z synoptic hour, need to worry about 2 diff 
c         years at the end of the year!
c      SO use the max of year (for the other times max=min)
c      + skip the missing data points!
           if (clvrx(i,j).gt.0.) then
            if (clvrx(i,j).gt.cmx) then
             cmx=clvrx(i,j)
             imx = i
             jmx = j
            end if
            if (clvrx(i,j).lt.cmn) then
             cmn=clvrx(i,j)
             imn = i
             jmn = j
            end if
           end if
          end do
         end do
         print 1006
         print 1001,lbl
         print *,'MAX,i,j =   ',cmx,imx,jmx
         print *,'MIN,i,j =   ',cmn,imn,jmn
         iyr = cmx + 0.1
        end if
   55 continue
      iolabl=60
      PRINT 293,IDA,IYR
c....   get the month and day of the month from the dayofyear..
c         crude account taken of leap days
      mday=ida
      mmn=1
      mdy=mday
      if (mday.gt.31) then
       nstart=31
       do 210 j=2,12
        jm=j
        lmon=jmon(j)
        if (iyr.eq.1984.and.j.eq.2) lmon=29
        if (iyr.eq.1988.and.j.eq.2) lmon=29
        if (iyr.eq.1992.and.j.eq.2) lmon=29
        if (iyr.eq.1996.and.j.eq.2) lmon=29
        if (iyr.eq.2000.and.j.eq.2) lmon=29
        if (iyr.eq.2004.and.j.eq.2) lmon=29
        if (iyr.eq.2008.and.j.eq.2) lmon=29
        if (iyr.eq.2012.and.j.eq.2) lmon=29
        nstart=nstart+lmon
        if (mday.le.nstart) then
         mmn=jm
         mdy=mday-(nstart-lmon)
         go to 220
        end if
  210  continue
c...  bad month
       mmn=99
       mdy=99
  220  continue
      end if
c....  create 4-digit year
cc      my2k = 2000+IYR
cc      if (IYR.gt.50) my2k=1900+IYR
      my2k = iyr
      nzt = ihr
      print 294, mdy,mmn,my2k,nzt
      do 7077 kt=13,22
       lbly2k(kt)=inum(10)
 7077 continue
c....create 4 digit year for data
      nthou=  my2k/1000
      nhun = (my2k-1000*nthou)/100
      nten = (my2k-1000*nthou-100*nhun)/10
      none =  my2k-1000*nthou-100*nhun-10*nten
      do 7177 kt=1,9
       if (nthou.eq.kt) then
        lbly2k(13)=inum(kt)
       end if
       if (nhun.eq.kt) then
        lbly2k(14)=inum(kt)
       end if
       if (nten.eq.kt) then
        lbly2k(15)=inum(kt)
       end if
       if (none.eq.kt) then
        lbly2k(16)=inum(kt)
       end if
 7177 continue
      mten=mmn/10
      mone=mmn-10*mten
      do 72 kt=1,9
       if (mten.eq.kt) then
        lbly2k(17)=inum(kt)
       end if
       if (mone.eq.kt) then
        lbly2k(18)=inum(kt)
       end if
   72 continue
      mten=mdy/10
      mone=mdy-10*mten
      do 73 kt=1,9
       if (mten.eq.kt) then
        lbly2k(19)=inum(kt)
       end if
       if (mone.eq.kt) then
        lbly2k(20)=inum(kt)
       end if
   73 continue
      mten=nzt/10
      mone=nzt-10*mten
      do 74 kt=1,9
       if (mten.eq.kt) then
        lbly2k(21)=inum(kt)
       end if
       if (mone.eq.kt) then
        lbly2k(22)=inum(kt)
       end if
   74 continue
      print 1747,(lbly2k(kt),kt=1,22)
 1747     format('  labelY2K=',22a1)
      write (iolabl,7677) (lbly2k(kt),kt=1,22)
 7677 format(22a1)
      IDATE(1) = nzt
      IDATE(2) = mmn
      IDATE(3) = mdy
      kyr = my2k
c...   get year of century and century for grib...
      ICENT = KYR/100 + 1
      II = MOD(KYR,100)
      IF (II.EQ.0) ICENT=ICENT-1
      KY = KYR - (ICENT-1)*100
      IDATE(4) = KY
      IDATE(5) = ICENT
CCC      lparam=0
      DO 1000 nfile=1,15
c...   skip the day and year files
        if (nfile.ge.2.and.nfile.le.3) go to 1000
CCC        lparam=lparam+1
c     missing = negative values 
c      -99./-32768./-999.for time/dy+yr/rest
c====>   NOW -999. for all variables
        READ (itp,REC=nfile) clvrx
        lbl=labl(nfile)
        cmx = -1.e20
        cmn = 1.e20
        imx = 0
        jmx = 0
        imn = 0
        jmn = 0
        do j=1,JJAF
         do i=1,IIAF
CCC          CLVXX(i,j,lparam) = clvrx(i,j)
c=====   skip the missing data points!
          if (clvrx(i,j).gt.-99.) then
           if (clvrx(i,j).gt.cmx) then
            cmx=clvrx(i,j)
            imx = i
            jmx = j
           end if
           if (clvrx(i,j).lt.cmn) then
            cmn=clvrx(i,j)
            imn = i
            jmn = j
           end if
          end if
         end do
        end do
        print 1006
        print 1001,lbl
        print *,'MAX,i,j =   ',cmx,imx,jmx
        print *,'MIN,i,j =   ',cmn,imn,jmn
        nmiss = 0
        do j=1,JJAF
         do i=1,IIAF
          if (clvrx(i,j).le.-999.) then
           nmiss=nmiss+1
          end if
         end do
        end do
        print *,'totpts,numpts missing =',IIJJ,nmiss
c..  convert to desired units .. AND
CCCC       if (nfile.ge.12) then
c..      take antilog10 for
c          optical  depth (12) and
c          effective particle radius (13)
c          LWP/IWP (14/15)
CCCC        do j=1,JJAF
CCCC         do i=1,IIAF
CCCC          if (clvrx(i,j).le.-999.) then
CCCC           CLV(i,j) = clvrx(i,j)
CCCC          else
CCCC           CLV(i,j) = 10.**clvrx(i,j)
c... good data back to clvrx so scaling works for 14/15
CCCC           clvrx(i,j) = CLV(i,j)
CCCC          end if
CCCC         end do
CCCC        end do
CCCC       end if
       scal = 1.
       if (nfile.eq.1) scal=3600.
       if (nfile.ge.4.AND.nfile.le.9) scal=100.
       if (nfile.ge.14) scal=0.001
       do j=1,JJAF
        do i=1,IIAF
         if (clvrx(i,j).gt.-999.) then
          CLV(i,j) = clvrx(i,j)*scal
         else
          CLV(i,j) = clvrx(i,j)
         end if
        end do
       end do
       nmiss=0
       do j=1,JJAF
c          flip grid so that j=1 is near North Pole
        jnu = JJAF+1 - j
        do i=1,IIAF
         clvrx(i,jnu) = CLV(i,j)
         if (clvrx(i,jnu).le.-999.) then 
          nmiss=nmiss+1
         end if
c...   leave all data as .true. 
c         cause using the .FALSE. gave me no known 'grads' way
c         to color missings as black.
         LBMS(I,JNU) = .TRUE.
        end do
       end do
        cmx = -1.e20
        cmn = 1.e20
        imx = 0
        jmx = 0
        imn = 0
        jmn = 0
        do j=1,JJAF
         do i=1,IIAF
c=====   skip the missing data points!
          if (clvrx(i,j).gt.-999.) then
           if (clvrx(i,j).gt.cmx) then 
            cmx=clvrx(i,j)
            imx = i
            jmx = j
           end if
           if (clvrx(i,j).lt.cmn) then
            cmn=clvrx(i,j)
            imn = i
            jmn = j
           end if
          end if
         end do
        end do
        print 1005
        print 1001,lbl
        print *,'MAX,i,j =   ',cmx,imx,jmx
        print *,'MIN,i,j =   ',cmn,imn,jmn
        print *,'totpts,numpts missing =',IIJJ,nmiss
c....    Grib the data
        call grbcld(clvrx,LBMS,IDATE,nfile,iout)
 1000 CONTINUE
      close (itp)
      close (iout)
cibmspecial
       call baclose(iout,iret)
cibmspecial
      STOP
 1005 format(1h ,'--------------')
 1006 format(1h ,'***************')
 1001 format(1h ,'...unloaded.. ',a12,'...data')
 2001 format(1h ,'...obs time (GMT)...........data')
  293 format('  day=',i5,'  year=',i5)
  294 format(' computed day,mon,year,hour=',4i6)
      END
      SUBROUTINE GRBCLD(cld,lbms,IDATEN,ktype,iunit)
C
C$$$  SUBPROGRAM DOCUMENTATION BLOCK
C                .      .    .                                       .
C SUBPROGRAM:   GRBCLD      ENCODES USAF RT CLOUD ANALYSIS IN GRIB
C   PRGMMR: KENNETH CAMPANA   ORG: W/NMC23    DATE: 99-12-29
C
C ABSTRACT: CONVERTS TO GRIB FORMAT THE CONTENTS OF INPUT ARRAY
C
C PROGRAM HISTORY LOG:
C   99-12-29  KENNETH CAMPANA 
C
C USAGE:   CALL GRBCLD(cld,IDATEN,ktype,lbms,IUNIT)
C
C   INPUT ARGUMENT LIST:
C     cld        - GLOBAL .5DEG CLOUD (fraction)...floating point
C     lbms       - GLOBAL .5DEG CLOUD (cld bit map, missing=false)
C     IDATEN     - DATE FOR WHICH ANALYSIS IS VALID
c     ktype      - cloud type ... 
C     IUNIT      - Output unit
C
C   OUTPUT ARGUMENT LIST:
C              - NONE -
C
C ATTRIBUTES:
C   LANGUAGE: FORTRAN -77
C   MACHINE:  CRAY 4
C
C$$$
      PARAMETER (JF=720*360)
      DIMENSION cld(720,360)
      DIMENSION IDATEN(5)
c....   ipds(25),igds(22) is what fi63 uses
      INTEGER IPDS(25),IGDS(22)
      LOGICAL*1 LBMS(JF)
C
c.......set ipds,igds to fi63 convention..change to fi72 convention
c           done in putgb..
c...    for more info, review $HOME/archive/gribcld_1dg.f
c....   ktype=1,4-15 for 
c         time,total,water,ice cloud,
c         l,m,h clouds,
c         cld temp,emissiv,optdpth,
c         eff particle size,LWP,IWP
      ITYPE=200
      if (ktype.eq.7) ITYPE=214
      if (ktype.eq.8) ITYPE=224
      if (ktype.eq.9) ITYPE=234
      IPARAM=71
      if (ktype.eq.1) IPARAM=172
      if (ktype.eq.5) IPARAM=146
      if (ktype.eq.6) IPARAM=147
cc      if (ktype.eq.7) IPARAM=73
      if (ktype.eq.7) IPARAM=71
cc      if (ktype.eq.8) IPARAM=74
      if (ktype.eq.8) IPARAM=71
cc      if (ktype.eq.9) IPARAM=75
      if (ktype.eq.9) IPARAM=71
      if (ktype.eq.10) IPARAM=11
      if (ktype.eq.11) IPARAM=143
      if (ktype.eq.12) IPARAM=144
      if (ktype.eq.13) IPARAM=145
      if (ktype.eq.14) IPARAM=136
      if (ktype.eq.15) IPARAM=137
      IPDS(1)=7
      IPDS(2)=0
      IPDS(3)=255
c...   yes GDS and yes BITMAP included....11000000 = 192
      IPDS(4)=192
      IPDS(5)=IPARAM
      IPDS(6)=ITYPE
      IPDS(7)=0
      IPDS(8)=IDATEN(4)
      IPDS(9)=IDATEN(2)
      IPDS(10)=IDATEN(3)
      IPDS(11)=IDATEN(1)
      IPDS(12)=0
      IPDS(13)=1
      IPDS(14)=0
      IPDS(15)=0
      IPDS(16)=0
      IPDS(17)=0
      IPDS(18)=0
C...   parameter table version...Table 129 if new satellite
c       variables (IPARAM gt 128)
CC      IPDS(19)=0
      IPDS(19)=2
      if (IPARAM.gt.128) IPDS(19) = 129
CC      IPDS(19)=129
      IPDS(20)=-100
      IPDS(21)=IDATEN(5)
      IPDS(22)=1
c...EMC sub center
      IPDS(23)=4
      IPDS(24)=0
      IPDS(25)=0
C
      IGDS(1)=0
      IGDS(2)=720
      IGDS(3)=360
C    before 8/4/04 
c        IGDS(4)=90000
c        IGDS(5)=0
c        IGDS(7)=-90000
c        IGDS(8)=0
      IGDS(4)=89750
      IGDS(5)=250
      IGDS(6)=128
      IGDS(7)=-89750
      IGDS(8)=359750
      IGDS(9)=500
      IGDS(10)=500
      IGDS(11)=0
      IGDS(12)=0
      IGDS(13)=0
      IGDS(14)=0
      IGDS(15)=0
      IGDS(16)=0
      IGDS(17)=0
      IGDS(18)=0
      IGDS(19)=0
      IGDS(20)=255
      IGDS(21)=0
      IGDS(22)=0
C
C... WRITE OUT CLOUD parameter...
      CALL PUTGB(IUNIT,JF,IPDS,IGDS,LBMS,cld,IRET)
      IF(IRET.NE.0) PRINT *,' ERROR IN PUTGB-CLOUD IRET= ',IRET
C
      RETURN
      END
