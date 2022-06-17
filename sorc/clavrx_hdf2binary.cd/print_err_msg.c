#include <hdf.h>

void print_err_msg(char sds_name[], char *pro_name, int sd_id, int istatus)

{

  if (istatus == FAIL) {
  
    printf("\nThere was an error reading sds: %s [sd_id=%d] - %s - exiting.\n\n",
           sds_name,sd_id,pro_name);
    
    exit(1);
  }
  
}
