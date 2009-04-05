/*
 *  images.c
 */

#include "images.h"

//image data
#include "Apple_Logo_gif.h"
#include "Apple_Logo_png.h"
#include "Apple_Logo_jpg.h"

#define IMAGE_NUM 3
struct images {
	unsigned char  image_name[256];
	unsigned char* byte_array;
	unsigned int   byte_size;
} g_images[IMAGE_NUM] = {
	{"Apple_Logo_gif",	Apple_Logo_gif,	sizeof(Apple_Logo_gif)	},
	{"Apple_Logo_png",	Apple_Logo_png,	sizeof(Apple_Logo_png)	},
	{"Apple_Logo_jpg",	Apple_Logo_jpg,	sizeof(Apple_Logo_jpg)	}
};

unsigned char* byte_array_of_image(const char* image_name)
{
	for( int i = 0; i < IMAGE_NUM; i++)
		if(0 == strcmp(image_name, (void*)g_images[i].image_name) )
			return g_images[i].byte_array;
	return NULL;
}

unsigned int   byte_size_of_image(const char* image_name)
{
	for( int i = 0; i < IMAGE_NUM; i++)
		if(0 == strcmp(image_name, (void*)g_images[i].image_name) )
			return g_images[i].byte_size;
	return 0;
}
