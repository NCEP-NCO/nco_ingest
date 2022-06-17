/**********************************************************************
**This code is designed to read a given SDS from any CLAVR-x hdf file.
**This routine will also unscale the data if needed. The SDS data and
**other attribute information is then stored in the structure defined
**"clavrx_data.h."
**
** INPUT:
** sd_id: the id returned from a call to SDstart [int32]
** sds_index: the index of the SDS to be read [int32]
** vari: the reference address of the structure defined in
** clavrx_data.h [var_info *]
** pflg: set to 0 to supress printing to the screen [int8]
**
** Author:
** Michael J. Pavolonis, CIMSS/SSEC/UW-Madison
***********************************************************************/

#include <math.h>
#include <hdf.h>
#include "clavrx_data.h"

void read_clavrx_hdf (int32 sd_id, int32 sds_index, var_info *vari, int8 pflg)

{

  char8
   outstring[MAX_NC_NAME];
   
  void
   *buf;
   
  int8
   *i8_buf;
   
  int16
   *i16_buf;
   
  int32
   *i32_buf;
   
  float32
   *f32_buf;
   
  int32
   *start,
   *edge,
   attr_index,
   sds_id,
   status,
   n_attr,
   type,
   n;

  /*sds_index = SDnametoindex(sd_id,sds_name);
  print_err_msg(sds_name,"SDnametoindex",sd_id,sds_index);*/
  
  sds_id = SDselect(sd_id,sds_index);
  sprintf(outstring,"index %d",sds_index);
  print_err_msg(outstring,"SDselect",sd_id,sds_id);
  
  status = SDgetinfo(sds_id,&vari->sds_name[0],&vari->rank,&vari->dimen[0],&vari->scaled_type,&n_attr);
  sprintf(outstring,"index %d",sds_index);
  print_err_msg(outstring,"SDgetinfo",sd_id,status);
  
  if (pflg) printf("Reading sds [%d] ==> %s\n",sds_index,vari->sds_name);
  
  attr_index = SDfindattr(sds_id,"SCALED");
  print_err_msg(vari->sds_name,"SDfindattr (SCALED)",sd_id,attr_index);
  status = SDreadattr(sds_id,attr_index,&vari->scaled_flg);
  print_err_msg(vari->sds_name,"SDreadattr (SCALED)",sd_id,status);
  
  /*attr_index = SDfindattr(sds_id,"UNITS");
  print_err_msg(vari->sds_name,"SDfindattr (UNITS)",sd_id,attr_index);
  status = SDreadattr(sds_id,attr_index,&vari->units[0]);
  print_err_msg(vari->sds_name,"SDreadattr (UNITS)",sd_id,status);*/
  
  attr_index = SDfindattr(sds_id,"UNITS");
  if (attr_index == -1) {
    strcpy(vari->units,"none");
  }
  else {
    status = SDreadattr(sds_id,attr_index,&vari->units[0]);
    print_err_msg(vari->sds_name,"SDreadattr (UNITS)",sd_id,status);
  }
  
  if (vari->scaled_flg) {
    attr_index = SDfindattr(sds_id,"RANGE_MIN");
    print_err_msg(vari->sds_name,"SDfindattr (RANGE_MIN)",sd_id,attr_index);
    status = SDreadattr(sds_id,attr_index,&vari->range_min);
    print_err_msg(vari->sds_name,"SDreadattr (RANGE_MIN)",sd_id,status);
    
    attr_index = SDfindattr(sds_id,"RANGE_MAX");
    print_err_msg(vari->sds_name,"SDfindattr (RANGE_MAX)",sd_id,attr_index);
    status = SDreadattr(sds_id,attr_index,&vari->range_max);
    print_err_msg(vari->sds_name,"SDreadattr (RANGE_MAX)",sd_id,status);
    
    attr_index = SDfindattr(sds_id,"SCALED_MIN");
    print_err_msg(vari->sds_name,"SDfindattr (SCALED_MIN)",sd_id,attr_index);
    status = SDreadattr(sds_id,attr_index,&vari->scaled_min);
    print_err_msg(vari->sds_name,"SDreadattr (SCALED_MIN)",sd_id,status);
    
    attr_index = SDfindattr(sds_id,"SCALED_MAX");
    print_err_msg(vari->sds_name,"SDfindattr (SCALED_MAX)",sd_id,attr_index);
    status = SDreadattr(sds_id,attr_index,&vari->scaled_max);
    print_err_msg(vari->sds_name,"SDreadattr (SCALED_MAX)",sd_id,status);
    
    attr_index = SDfindattr(sds_id,"SCALED_MISSING");
    print_err_msg(vari->sds_name,"SDfindattr (SCALED_MISSING)",sd_id,attr_index);
    status = SDreadattr(sds_id,attr_index,&vari->scaled_missing);
    print_err_msg(vari->sds_name,"SDreadattr (SCALED_MISSING)",sd_id,status);
  }
  
  start = (int32 *) calloc(vari->rank,sizeof(int32));
  edge = (int32 *) calloc(vari->rank,sizeof(int32));
  
  vari->ncells = 1;
  for (n=0; n<vari->rank; n++) {
    vari->ncells *= vari->dimen[n];
    start[n] = 0;
    edge[n] = vari->dimen[n];
  }
  
  buf = (void *) malloc(vari->ncells*sizeof(vari->scaled_type));
  
  status = SDreaddata(sds_id,start,NULL,edge,buf);
  print_err_msg(vari->sds_name,"SDreaddata",sd_id,status);
  
  switch (vari->scaled_type) {
    case DFNT_INT8:
      i8_buf = (int8 *) buf;
      if (!vari->scaled_flg) {
        vari->i8_unscaled = (int8 *) malloc(vari->ncells*sizeof(int8));
        vari->unscaled_type = vari->scaled_type;
vari->unscaled_type_size = sizeof(int8);
for (n=0; n<vari->ncells; n++) vari->i8_unscaled[n] = i8_buf[n];
      }
      break;
    case DFNT_INT16:
      i16_buf = (int16 *) buf;
      if (!vari->scaled_flg) {
        vari->i16_unscaled = (int16 *) malloc(vari->ncells*sizeof(int16));
        vari->unscaled_type = vari->scaled_type;
        vari->unscaled_type_size = sizeof(int16);
for (n=0; n<vari->ncells; n++) vari->i16_unscaled[n] = i16_buf[n];
      }
      break;
    case DFNT_INT32:
      i32_buf = (int32 *) buf;
      if (!vari->scaled_flg) {
        vari->i32_unscaled = (int32 *) malloc(vari->ncells*sizeof(int32));
        vari->unscaled_type = vari->scaled_type;
        vari->unscaled_type_size = sizeof(int32);
for (n=0; n<vari->ncells; n++) vari->i32_unscaled[n] = i32_buf[n];
      }
      break;
    case DFNT_FLOAT32:
      f32_buf = (float32 *) buf;
      if (!vari->scaled_flg) {
        vari->f32_unscaled = (float32 *) malloc(vari->ncells*sizeof(float32));
        vari->unscaled_type = vari->scaled_type;
        vari->unscaled_type_size = sizeof(float32);
for (n=0; n<vari->ncells; n++) vari->f32_unscaled[n] = f32_buf[n];
      }
      break;
    default:
      printf("\n%s: Unscaled data type is not INT8, INT16, INT32, or FLOAT32-exiting\n\n",vari->sds_name);
      exit(1);
  }
        
  if (vari->scaled_flg) {
  
    vari->f32_unscaled = (float32 *) malloc(vari->ncells*sizeof(float32));
    vari->unscaled_type = DFNT_FLOAT32;
    vari->unscaled_type_size = sizeof(float32);
        
    for (n=0; n<vari->ncells; n++) {
      if (vari->scaled_type == DFNT_INT8) {
if (i8_buf[n] == vari->scaled_missing) {
vari->f32_unscaled[n] = MISSING_F32;
}
else {
vari->f32_unscaled[n] = (vari->range_min) + (((float32) i8_buf[n] - (float32) vari->scaled_min)/
                                  ((float32) vari->scaled_max - (float32) vari->scaled_min))*
                                  (vari->range_max - vari->range_min);
if (vari->scaled_flg == 2) vari->f32_unscaled[n] = pow(10.0,vari->f32_unscaled[n]);
        }
      }
      else if (vari->scaled_type == DFNT_INT16) {
if (i16_buf[n] == vari->scaled_missing) {
vari->f32_unscaled[n] = MISSING_F32;
}
else {
vari->f32_unscaled[n] = (vari->range_min) + (((float32) i16_buf[n] - (float32) vari->scaled_min)/
                                  ((float32) vari->scaled_max - (float32) vari->scaled_min))*
                                  (vari->range_max - vari->range_min);
if (vari->scaled_flg == 2) vari->f32_unscaled[n] = pow(10.0,vari->f32_unscaled[n]);
        }
      }
      else {
        if (i32_buf[n] == vari->scaled_missing) {
vari->f32_unscaled[n] = MISSING_F32;
}
else {
vari->f32_unscaled[n] = (vari->range_min) + (((float32) i32_buf[n] - (float32) vari->scaled_min)/
                                  ((float32) vari->scaled_max - (float32) vari->scaled_min))*
                                  (vari->range_max - vari->range_min);
if (vari->scaled_flg == 2) vari->f32_unscaled[n] = pow(10.0,vari->f32_unscaled[n]);
        }
      }
      /*printf("[%d] = %d %f\n",n,vari->i16_unscaled[n],vari->f32_unscaled[n]);*/
    }
  }
  
  status = SDendaccess(sds_id);
  print_err_msg(vari->sds_name,"SDendaccess",sd_id,sds_id);
  
  free(buf);
  free(start);
  free(edge);
  
}
