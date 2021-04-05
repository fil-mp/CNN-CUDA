#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define max(a,b) (((a) > (b)) ? (a) : (b))
#include <math.h>
#include <cuda.h>
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include "cuda_runtime_api.h"
#include <time.h>


#define cudaCheckErrors(msg) \
	do { \
		cudaError_t __err = cudaGetLastError(); \
		if (__err != cudaSuccess) { \
			fprintf(stderr, "Fatal error: %s (%s at %s:%d)\n", \
				msg, cudaGetErrorString(__err), \
				__FILE__, __LINE__); \
			fprintf(stderr, "*** FAILED - ABORTING\n"); \
			return 1; \
		} \
	} while (0)

#define kernels 8
#define out_height 76
#define out_width 76
#define kernel_height 5
#define kernel_width 5
#define depth 3
#define maxout_height 19
#define maxout_width 19
#define maxpooldepth 8
//#define pool_x 5
//#define pool_y 5
#define dense_out 32
#define out_height1 16
#define out_width1 16
#define depth1 8
#define kernel1_height 4
#define kernel1_width 4
#define kernels1 8
#define maxout_height1 4
#define maxout_width1 4
#define maxpooldepth1 8
//#define pool_x1
//#define pool_y1
#define flattened 128
#define dense1_out 2
#define thread 8
//#define threads 32


#define de 3
#define sy 80
#define sx 80

#define a 5
#define b 5
#define c0 3
#define d 8

#define a1 4
#define b1 4
#define c1 8
#define d1 8

#define e 8

#define v 32

#define g 2

#define z0 128
#define q 32

#define z1 32
#define q1 2



void read_input(const char filename[], float numberArray[sy*sx*de])
{
	int x;
	FILE* myFile;
	myFile = fopen(filename, "r");

	//read file into array
	
	
	for (x = 0; x < de; x++)
		for (int i = 0; i < sy; i++)
			for (int j = 0; j < sx; j++)

			{
				fscanf(myFile, "%f", &numberArray[x*sy*sx + i * sy + j]);
			}
			

}

void read_weights(const char filename[], float numberArray[a*b*c0*d])
{

	FILE* myFile;
	myFile = fopen(filename, "r");

	//read file into array

	//read file into array

	int i, j, x, y;
	for (y = 0; y < d; y++)
		for (x = 0; x < c0; x++)
			for (i = 0; i < a; i++)
				for (j = 0; j < b; j++)
				{
					fscanf(myFile, "%f", &numberArray[y*c0*a*b + x * a*b + i * b + j]);

				}



}

void read_weights1(const char filename[], float numberArray[a1*b1*c1*d1])
{

	FILE* myFile;
	myFile = fopen(filename, "r");


	int i, j, x, y;
	for (y = 0; y < d1; y++)
		for (x = 0; x < c1; x++)
			for (i = 0; i < a1; i++)
				for (j = 0; j < b1; j++)
				{
					fscanf(myFile, "%f", &numberArray[y*c1*a1*b1 + x * a1*b1 + i * b1 + j]);

				}


}

void read_dweights(const char filename[], float numberArray[z0*q])
{

	FILE* myFile;
	myFile = fopen(filename, "r");

	//read file into array
	//double numberArray[m*n] = { 0.0 };
	int i, j;
	for (i = 0; i < z0; i++)
		for (j = 0; j < q; j++)
		{
			fscanf(myFile, "%f", &numberArray[i*q + j]);

		}

}

void read_dweights1(const char filename[], float numberArray[z1*q1])
{

	FILE* myFile;
	myFile = fopen(filename, "r");

	//read file into array

	int i, j;
	for (i = 0; i < z1; i++)
		for (j = 0; j < q1; j++)
		{
			fscanf(myFile, "%f", &numberArray[i*q1 + j]);

		}


}

void read_bias(const char filename[], float numberArray[e])
{

	FILE* myFile;
	myFile = fopen(filename, "r");

	//read file into array
	int i;
	for (i = 0; i < e; i++)
	{
		fscanf(myFile, "%f", &numberArray[i]);
	}


}

void read_bias2(const char filename[], float numberArray[g])
{

	FILE* myFile;
	myFile = fopen(filename, "r");

	//read file into array

	int i;
	for (i = 0; i < g; i++)
	{
		fscanf(myFile, "%f", &numberArray[i]);
	}


}

