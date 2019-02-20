mycount=0
totalThread=200
test()
{
    while (( $mycount < $totalThread ));
    do
        curl -i -H 'Content-Type: application/json' -X POST http://localhost:8685/v1/admin/transactionWithPassphrase -d '{"transaction":{"from":"n1dYu2BXgV3xgUh8LhZu8QDDNr15tz4hVDv","to":"n1VMLHmPAK9wvbJzvTxjWb7T4CgqyMj9YLt", "value":"1000000000000","gasPrice":"1000000","gasLimit":"2000000"},"passphrase":"passphrase"}'
    ((mycount=$mycount+1));
    echo ""
    echo $mycount
    echo ""
    sleep 0.01
    done;

    
}

test
