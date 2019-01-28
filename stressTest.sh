usage()
{
  echo ""
  echo "[Usage]"
  echo "  step 1: set neb cmd path stressTest.sh -p \"nebPath\""
  echo "  step 2: set server address stressTest.sh -s \"server\""
  echo "  step 3: create addrss file,contracts stressTest.sh -c"
  echo "  step 4: start test stressTest.sh -r"
  echo ""
  echo "[Options]"
  echo "  -p neb cmd path"
  echo "  -pre prepare"
  echo "  -precall check and call contract an start test"
  echo "  -s server address"
  echo "  -ca create accounts and create Address file"
  echo "  -cc create contract"
  echo "  -call call contract"
  echo "  -r run test"
  echo "  -rn refresh nonce"
  echo "  -tc test contract deploy status"
  echo "  -ta check address balance"
  echo "  -m  transaction from moneyAddress to address in accounts.sh"
  echo "  -lua create lua info scripts"
  echo "  -check check result"
  echo "  -h help info"
  echo "  -i show config.json"
  echo ""
}


if command -v python >/dev/null 2>&1; then 
    py="python"
else
    
    if command -v python3 >/dev/null 2>&1; then
        py="python3"
    else
        echo "please install python"
    fi
fi

if [ $# -lt 1 ] ; then
  usage
  exit 1
fi

#配置
configJson="{\"path\":\"%s\", \"server\":\"%s\"}"

#有NAS的账户
moneyAddress="n1UCBjyikxeSgJ15Pep5YfwA8UA7g5cZuAA"
#密码
moneyPwd="12345"

#账户密码
passwd="123456"

#账户地址
accountFile="accounts.sh"
#账户个数
accountsCount=50

#合约地址
contractFile="contract.sh"
#合约个数
contractCount=50
#创建合约命令
contractCreateRpc="curl -s -H 'Accept: application/json' -X POST http://localhost:9685/v1/admin/transactionWithPassphrase -H 'Content-Type: application/json' -d '{\"transaction\": {\"from\":\"%s\",\"to\":\"%s\", \"value\":\"0\",\"nonce\":%d,\"gasPrice\":\"1000000\",\"gasLimit\":\"2000000\",\"contract\":{\"source\":\"%s\",\"sourceType\":\"js\", \"args\":\"\"}}, \"passphrase\": \"%s\"}'"

#与accounts.sh文件中账户对应的nonce文件
nonces="nonce.sh"

initConfig()
{
    if [ ! -f "config.json" ]; then
        echo "{\"path\":\"/home/guangyu/nebulas/go2/src/github.com/nebulasio/go-nebulas/\", \"server\":\"http://localhost:9685\"}" > config.json
    fi
}

getTmp()
{
    initConfig
    pathTmp=$(cat config.json |  $py -c "import sys, json; print json.load(sys.stdin)['path']")
    serverTmp=$(cat config.json |  $py -c "import sys, json; print json.load(sys.stdin)['server']")
}

setPath()
{
    getTmp
    #echo $pathTmp
    #echo $serverTmp
    echo $(printf "$configJson" $1 $serverTmp) > config.json
}

setServer()
{
    getTmp
    echo $(printf "$configJson" $pathTmp $1) > config.json
}

getAccounts()
{
    if [ ! -f "$accountFile" ]; then
        echo "err : cannot find "$accountFile
        exit 1
    else
        . $accountFile
    fi
}

getContracts()
{
    if [ ! -f "$contractFile" ]; then
        echo "err : cannot find "$contractFile
        exit 1
    else
        . $accountFile
    fi
}

createAccounts()
{
    getTmp
    nowpwd=$(pwd)
    cd $pathTmp
    i=0
    echo "accounts=(" > $nowpwd"/"$accountFile
    while (( $i < $accountsCount ));
    do
        k=$($pathTmp"neb" account new $passwd)
        echo "\""${k:9}"\"" >> $nowpwd"/"$accountFile
        ((i=$i+1));
    done;
    cd $nowpwd
    #sed -i 's/Address: //g' accounts
    echo ")" >> $nowpwd"/"$accountFile
}

testAccounts()
{
    . $accountFile

    i=0
    while(($i < $contractCount))
    do
        balance=$(curl -s -H Accept:application/json -X POST http://localhost:9685/v1/user/accountstate  -d '{"address":"'${accounts[$i]}'"}')
        balance=$(python tool.py balance $balance)
        echo ${accounts[$i]}":"$balance
        ((i=$i+1))
    done
}


getNonce()
{
    . $accountFile
    echo "nonce=(" > $nonces
    i=0 
    while(($i < $contractCount))
    do  
        n=$(curl -s -H Accept:application/json -X POST http://localhost:9685/v1/user/accountstate  -d '{"address":"'${accounts[$i]}'"}' | python -c "import sys, json; print json.load(sys.stdin)['result']['nonce']")
        echo "\""$n"\"" >> $nonces
        ((i=$i+1))
    done

    echo ")" >> $nonces

}

transactionFromAdmin()
{

    nonce=$(curl -s -H Accept:application/json -X POST http://localhost:9685/v1/user/accountstate  -d '{"address":"'$moneyAddress'"}')
    nonce=$(python tool.py nonce $nonce)
    #echo $nonce
    . $accountFile
    i=0
    #while(($i < $contractCount))
    while(($i < $contractCount))
    do
        ((nonce=$nonce+1))
        #echo "------------------------"
        #echo ${accounts[$i]}
        #echo $moneyAddress
        #echo $nonce
        #echo $moneyPwd
        raw=$(curl -s -H 'Content-Type: application/json' -X POST http://localhost:9685/v1/admin/sign -d '{"transaction":{"from":"'$moneyAddress'","to":"'${accounts[$i]}'", "value":"10000000000000000000","nonce":'$nonce',"gasPrice":"1000000","gasLimit":"2000000"}, "passphrase":"'$moneyPwd'"}')
        #echo $raw
        #echo "-----------------------"
        #echo
        #echo
        raw=$(python tool.py raw $raw)
        curl -s -H 'Content-Type: application/json' -X POST http://localhost:9685/v1/user/rawtransaction -d '{"data":"'$raw'"}' > /dev/null
        ((i=$i+1))
    done
    echo "wait 1 minute"
    sleep 60
}




#创建合约脚本
ccsh="createContract.sh"
#创建合约receipt
crjson="contractResult.json"

createContract()
{
    getNonce
    . $nonces
    . $accountFile
    echo "" > $ccsh
    echo "" > $crjson
    data=$(cat bank.js)
    i=0
    while (( $i < $contractCount ));
    #while (( $i < 1 ));
    do
        ((nn=${nonce[$i]}+1))
        $(curl -s -H 'Content-Type: application/json' -X POST http://localhost:9685/v1/admin/account/unlock -d '{"address":"'${accounts[$i]}'","passphrase":"'$passwd'","duration":"43200000000000"}')
        cmd=$(printf "$contractCreateRpc" ${accounts[$i]} ${accounts[$i]} $nn "$data" $passwd)
        echo $cmd" >> "$crjson  >> $ccsh
        echo >> $ccsh
        echo "echo creating contract ..." >> $ccsh
        echo "echo >> "$crjson >> $ccsh
        ((i=$i+1));
    done;
    . $ccsh
    dos2unix $ccsh 1>/dev/null 2>&1
}

#当前尝试次数
repeat=0
#总共可以的尝试次数
totalRepeat=3

resetTest()
{
    repeat=0
}

testContractState()
{
    echo "checking deployed contract receipt..."

    i=0
    ok=0
    echo "contracts=(" > $contractFile
    while read line
    do
        if [ ! -n "$line" ]; then
            echo > /dev/null
        else
            ((i=$i+1));
            txhash=$(echo "${line}" | python -c "import sys, json; print json.load(sys.stdin)['result']['txhash']")
            status=$(curl -s -H 'Content-Type: application/json' -X POST http://localhost:9685/v1/user/getTransactionReceipt -d '{"hash":"'$txhash'"}')
            status=$(python tool.py status $status)
            if [ "$status" == "1" ]; then
                ((ok=$ok+1));
                address=$(echo "${line}" | python -c "import sys, json; print json.load(sys.stdin)['result']['contract_address']")
                echo "\""$address"\"" >> $contractFile
            fi
        fi
    done < $crjson
    echo ")" >> $contractFile
    echo "Total contract: "$i" success: "$ok
    #((i=$i/2))
    if [ $ok -lt $i ];then
        if [ $repeat -lt $totalRepeat ];then
            ((repeat=$repeat+1));
            echo "not enough success contract, check again..."
            sleep 10
            testContractState
        else
            echo "deploy contract failed  please redo this script -cc "
            resetTest
            exit 1
        fi
    fi

}

callContract()
{
    getNonce
    createLua
    echo "call contract..."
    ./wrk -s ex_contract.lua -t1 -c1 -d10 --latency http://localhost:9685 > call.log
    sleep 11 

}

luaAccount="accounts.lua"
luaNonce="nonce.lua"
luaContract="contract.lua"
luaHeight="height.lua"

createParam()
{
    getTmp
    start=0
    height=$(curl -s -H Accept:application/json -X GET $serverTmp/v1/user/nebstate)
    height=$(python tool.py height $height)
    if [ $height -gt 2000 ] ; then
        ((start=$height-2000))
    fi
    #echo "## height:"$height" start:"$start
    echo "startHeight="$start > $luaHeight
    echo >> $luaHeight
    echo "endHeight="$height >> $luaHeight
}

createLua()
{
    echo "creating lua script..."
    . $accountFile
    . $contractFile
    . $nonces

    echo "nonces={" > $luaNonce
    i=0
    while(($i < $accountsCount))
    do
        echo ${nonce[$i]}"," >> $luaNonce
        ((i=$i+1))
    done
    echo "}" >> $luaNonce



    echo "contractArray={" > $luaContract
    i=0
    while(($i < $contractCount))
    do
        echo "\""${contracts[$i]}"\"," >> $luaContract
        ((i=$i+1))
    done
    echo "}" >> $luaContract

    

    echo "accounts={" > $luaAccount
    i=0
    while(($i < $contractCount))
    do
        echo "\""${accounts[$i]}"\"," >> $luaAccount
        ((i=$i+1))
    done
    echo "}" >> $luaAccount

}

#getNR()
#{
#    log=$(./nr.sh internal)
#    echo $log
#}

resultlog="nrIdResult0001.log"

#NRid缓存
nrIdCache="../nrid.lua"

#NR结果值
nrResultSh="nrResult.sh"

#测试时间
timedelay=60

getNR()
{
    getTmp
    time=$(date "+%Y-%m-%d-%H-%M-%S")
    dirName="result"${time}
    mkdir $dirName
    cd $dirName
    cp ../height.lua ./
    mycount=0
    totalThread=100
    timeTest=30
    timeDelay=$[timeTest+4]
    logfile="nrIdResult%04d.log"
    
    while (( $mycount < $totalThread )); 
    do
        name=$(printf $logfile $mycount);
        touch "$name";
        ((mycount=$mycount+1)); 
    done;

    mycount=0

    while (( $mycount < $totalThread )); 
    do
        name=$(printf $logfile $mycount);
        nohup ../wrk -s ../getNrHandlerId.lua -d${timeTest}  -t1 -c1 --latency $serverTmp > $name 2>&1 &
        ((mycount=$mycount+1));
    done;

    rm -rf height.lua
    cd ..

    sleep $timeDelay
    echo $dirName
}

getNrResutFromId()
{
    getTmp
    # echo "## server: "$serverTmp"  ###"

    i=0
    timedelay=60

    echo "please wait "$timedelay" seconds"
    while (( $i < 5 ));
    do
        nohup ./wrk -s getNrResult.lua -t1 -c1 -d$timedelay --latency $serverTmp > $1"/nrResult"$i".log" 2>&1 &
        ((i=$i+1))
    done
    ((timedelay=$timedelay+4))
    sleep $timedelay
}

getNrResult()
{
    dirNow=$(pwd)
    echo > $nrIdCache
    echo > $nrResultSh
    cd $1
    i=0
    echo "collecting id info"

    i=$(python ../tool.py getNrId $resultlog $nrIdCache)
    #echo "collected "$i" valid id"
    if [ $i -lt 1 ];then
        python ../tool.py checkErr $resultlog
        echo "something wrong in getting NR id please check \"nrIdResultxxxx.log\" in dir \""$1"\""
        exit 1
    fi

    cd $dirNow
    getNrResutFromId $1
}

getLatestDip()
{
    timedelay=60
    getTmp
    #echo "## server: "$serverTmp"  ###"
    echo "please wait "$timedelay" seconds"
    ./wrk -s dipNow.lua -t100 -c200 -d$timedelay --latency $serverTmp > $1"/dipNowResult.log" 2>&1
}


getRandomDip()
{
    timedelay=60
    getTmp
    #echo "## server: "$serverTmp"  ###"

    i=0
    echo "please wait "$timedelay" seconds"
    while (( $i < 5 ));
    do
        nohup ./wrk -s dipRandom.lua -t1 -c1 -d$timedelay --latency $serverTmp > $1"/dipRandomResult"$i".log" 2>&1 &
        ((i=$i+1))
    done
    ((timedelay=$timedelay+4))
    sleep $timedelay
}

checkNrId()
{
    cd $1
    python ../tool.py checkNrId
    cd ..
}

checkNrResult()
{
    cd $1
    python ../tool.py checkNrResult
    cd ..
}

checkDipNow()
{
    cd $1
    python ../tool.py checkDipNow
    cd ..
}

checkDipRandom()
{
    cd $1
    python ../tool.py checkDipRandom
    cd ..
}

#getRandomDip "result2019-01-23-11-39-19"
#getLatestDip "result2019-01-23-11-39-19"
#getNrResutFromId "result2019-01-23-11-39-19"
#getNrResult "result2019-01-23-11-39-19"
#checkNrId "result2019-01-24-10-19-09"
#checkNrResult "result2019-01-24-10-19-09"
#checkDipNow "result2019-01-24-10-19-09"
#checkDipRandom "result2019-01-24-10-19-09"

#exit 1

checkNodeStatus()
{
    getTmp
    echo
    echo "try to connect server: "$serverTmp
    height=$(curl -s -H Accept:application/json -X GET $serverTmp/v1/user/nebstate)
    if [ ! -z "$height" ]; then
        height=$(python tool.py height $height)
        if [ $height == "error" ]; then
            echo "something wrong when doing"
            echo "curl -s -H Accept:application/json -X GET "$serverTmp"/v1/user/nebstate"
            echo
            echo "response:"
            curl -s -H Accept:application/json -X GET $serverTmp/v1/user/nebstate
            echo
            exit 1
        else
            echo "server is ok"
            echo
        fi
    else
        echo "server is down, please check..."
        echo
        exit 1
    fi
}

run()
{
    checkNodeStatus
    #当前heght前2000个
    createParam

    echo "Test 1: get NR id"
    nrResultDir=$(getNR)

    echo "Test 2: get NR result"
    getNrResult $nrResultDir

    echo "Test 3: get latest DIP"
    getLatestDip $nrResultDir

    echo "Test 4: get random DIP"
    getRandomDip $nrResultDir

    echo
    echo "============================"
    echo
    echo "NR result analysis"
    echo
    echo "## check nr id"
    checkNrId $nrResultDir

    echo
    echo "## check nr result"
    checkNrResult $nrResultDir

    echo
    echo "DIP result analysis"
    echo
    echo "## check latest dip"
    checkDipNow $nrResultDir

    echo
    echo "## check random dip"
    checkDipRandom $nrResultDir
    echo
    echo "if error occurs, see more details in "$nrResultDir"/errors.log"
    echo
    echo "============================"
}

checkAll()
{
    nrResultDir = $1
    echo "check dir "$1

    echo
    echo "============================"
    echo
    echo "NR result analysis"
    echo
    echo "## check nr id"
    checkNrId $1

    echo
    echo "## check nr result"
    checkNrResult $1

    echo
    echo "DIP result analysis"
    echo
    echo "## check latest dip"
    checkDipNow $1

    echo
    echo "## check random dip"
    checkDipRandom $1
    echo
    echo "if error occurs, see more details in "$1"/errors.log"
    echo
    echo "============================"

}



prepare()
{
    checkNodeStatus
    echo "prepare step 1: create accounts"
    if [ ! -f accounts.sh ]; then
        createAccounts
    else
        echo "accounts.sh already exist"
    fi

    echo "prepare step 2: transfer NAS to accounts"
    transactionFromAdmin

    echo "prepare step 3: create contracts"
    getNonce
    createContract

    echo "prepare step 4: call contracts"
    resetTest
    testContractState
    createLua
    callContract

    echo "wait 1 minute to test"
    sleep 60
    run
}

prepareCallContract()
{
    checkNodeStatus
    echo "prepare step 1: test contract receipt"
    resetTest
    testContractState
    echo "prepare step 2: call contracts"
    createLua
    callContract

    echo "wait 10 minute to test"
    sleep 600
    run
}


while [ -n "$1" ]
do
  case "$1" in
    -h)
        usage
        exit 0
        ;;
    -i)
        initConfig
        cat config.json
        exit 0
        ;;
    -pre)
        prepare
        exit 0
        ;;
    -precall)
        prepareCallContract
        exit 0
        ;;
    -p)

        if [ $# -lt 2 ] ; then
            echo "get no path"
            exit 1
        fi
        if [ ! -d "$2" ]; then
            echo "path error, please check"
            exit 1
        fi
        setPath "$2"
        echo "set path done"
        shift
        exit 0
        ;;
    -s)
        setServer "$2"
        echo "set server done"
        shift
        exit 0
        ;;
    -ca)
        createAccounts
        echo "create accounts done"
        exit 0
        ;;
    -cc)
        createContract
        echo "create Contract done"
        exit 0
        ;;
    -rn)
        getNonce
        exit 0
        ;;
    -r)
        run
        exit 0
        ;;
    -check)
        checkAll $2
        exit 0
        ;;
    -tc)
        resetTest
        testContractState
        exit 0
        ;;
    -ta)
        testAccounts
        exit 0
        ;;
    -m)
        transactionFromAdmin
        exit 0
        ;;
    -lua)
        createLua
        exit 0
        ;;
    -call)
        callContract
        exit 0
        ;;
    -luaparam)
        createParam
        exit 0
        ;;
    *)
        echo "$1 is not an option"
        usage
        exit 0
        ;;
  esac
  shift
done