void read_bias1(const char filename[], float numberArray[v])
{

	FILE* myFile;
	myFile = fopen(filename, "r");

	//read file into array

	int i;
	for (i = 0; i < v; i++)
	{
		fscanf(myFile, "%f", &numberArray[i]);
	}


}


__global__ void convolution(float *d_in, float *d_out_layer, float *d_weight, float *d_bias)
{
	int tx = threadIdx.x;
	int ty = threadIdx.y;
	
	// Block index
	int bx = blockIdx.x;
	int by = blockIdx.y;
	
	/* row and column index */
	int x, y;
	/* row and column index of each thread */
	y = by * thread + ty;
	x = bx * thread + tx;

	int  k,c, ky, kx;

	for (k = 0; k < kernels; ++k) {
		if (y >= 0 && y < out_height &&  x >= 0 && x < out_width) {
			//out[y*x*k] = 0.f ;
			for (c = 0; c < depth; ++c) {
				for (ky = 0; ky < kernel_height; ++ky) {
					for (kx = 0; kx < kernel_width; ++kx) {

						d_out_layer[k*out_height*out_width + y * out_width + x] += d_weight[k*depth*kernel_height*kernel_width + c * kernel_height * kernel_width + ky * kernel_width + kx] * d_in[c * 80 * 80 + ((y + ky) * 80) + (x + kx)];
						__syncthreads();
					}
				}
			}


			d_out_layer[k*out_height*out_width + y * out_width + x] += d_bias[k];
			//__syncthreads();

		}
	}
}





__global__ void convolution1(float *d_in1, float *d_out_layer1, float *d_weight1, float *d_bias1)
{
	int tx = threadIdx.x;
	int ty = threadIdx.y;
	// Block index
	int bx = blockIdx.x;
	int by = blockIdx.y;
	
	/* row and column index */
	int x, y;
	/* row and column index of each thread */
	y = by * thread + ty;
	x = bx * thread + tx;
	int k, c, ky, kx;
	//__syncthreads();

	for (k = 0; k < kernels1; ++k) {
		if (y < out_height1 && x < out_width1) {
				for (c = 0; c < depth1; ++c) {
					for (ky = 0; ky < kernel1_height; ++ky) {
						for (kx = 0; kx < kernel1_width; ++kx) {
							d_out_layer1[k*out_height1*out_width1 + y * out_width1 + x] += d_weight1[k*depth1*kernel1_height*kernel1_width+c*kernel1_height*kernel1_width+ky*kernel1_width+kx] * d_in1[c * maxout_height*maxout_width + (y + ky) * maxout_width + (x + kx)];
							__syncthreads();
						}
					}
				}

				d_out_layer1[k*out_height1*out_width1 + y * out_width1 + x] += d_bias1[k];
				__syncthreads();
			}
		}


	}


__global__ void d__relu2d(float *d_out_layer, float *d_relu2d)
{
	int i = blockDim.y * blockIdx.y + threadIdx.y;
	int j = blockDim.x * blockIdx.x + threadIdx.x;
	int k;
	
		if (i < out_height && j < out_width) {
			for (k = 0; k < kernels; ++k) {
				if (d_out_layer[k*out_height*out_width + i * out_width + j] <= 0.f) {
					d_relu2d[k*out_height*out_width + i * out_width + j] = 0.f;
				}
				else
					d_relu2d[k*out_height*out_width + i * out_width + j] = d_out_layer[k*out_height*out_width + i * out_width + j];

			}
		}
	}


__global__ void d_relu2da(float *d_out_layer1, float *d_relu2d1)
{

	int i = blockDim.y * blockIdx.y + threadIdx.y;
	int j = blockDim.x * blockIdx.x + threadIdx.x;
	int k;
	for (k = 0; k < kernels1; ++k) {
		if (i < out_height1 && j < out_width1) {
			if (d_out_layer1[k*out_height1*out_width1 + i * out_width1 + j] <= 0.f) {
				d_relu2d1[k*out_height1*out_width1 + i * out_width1 + j] = 0.f;
			}
			else
				d_relu2d1[k*out_height1*out_width1 + i * out_width1 + j] = d_out_layer1[k*out_height1*out_width1 + i * out_width1 + j];

		}
	}
}

