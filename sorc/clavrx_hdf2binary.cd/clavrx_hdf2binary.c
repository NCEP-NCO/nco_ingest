/**********************************************************************
**This routine reads a list of CLAVR-x HDF SDS names from
**"clavrx_hdf2binary_input." Those SDS's are then read from a CLAVR-x hdf file
**which is specified on the command line and output to a binary file
**as 32 bit floats in the order in which they are listed in 
**"clavrx_hdf2binary_input."
**
**INPUT:
**  hdf_name: the complete hdf filename
**
** USAGE:
**  ./clavrx_hdf2binary clavrx_n12_asc_05_0_1996_183.cell.hdf
**
** NEEDED SUBROUTINES and LIBRARIES:
**  read_clavrx_hdf.c
**  print_err_msg.c
**  clavrx_data.h
**
** AUTHOR:
**  Michael J. Pavolonis, CIMSS/SSEC/UW-Madison
***********************************************************************/

#include <hdf.h>
#include "clavrx_data.h"

main (argc, argv)

int
 argc;
 
char
 **argv;
 
{

  char8
   input_name[MAX_NC_NAME],
   hdf_name[MAX_NC_NAME],
   sds_name[MAX_NC_NAME],
   binary_name[MAX_NC_NAME],
   line[MAX_NC_NAME];
   
  char8
   *fcheck;
   
  int32
   sd_id,
   sds_index,
   status,
   n;
   
  float32
    *f32_buf;
   
  var_info
   f;
   
  FILE
   *fp_in,
   *fp_out;
   
  /*----------------------------------------------------------------------------
    Check for proper usage.
  ----------------------------------------------------------------------------*/  
  
  if (argc != 2) {
    printf("\nUSAGE: ./clavrx_hdf2binary hdf_name\n\n");
    exit(1);
  }
  
  strcpy(hdf_name,argv[1]);
  strcpy(input_name,"clavrx_hdf2binary_input");
  
  printf("\n*****CLAVRX_HDF2BINARY - %s*****\n\n",hdf_name);
  
  /*----------------------------------------------------------------------------
    Check to make sure an hdf file was specified.
  ----------------------------------------------------------------------------*/
  
  fcheck = strstr(hdf_name,".hdf");
  if (fcheck == NULL) {
    printf("\nFile name does not end in .hdf-exiting.\n\n");
    exit(1);
  }
  
  /*----------------------------------------------------------------------------
    Open the hdf, input, and output files.
  ----------------------------------------------------------------------------*/
  
  sd_id = SDstart(hdf_name, DFACC_READ);
  if (sd_id == FAIL) {
    printf("\nERROR: Invalid HDF file: %s\n\n", hdf_name);
    exit (1);
  }
  
  fp_in = fopen(input_name, "r");
  
  strncpy(binary_name,hdf_name,strlen(hdf_name)-3);
  for (n=strlen(hdf_name)-3; n<strlen(binary_name)-1; n++) binary_name[n] = '\0';
  sprintf(binary_name,"%sbin",binary_name);
  
  fp_out = fopen(binary_name, "w");
  
  /*----------------------------------------------------------------------------
    Loop through each SDS listed in the input file.
  ----------------------------------------------------------------------------*/
  
  while(!feof(fp_in)) {
    
    /*----------------------------------------------------------------------------
      Read in the current SDS name.
    ----------------------------------------------------------------------------*/
    
    fscanf(fp_in,"%s",sds_name);
    if (fp_in == NULL)  {
      printf( "\nThere is an error reading %s-exiting.\n\n",input_name);
      exit (1);
    }
    
    if (feof(fp_in)) break;
  
    /*----------------------------------------------------------------------------
      Read in the SDS from the HDF file.
    ----------------------------------------------------------------------------*/
    
    sds_index = SDnametoindex(sd_id,sds_name);
    print_err_msg(sds_name,"SDnametoindex",sd_id,sds_index);
    read_clavrx_hdf(sd_id,sds_index,&f,1);  
  
    /*----------------------------------------------------------------------------
      Write the current SDS as a 32 bit float to a binary file.
    ----------------------------------------------------------------------------*/
    
    printf("Writing SDS %s to %s...\n\n",sds_name,binary_name);
    
    switch (f.unscaled_type) {
      case DFNT_INT8:
        f32_buf = (float32 *) malloc(f.ncells*sizeof(float32));
	for (n=0; n<f.ncells; n++) f32_buf[n] = (float32) f.i8_unscaled[n];
	fwrite(f32_buf, sizeof(float32), f.ncells, fp_out);
        free(f.i8_unscaled);
	free(f32_buf);
        break;
      case DFNT_INT16:
        f32_buf = (float32 *) malloc(f.ncells*sizeof(float32));
	for (n=0; n<f.ncells; n++) f32_buf[n] = (float32) f.i16_unscaled[n];
	fwrite(f32_buf, sizeof(float32), f.ncells, fp_out);
        free(f.i16_unscaled);
	free(f32_buf);
        break;
      case DFNT_INT32:
        f32_buf = (float32 *) malloc(f.ncells*sizeof(float32));
	for (n=0; n<f.ncells; n++) f32_buf[n] = (float32) f.i32_unscaled[n];
	fwrite(f32_buf, sizeof(float32), f.ncells, fp_out);
        free(f.i32_unscaled);
	free(f32_buf);
        break;
      case DFNT_FLOAT32:
        fwrite(f.f32_unscaled, sizeof(float32), f.ncells, fp_out);
        free(f.f32_unscaled);
        break;
      default:
        printf("\n%s: Unscaled data type is not INT8, INT16, INT32, or FLOAT32-exiting\n\n",f.sds_name);
        exit(1);
    }
  
  }
  
  /*----------------------------------------------------------------------------
    Print out the size of the SDS's read in.
  ----------------------------------------------------------------------------*/
  
  printf("***Number of cells in CLAVR-x grid: %d\n",f.ncells);
  
  /*----------------------------------------------------------------------------
    Close the HDF, input, and output files.
  ----------------------------------------------------------------------------*/
  
  status = SDend(sd_id);
  if (status == FAIL) {
    printf("\nError closing HDF file: %s\n\n", hdf_name);
    exit (1);
  }
  
  fclose(fp_in);
  fclose(fp_out);
  
  /*----------------------------------------------------------------------------
    Finished with routine.
  ----------------------------------------------------------------------------*/
  
  printf("\n");

}

/*********************************************************************************/
/*********************************************************************************/
