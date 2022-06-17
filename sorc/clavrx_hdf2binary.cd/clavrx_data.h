#define DIMEN_LEN 10
#define MAX_LEN 500
#define MISSING_I8 -128
#define MISSING_I16 -999
#define MISSING_I32 -999
#define MISSING_F32 -999.0
#define DTOR 0.0174533
#define PI 3.1415926
#define C1 1.191062e-5
#define C2 1.4387863

#define max(A, B) ((A) > (B) ? (A) : (B))
#define min(A, B) ((A) < (B) ? (A) : (B))

typedef struct VARIABLE_INFORMATION {
  
  char8
   sds_name[MAX_NC_NAME],
   units[MAX_NC_NAME];
  
  int8
   scaled_flg;
   
  int32
   scaled_min,
   scaled_max,
   scaled_missing,
   scaled_type,
   unscaled_type,
   unscaled_type_size,
   ncells,
   rank,
   dimen[DIMEN_LEN],
   *nobs;
  
  float32
   range_min,
   range_max;
    
  int8
   *i8_unscaled,
   *i8_avg;
   
  int16
   *i16_unscaled,
   *i16_avg;
   
  int32
   *i32_unscaled,
   *i32_avg;
   
  float32
   *f32_unscaled,
   *f32_avg;
    
} var_info;

void read_clavrx_hdf(int32, int32, var_info *, int8);
void print_err_msg(char [], char *, int, int);
