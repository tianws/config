DESTINATION='../test2/'

for i in *
do
    if test -d $i
    then
        echo moving $i
        mv $i $DESTINATION
        ln -s $DESTINATION$i $i
    fi
done
