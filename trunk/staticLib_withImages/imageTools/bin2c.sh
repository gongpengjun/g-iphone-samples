mkdir -p tmp
rm -f $1/*.h
ls -1 $1 > tmp/filelist
sed -n -e /\\.gif$/p -e /\\.png$/p -e /\\.jpg$/p < tmp/filelist > tmp/imagelist
echo Found image files:
cat tmp/imagelist
echo ========
sed s/\\./_/ < tmp/imagelist > tmp/arraylist
sed s/$/.h/ < tmp/arraylist > tmp/headerlist
paste tmp/imagelist tmp/headerlist > tmp/bin2clist
cd $1
awk -f ../imageTools/bin2c.awk ../tmp/bin2clist
sed -f ../imageTools/ImageList.sed ../tmp/arraylist > ImageList.h
echo ImageList.h generated.
sed -f ../imageTools/ImageTable.sed ../tmp/arraylist > ImageTable.h
echo ImageTable.h generated.
cd - > /dev/null