/*
 *  images.c
 */

#include "images.h"
#include "ImageList.h"

struct images {
	unsigned char  image_name[256];
	unsigned char* byte_array;
	unsigned int   byte_size;
} g_images[] = {
#include "ImageTable.h"
};

#define IMAGE_NUM sizeof(g_images) / sizeof(struct images)

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