void convolution_layer1(float in[80*80*3], float out[out_height*out_width*kernels], float weights[kernel_height*kernel_width*depth*kernels], float biases[kernels]) {
	unsigned int size_in = 80 * 80 * 3;
	unsigned int mem_size_in = sizeof(float) * size_in;
	float *d_in;

	unsigned int size_weight = kernel_height * kernel_width*depth*kernels;
	unsigned int mem_size_weight = sizeof(float) * size_weight;
	float *d_weight;

	unsigned int size_bias = kernels;
	unsigned int mem_size_bias = sizeof(float) * size_bias;
	float *d_bias;


	unsigned int size_out_layer = out_height * out_width*kernels;
	unsigned int mem_size_out_layer = sizeof(float ) * size_out_layer;
	float *d_out_layer;

	unsigned int size_relu2d = out_height * out_width*kernels;
	unsigned int mem_size_relu2d = sizeof(float) * size_relu2d;
	float *d_relu2d;


	dim3 threads;
	dim3 grid;
	
	/********************************
	* Allocate device memory on GPU.
	********************************/
	
	cudaEvent_t start1, end1, start2, end2;
	float time1, time2;
	cudaEventCreate(&start1);
	cudaEventCreate(&end1);
	cudaEventRecord(start1, 0);
	

	cudaMalloc(&d_in, mem_size_in);
	cudaMalloc(&d_bias, mem_size_bias);
	cudaMalloc(&d_weight, mem_size_weight);
	cudaMalloc(&d_out_layer, mem_size_out_layer);
	cudaMalloc(&d_relu2d, mem_size_relu2d);

	/*********************************************
	 * copy data from host (CPU) to device (GPU)
	 ********************************************/
	


	cudaMemcpy(d_in, in, mem_size_in, cudaMemcpyHostToDevice);
	cudaMemcpy(d_weight, weights, mem_size_weight, cudaMemcpyHostToDevice);
	cudaMemcpy(d_bias, biases, mem_size_bias, cudaMemcpyHostToDevice);

	// Synchronize all the cudaMemcpy API 
	cudaDeviceSynchronize();

	threads.x = thread;
	threads.y = thread;
	threads.z = 1;

	grid.x = (int)ceil(out_width / (float)(thread));
	grid.y = (int)ceil(out_height / (float)(thread));
	grid.z = 1;

	cudaEventCreate(&start2);
	cudaEventCreate(&end2);
	cudaEventRecord(start2, 0);

	
	convolution << <grid, threads >> > (d_in, d_out_layer, d_weight, d_bias);
	d__relu2d << <grid, threads >> > (d_out_layer, d_relu2d);
	

	cudaEventRecord(end2, 0);
	cudaEventSynchronize(end2);
	cudaEventElapsedTime(&time2, start2, end2);
	cudaDeviceSynchronize();
	cudaMemcpy(out, d_relu2d, mem_size_relu2d, cudaMemcpyDeviceToHost);

	cudaFree(d_in);
	cudaFree(d_out_layer);
	cudaFree(d_weight);
	cudaFree(d_bias);
	cudaFree(d_relu2d);

	cudaEventRecord(end1, 0);
	cudaEventSynchronize(end1);
	cudaEventElapsedTime(&time1, start1, end1);
	printf("Total time for layer 1: %f\t sec\n", time2 / 1000);
	printf("Total time (comm+comput) for layer 1 : %f\t sec\n", time1 / 1000);
}






