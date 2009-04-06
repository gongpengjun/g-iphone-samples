#! /bin/sh
#
# A build script to generate a header file that defines the all images' name
#

HEADER_FILE=../images/ImageTable.h
rm -f "$HEADER_FILE"
cat <<- EOF > "$HEADER_FILE"
	/*
	*  ImageTable.h
	*
	* THIS FILE IS GENERATED AUTOMATICALLY BY THE BUILD PROCESS
	* DO NOT MODIFY IT AND DO NOT ADD IT TO SOURCE CONTROL
	*/

	#ifndef IMAGE_TABLE_H
	#define IMAGE_TABLE_H

	#include "Apple_Logo_gif.h"
	#include "Apple_Logo_png.h"
	#include "Apple_Logo_jpg.h"

	#define INTERNAL_NAME(name,type) #name "_" #type
	#define IMAGE(name,type) {INTERNAL_NAME(name,type), name##_##type,sizeof(name##_##type)}

	#define IMAGE_TABLE { \
	IMAGE(Apple_Logo,gif),\
	IMAGE(Apple_Logo,png),\
	IMAGE(Apple_Logo,jpg) \
	}

	#endif
	EOF
