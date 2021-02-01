# xmrig
This container is a CUDA enabled build of xmrig/xmrig. It tracks the head of the
master branch at build time. I used the guidance provided in the
XMRig [Build](https://xmrig.com/docs/miner/build/ubuntu) documentation for Ubuntu
to put this image together.

To minimize the complexity of pulling in the required dependencies and
minimizing the size of the image, I use the
nvidia/cuda:11-2.0-devel image to build the xmrig binary. In the second
stage, I copy the build artifacts to a new image dependent on
nvidia/cuda:11.2.0-runtime.

The final image size is ~2.18GB compared to ~4.59GB when using the nvidia
development image.

The entrypoint for the final image is /opt/xmrig/xmrig.

This provides the ability to pass arguments at container execution time. For
example:

```
$ docker run --rm --gpus all -it kriation/xmrig:latest \
-t 4 --randomx-1gb-pages --bench=1M --cuda
 * ABOUT        XMRig/6.8.0 gcc/9.3.0
 * LIBS         libuv/1.34.2 OpenSSL/1.1.1f hwloc/2.1.0
 * HUGE PAGES   supported
 * 1GB PAGES    supported
 * CPU          Intel(R) Core(TM) i5-4670K CPU @ 3.40GHz (1) 64-bit AES
                L2:1.0 MB L3:6.0 MB 4C/4T NUMA:1
 * MEMORY       7.4/31.3 GB (24%)
 * DONATE       0%
 * ASSEMBLY     auto:intel
 * POOL #1      benchmark algo auto
 * COMMANDS     hashrate, pause, resume, results, connection
 * OPENCL       disabled
 * CUDA         11.2/11.2/6.5.0
 * CUDA GPU     #0 01:00.0 GeForce GTX 1660 SUPER 1830/7001 MHz smx:22 arch:75 mem:1572/5941 MB
		 bench    start benchmark hashes 1M algo rx/0
		 cpu      use argon2 implementation AVX2
		 randomx  init dataset algo rx/0 (4 threads) seed 0000000000000000...
		 randomx  allocated 3072 MB (2080+256) huge pages 100% 3/3 +JIT (142 ms)
		 randomx  dataset ready (6438 ms)
		 cpu      use profile  *  (4 threads) scratchpad 2048 KB
		 nvidia   use profile  rx  (1 thread) scratchpad 2048 KB
|  # | GPU |  BUS ID | INTENSITY | THREADS | BLOCKS | BF |  BS | MEMORY | NAME
|  0 |   0 | 01:00.0 |       736 |      32 |     23 |  0 |   0 |   1472 | GeForce GTX 1660 SUPER
		 cpu      READY threads 4/4 (4) huge pages 100% 4/4 memory 8192 KB (3 ms)
		 nvidia   READY threads 1/1 (602 ms)
		 nvidia   #0 01:00.0   0W  0C
		 miner    speed 10s/60s/15m 2275.4 n/a n/a H/s max 2277.7 H/s
		 bench    12.55% 125485/1000000 (60.019s)
|    CPU # | AFFINITY | 10s H/s | 60s H/s | 15m H/s |
|        0 |       -1 |   407.6 |   407.7 |     n/a |
|        1 |       -1 |   412.6 |   412.6 |     n/a |
|        2 |       -1 |   636.7 |   636.5 |     n/a |
|        3 |       -1 |   638.8 |   638.5 |     n/a |
|        - |        - |  2095.8 |  2095.3 |     n/a |
|   CUDA # | AFFINITY | 10s  H/s | 60s  H/s | 15m  H/s |
|        0 |       -1 |    181.3 |    180.3 |      n/a | #0 01:00.0 GeForce GTX 1660 SUPER
|        - |        - |    180.4 |    180.3 |      n/a |
		 miner    speed 10s/60s/15m 2276.2 2275.6 n/a H/s max 2277.7 H/s
		 bench    17.89% 178922/1000000 (85.759s)
		 signal   Ctrl+C received, exiting
		 cpu      stopped (1 ms)
		 nvidia   stopped (376 ms)
```

The prerequisite to using this image is that the NVIDIA container toolkit is
configured properly on the container host. The
[documentation](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/user-guide.html)
from NVIDIA on setting the toolkit up is straightforward.

In addition, I **highly** recommend that Huge Pages, 1GB Pages, and Hardware
prefetching be configured per the XMRig
[documentation](https://xmrig.com/docs/miner/randomx-optimization-guide). The difference in hashrate on my test rig was more than 30%. 