void convolution_layer2(float in[maxout_height*maxout_width*maxpooldepth], float out[out_height1*out_width1*kernels1], float weights[kernel1_height*kernel1_width*depth1*kernels1], float biases[kernels1]) {
	unsigned int size_in = maxout_height * maxout_width*maxpooldepth;
	unsigned int mem_size_in = sizeof(float) * size_in;
	float *d_in1;

	unsigned int size_bias = kernels1;
	unsigned int mem_size_bias = sizeof(float) * size_bias;
	float *d_bias1;

	unsigned int size_weight = kernel1_height * kernel1_width*depth1*kernels1;
	unsigned int mem_size_weight = sizeof(float) * size_weight;
	float *d_weight1;

	unsigned int size_out_layer = out_height1 * out_width1*kernels1;
	unsigned int mem_size_out_layer = sizeof(float) * size_out_layer;
	float *d_out_layer1;

	unsigned int size_relu2d = out_height1 * out_width1*kernels1;
	unsigned int mem_size_relu2d = sizeof(float) * size_relu2d;
	float *d_relu2d1;

	dim3 threads;
	dim3 grid;
	
	/********************************
	* Allocate device memory on GPU.
	********************************/
	cudaEvent_t start1, end1, start2, end2;
	float time1, time2;
	cudaEventCreate(&start1);
	cudaEventCreate(&end1);
	cudaEventRecord(start1, 0);

	cudaMalloc(&d_in1, mem_size_in);
	cudaMalloc(&d_bias1, mem_size_bias);
	cudaMalloc(&d_weight1, mem_size_weight);
	cudaMalloc(&d_out_layer1, mem_size_out_layer);
	cudaMalloc(&d_relu2d1, mem_size_relu2d);

	/*********************************************
	 * copy data from host (CPU) to device (GPU)
	 ********************************************/


	cudaMemcpy(d_in1, in, mem_size_in, cudaMemcpyHostToDevice);
	cudaMemcpy(d_bias1, biases, mem_size_bias, cudaMemcpyHostToDevice);
	cudaMemcpy(d_weight1, weights, mem_size_weight, cudaMemcpyHostToDevice);

	// Synchronize all the cudaMemcpy API 
	cudaDeviceSynchronize();
	
	threads.x = thread;
	threads.y = thread;
	threads.z = 1;

	grid.x = (int)ceil(out_width1 / (float)(thread));
	grid.y = (int)ceil(out_height1 / (float)(thread));
	grid.z = 1;

	cudaEventCreate(&start2);
	cudaEventCreate(&end2);
	cudaEventRecord(start2, 0);

	convolution1 << <grid, threads >> > (d_in1, d_out_layer1, d_weight1, d_bias1);
	d_relu2da << <grid, threads >> > (d_out_layer1, d_relu2d1);
	
	cudaEventRecord(end2, 0);
	cudaEventSynchronize(end2);
	cudaEventElapsedTime(&time2, start2, end2);
	cudaMemcpy(out, d_out_layer1, mem_size_out_layer, cudaMemcpyDeviceToHost);

	cudaFree(d_in1);
	cudaFree(d_out_layer1);
	cudaFree(d_weight1);
	cudaFree(d_bias1);
	cudaFree(d_relu2d1);
	

	cudaEventRecord(end1, 0);
	cudaEventSynchronize(end1);
	cudaEventElapsedTime(&time1, start1, end1);
	printf("Total time for layer 2: %f\t sec\n", time2 / 1000);
	printf("Total time (comm+comput) for layer 2 : %f\t sec\n", time1 / 1000);


}

void maxPool(float in[out_height*out_width*kernels], float out[maxout_height*maxout_width*maxpooldepth], int pool_y, int pool_x)
{
	int y, x, i, j, c;


	for (c = 0; c < maxpooldepth; ++c) {
		for (y = 0; y < maxout_height; ++y) {
			for (x = 0; x < maxout_width; ++x) {
				for (i = 0; i < pool_y; ++i) {
					for (j = 0; j < pool_x; ++j)
					{
						float temp = in[c*out_height*out_width + (y * pool_y + i) * out_width + (x * pool_x + j)];
					out[c*maxout_height*maxout_width + y * maxout_width + x] = max(out[c*maxout_height*maxout_width + y * maxout_width + x], temp);
				}
				}
			}
		}
	}

}

void maxPool1(float in[out_height1*out_width1*kernels1], float out[maxout_height1*maxout_width1*maxpooldepth1], int pool_y, int pool_x)
{
	int y, x, i, j, c;


	for (c = 0; c < maxpooldepth1; ++c) {
		for (y = 0; y < maxout_height1; ++y) {
			for (x = 0; x < maxout_width1; ++x) {
				for (i = 0; i < pool_y; ++i) {
					for (j = 0; j < pool_x; ++j)
					{
						float temp = in[c * out_height1 * out_width1 + (y * pool_y + i) * out_width1 + (x * pool_x + j)];
						out[c * maxout_height1 * maxout_width1 + y * maxout_width1 + x] = max(out[c * maxout_height1 * maxout_width1 + y * maxout_width1 + x], temp);
					}
				}
			}
		}
	}

}



