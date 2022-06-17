local envvar_ver = os.getenv("envvar_ver")
local PrgEnv_intel_ver = os.getenv("PrgEnv_intel_ver")
local craype_ver = os.getenv("craype_ver")
local intel_ver = os.getenv("intel_ver")
local cray_mpich_ver = os.getenv("cray_mpich_ver")
local w3emc_ver = os.getenv("w3emc_ver")
local w3nco_ver = os.getenv("w3nco_ver")
local bacio_ver = os.getenv("bacio_ver")
local zlib_ver = os.getenv("zlib_ver")
local bacio_ver = os.getenv("bacio_ver")
local hdf4_ver = os.getenv("hdf4_ver")
local libjpeg_ver = os.getenv("libjpeg_ver")

load("envvar/"..envvar_ver)
load("PrgEnv-intel/"..PrgEnv_intel_ver)
load("craype/"..craype_ver)
load("intel/"..intel_ver)
load("cray_mpich/"..cray_mpich_ver)
load("w3emc/"..w3emc_ver)
load("w3nco/"..w3nco_ver)
load("bacio/"..bacio_ver)
load("zlib/"..zlib_ver)
load("libjpeg/"..libjpeg_ver)
