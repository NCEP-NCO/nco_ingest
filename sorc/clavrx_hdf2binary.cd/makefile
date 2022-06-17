##!/bin/sh
SHELL = /bin/sh

#Makefile 

#Location of HDF include files
HDFINC = ${HDF4_INCLUDES}

#Location of HDF libraries
HDFLIB = ${HDF4_LIBRARIES}

#Intel include
#INTELINC=${MKLROOT}/include

#Location of clavrx_data.h
CINC = ./

#LIBS = ${HDFLIB}/libmfhdf.a ${HDFLIB}/libdf.a ${Z_LIB}
#CC = cc -g -ansi -D_BSD_SOURCE -I${INTELINC} -I${HDFINC} -I${CINC} -Xlinker --start-group -L${HDFLIB} --end-group

LIBS = -lmfhdf -ldf -ljpeg -lz
CC = cc -g -ansi -I${HDFINC} -I${CINC} -Xlinker -L${HDFLIB}

OBJECTS =clavrx_hdf2binary.o \
	 read_clavrx_hdf.o \
	 print_err_msg.o 	 

CMD = clavrx_hdf2binary	 

clavrx_hdf2binary: $(OBJECTS)
	$(CC) -o $@ $(OBJECTS) ${LIBS}
	
clavrx_hdf2binary.o: clavrx_hdf2binary.c
	$(CC) -c clavrx_hdf2binary.c
	
read_clavrx_hdf.o: read_clavrx_hdf.c
	$(CC) -c read_clavrx_hdf.c
	
print_err_msg.o: print_err_msg.c
	$(CC) -c print_err_msg.c		

clean:
	rm -f $(OBJECTS)

install:
	cp $(CMD) ../../exec/$(CMD)