void flatten(float in[maxout_height1*maxout_width1*maxpooldepth1], float out[flattened])
{
	int x, y, c;
	int i = 0;
	for (x = 0; x < maxout_width1; ++x) {
		for (y = 0; y < maxout_height1; ++y) {
			for (c = 0; c < maxpooldepth1; ++c) {
				out[i++] = in[c * maxout_height1 * maxout_width1 + y * maxout_width1 + x];
			}
		}
	}


}


void relu1d(float in[dense_out], float out[dense_out])
{
	int i;

	for (i = 0; i < dense_out; ++i) {
		if (in[i] < 0.f) {
			out[i] = 0.f;
		}
		else
			out[i] = in[i];
	}
}

void dense(float in[maxout_height1*maxout_width1*maxpooldepth1], float out[dense_out], float weights[flattened*dense_out], float biases[dense_out])
{
	int i, j;

	for (i = 0; i < flattened; ++i) {
		for (j = 0; j < dense_out; ++j) {
			out[j] += weights[i*dense_out+j] * in[i];
		}

	}

	for (j = 0; j < dense_out; ++j) {
		out[j] += biases[j];
	}

}

void dense1(float in[dense_out], float out[dense1_out], float weights[dense_out*dense1_out], float biases[dense1_out])
{
	int i, j;

	for (i = 0; i < dense_out; ++i) {
		for (j = 0; j < dense1_out; ++j) {
			out[j] += weights[i*dense1_out+j] * in[i];
		}
	}

	for (j = 0; j < dense1_out; ++j) {
		out[j] += biases[j];
	}

}

void output(float in[dense1_out])
{
	int i;
	for (i = 0; i < dense1_out; ++i) {
		printf("%f \n", in[i]);
	}
}

int main(void) {
	//static float conv0layer[76 * 76 * 8];
	static float relu0a[76 * 76 * 8];
	static float maxpool0layer[19 * 19 * 8];
	//static float conv1layer[16 * 16 * 8];
	static float relu0b[16 * 16 * 8];
	static float maxpool1layer[4 * 4 * 8];
	static float denselayer[32];
	static float relu1a[32];
	static float dense1layer[2];

	static float input[80 * 80 * 3];
	static float conv0_bias[8];
	static float conv0_kernel[5 * 5 * 3 * 8];
	static float conv1_bias[8];
	static float conv1_kernel[4 * 4 * 8 * 8];
	static float dense_bias[32];
	static float dense_weights[128 * 32];
	static float dense1_bias[2];
	static float dense1_weights[32 * 2];
	static float flattenlayer[128];

	read_input("input_layer.txt", input);
	read_bias("conv0_bias.txt", conv0_bias);
	read_weights("conv0_kernel.txt", conv0_kernel);
	read_bias("conv1_bias.txt", conv1_bias);
	read_weights1("conv1_kernel.txt", conv1_kernel);
	read_bias1("dense_bias.txt", dense_bias);
	read_dweights("dense_weights.txt", dense_weights);
	read_bias2("dense1_bias.txt", dense1_bias);
	read_dweights1("dense1_weights.txt", dense1_weights);

	/*
	convolution(input, conv0layer, conv0_kernel, conv0_bias);
	relu2d(conv0layer, relu0a);
	maxPool(relu0a, maxpool0layer, 4, 4);

	convolution1(maxpool0layer, conv1layer, conv1_kernel, conv1_bias);
	relu2da(conv1layer, relu0b);
	maxPool1(relu0b, maxpool1layer, 4, 4);
	*/
	convolution_layer1(input, relu0a, conv0_kernel, conv0_bias);
	
	
	//relu2d(conv0layer, relu0a);
	//d_maxPool(relu0a, maxpool0layer, 4, 4);
	maxPool(relu0a, maxpool0layer, 4, 4);


	convolution_layer2(maxpool0layer, relu0b, conv1_kernel, conv1_bias);
	
	
	
	//relu2da(conv1layer, relu0b);
	
	//d_maxPool1(relu0b, maxpool1layer, 4, 4);
	maxPool1(relu0b, maxpool1layer, 4, 4);

	flatten(maxpool1layer, flattenlayer);

	dense(flattenlayer, denselayer, dense_weights, dense_bias);
	relu1d(denselayer, relu1a);

	dense1(relu1a, dense1layer, dense1_weights, dense1_bias);
	output(dense1layer);

	return 0;
}
