echo "Fething values.yaml from directories"
arr=(`find  ~/Curefit/prod/ -name "values-*.yaml"`)
echo "Retrieved all values.yaml files"

for i in "${arr[@]}"
do
    if helm template . -f $i 2> /dev/null 1> /dev/null ; then
        :
    else
        echo "Failed for $i"
    fi
done