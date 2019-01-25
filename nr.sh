usage()
{
  echo "USAGE: $0 [net]"
  echo " e.g.: \"$0 local\" or \"$0 internal\""
  exit 1;
}

if [ $# != 1 ] ; then
  usage
fi

if [[ "$1" != "local" && "$1" != "internal" ]] ; then
  usage
fi

url="http://localhost:9685"

if [[ "$1" == "internal" ]] ; then
  url="http://47.92.203.173:9685"
fi

#echo "connecting : "$url

time=$(date "+%Y-%m-%d-%H-%M-%S")
dirName="result"${time}

mkdir $dirName
cd $dirName

#pwd

mycount=0;
totalThread=100


timeTest=30
timeDelay=$[timeTest+1]
logfile="nrIdResult%04d.log"


#echo "creating log file..."

while (( $mycount < $totalThread ));
  do
    name=$(printf $logfile $mycount);
    touch "$name";
    ((mycount=$mycount+1)); 
done;

mycount=0
#echo "test start..."

while (( $mycount < $totalThread ));
  do
    name=$(printf $logfile $mycount);
    nohup ../wrk -s ../getNrHandlerId.lua -d${timeTest}  -t1 -c1 --latency $url > $name 2>&1 &
    ((mycount=$mycount+1));
done;

cd ..

sleep $timeDelay

echo $dirName
