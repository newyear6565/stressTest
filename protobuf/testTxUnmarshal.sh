mycount=0
totalThread=200
test()
{
    while (( $mycount < $totalThread ));
    do
        curl -i -H 'Content-Type: application/json' -X POST http://localhost:8685/v1/user/rawtransaction -d '{"data":"CiA7nIzd2fxOQjrXNc7M1F8ShM3ANbFiV8w2IlMukKGDihIaGVf8rf7mn18ymyvOkCX59BghNoFBilrvV60aGhlXor0XVEvxJTi+GBqrH8lr87r/RLImSfk9IhAAAAAAAAAAAAAAAOjUpRAAMIeuguQFOggKBmJpbmFyeUBkShAAAAAAAAAAAAAAAAAAD0JAUhAAAAAAAAAAAAAAAAAAHoSAWAFiQb/OtPCmzBjNHMM5IehXL0Cbwcn758szq1RXQmpvsKUrPALq9V67LjRbzacXLfrhi5QnJreaj7EuYxPLJSMxAWoB"}'
    ((mycount=$mycount+1));
    echo ""
    echo $mycount
    echo ""
    sleep 0.01
    done;

    
}

test
