import sys, json

def status(param):
	try:
		print json.loads(param)['result']['status']
	except:
		print 'error'
  
def balance(param):
	try:
		print json.loads(param)['result']['balance']
	except:
		print 'error'

def nonce(param):
	try:
		print json.loads(param)['result']['nonce']
	except:
		print 'error'

def raw(param):
	try:
		print json.loads(param)['result']['data']
	except:
		print 'error'

def nrStart(param):
	try:
		print json.loads(param)['start']
	except:
		print 'error'

def nrEnd(param):
	try:
		print json.loads(param)['end']
	except:
		print 'error'

def nrid(param):
	try:
		print json.loads(param)['result']['hash']
	except:
		print 'error'

def height(param):
	try:
                print json.loads(param)['result']['height']
        except:
                print 'error'

def getNrId(param):
	inputFile = param[0]
	outFile = param[1]
	i=0
	o = open(outFile, 'w')
	o.write('nrids = {\n')
        with open(inputFile, 'r') as f:
		lines = f.readlines()
		for line in lines:
			try:
				o.write('"'+json.loads(line)['result']['hash']+'",\n')
				i=i+1
			except:
				pass
	o.write('}\n')
	o.close()
	print i

def checkNrId():
	i = 0
	flag=0
	ok=0
	err=0
	errflag=0

	while i < 100:
		fileName = "nrIdResult%04d.log" % i
		#print fileName+"####"
		with open(fileName, 'r') as f:
			lines = f.readlines()
			for line in lines:
				if flag == 0:
					try:
						json.loads(line)['start']
						flag=1
					except:
						flag=0
						pass
				else:
					try:
						json.loads(line)['result']['hash']
						ok = ok + 1
					except:
						errflag=1
						pass
					finally:
						flag=0

					if errflag == 1:
						try:
							json.loads(line)['error']
							err = err + 1
							with open("errors.log", 'a') as er:
								er.write(fileName+' : ' + line)
						except:
							pass
						finally:
							errflag = 0
		i = i + 1
	total = ok + err
	print '{"total":'+str(total)+', "success":'+str(ok)+', "error":'+str(err)+'}'

def checkNrResult():
	i = 0
	flag = 0
	ok = 0
	err = 0
	errflag = 0
	while i < 5:
		fileName = "nrResult%d.log" % i
		# print fileName
		with open(fileName, 'r') as f:
			lines = f.readlines()
			for line in lines:
				if flag == 0:
					try:
						json.loads(line)['hash']
						flag=1
					except:
						flag=0
						pass
				else:
					try:
						json.loads(line)['result']['data']
						ok = ok + 1
					except:
						errflag=1
						pass
					finally:
						flag=0

					if errflag == 1:
						try:
							json.loads(line)['error']
							err = err + 1
							with open("errors.log", 'a') as er:
								er.write(fileName+' : ' + line)
						except:
							pass
						finally:
							errflag = 0
		i = i + 1
	total = ok + err
	print '{"total":'+str(total)+', "success":'+str(ok)+', "error":'+str(err)+'}'


def checkNrResultCompared():
	i = 0
	flag = 0
	ok = 0
	err = 0
	errflag = 0
	d={}
	dfile={}
	tmpHash=''
	dflag=0
	while i < 5:
		fileName = "nrResult%d.log" % i
		# print fileName
		with open(fileName, 'r') as f:
			lines = f.readlines()
			for line in lines:
				if flag == 0:
					try:
						t = json.loads(line)['hash']
						flag=1
						if d.has_key(t) == False:
							dflag=1
							dfile[t] = fileName
						else:
							dflag=0
						tmpHash = t
					except:
						flag=0
						pass
				else:
					try:
						t = json.loads(line)['result']['data']
						if(dflag == 1):
							dflag = 0
							d[tmpHash] = t
							ok = ok + 1
						else:
							told=d[tmpHash]
							if t == told :
								ok = ok + 1
							else:
								err = err + 1
								with open("errors.log", 'a') as er:
									er.write('--result not same :'+fileName+' : ' + line + 'id hash :'+str(tmpHash)+' the old is ##'+ dfile[tmpHash] + ' result:'+  told + '\n')
					except:
						errflag=1
						pass
					finally:
						flag=0

					if errflag == 1:
						try:
							json.loads(line)['error']
							err = err + 1
							with open("errors.log", 'a') as er:
								er.write(fileName+' : ' + line)
						except:
							pass
						finally:
							errflag = 0
		i = i + 1
	total = ok + err
	print '{"total":'+str(total)+', "success":'+str(ok)+', "error":'+str(err)+'}'

def checkNrIdCompared():
        i = 0
        flag=0
        ok=0
        err=0
        errflag=0
	d={}
	dfile={}
	tmpStart=''
	dflag=0
        while i < 100:
                fileName = "nrIdResult%04d.log" % i
                #print fileName+"####"
                with open(fileName, 'r') as f:
                        lines = f.readlines()
                        for line in lines:
                                if flag == 0:
                                        try:
                                                t=json.loads(line)['start']
                                                flag=1
						if d.has_key(t) == False:
							dflag=1
							dfile[t] = fileName
						else:
							dflag=0
						tmpStart=t
                                        except:
                                                flag=0
                                                pass
                                else:
                                        try:
                                                t = json.loads(line)['result']['hash']
						if(dflag == 1):
							dflag = 0
							d[tmpStart] = t
							ok = ok + 1
						else:
							told=d[tmpStart]
							if t == told :
								ok = ok + 1
							else:
								err = err + 1
								with open("errors.log", 'a') as er:
									#er.write(fileName+' : ' + line)
									er.write('--result not same :'+fileName+' : ' + line + 'start height:'+str(tmpStart)+' the old is ##'+ dfile[tmpStart] + ' result:'+  told + '\n')
                                        except:
                                                errflag=1
                                                pass
                                        finally:
                                                flag=0

                                        if errflag == 1:
                                                try:
                                                        json.loads(line)['error']
                                                        err = err + 1
                                                        with open("errors.log", 'a') as er:
                                                                er.write(fileName+' : ' + line)
                                                except:
                                                        pass
                                                finally:
                                                        errflag = 0
                i = i + 1
        total = ok + err
        print '{"total":'+str(total)+', "success":'+str(ok)+', "error":'+str(err)+'}'


def checkDipNowCompared():
	i = 0
	ok = 0
	err = 0
	errflag = 0
	d={}
	count = 0

	fileName = "dipNowResult.log"
	# print fileName
	with open(fileName, 'r') as f:
		lines = f.readlines()
		for line in lines:
			count = count + 1
			try:
				tmpData = json.loads(line)['result']['data']
				tmpStart = json.loads(line)['result']['start']
				if d.has_key(tmpStart) == False:
					d[tmpStart] = str(tmpData)
					ok = ok + 1
				else:
					told = d[tmpStart]
					t = str(tmpData)
					if t == told:
						ok = ok + 1
					else:
						err = err + 1
						with open("errors.log", 'a') as er:
							er.write('--result not same :'+fileName+' in line'+str(count)+': ' + line + ':'+tmpStart +' the old is ## :'+  told + '\n')
			except:
				errflag=1
				pass
			if errflag == 1:
				try:
					json.loads(line)['error']
					err = err + 1
					with open("errors.log", 'a') as er:
						er.write(fileName+' : ' + line)
				except:
					pass
				finally:
					errflag = 0
	total = ok + err
	print '{"total":'+str(total)+', "success":'+str(ok)+', "error":'+str(err)+'}'

def checkDipRandomCompared():
	i = 0
	ok = 0
	err = 0
	errflag = 0
	count = 0
	d={}
	dfile={}
	while i < 5:
		fileName = "dipRandomResult%d.log" % i
		# print fileName
		with open(fileName, 'r') as f:
			lines = f.readlines()
			for line in lines:
				try:
					tmpData = json.loads(line)['result']['data']
					tmpStart = json.loads(line)['result']['start']
					if d.has_key(tmpStart) == False:
						d[tmpStart] = str(tmpData)
						dfile[tmpStart] = fileName
						ok = ok + 1
					else:
						told = d[tmpStart]
						t = str(tmpData)
						if t == told:
							ok = ok + 1
						else:
							err = err + 1
							with open("errors.log", 'a') as er:
								er.write('--result not same :'+fileName+' in line'+str(count)+': ' + line + ':'+tmpStart +' the old is ## '+ dfile[tmpStart]+':'+  told + '\n')
				except:
					errflag=1
					pass
				finally:
					flag=0

				if errflag == 1:
					try:
						json.loads(line)['error']
						err = err + 1
						with open("errors.log", 'a') as er:
							er.write(fileName+' : ' + line)
					except:
						pass
					finally:
						errflag = 0
		i = i + 1
		count = 0
	total = ok + err
	print '{"total":'+str(total)+', "success":'+str(ok)+', "error":'+str(err)+'}'

def checkDipNow():
	i = 0
	ok = 0
	err = 0
	errflag = 0

	fileName = "dipNowResult.log"
	# print fileName
	with open(fileName, 'r') as f:
		lines = f.readlines()
		for line in lines:
			try:
				json.loads(line)['result']['data']
				ok = ok + 1
			except:
				errflag=1
				pass
			if errflag == 1:
				try:
					json.loads(line)['error']
					err = err + 1
					with open("errors.log", 'a') as er:
						er.write(fileName+' : ' + line)
				except:
					pass
				finally:
					errflag = 0
	total = ok + err
	print '{"total":'+str(total)+', "success":'+str(ok)+', "error":'+str(err)+'}'

def checkDipRandom():
	i = 0
	flag = 0
	ok = 0
	err = 0
	errflag = 0
	while i < 5:
		fileName = "dipRandomResult%d.log" % i
		# print fileName
		with open(fileName, 'r') as f:
			lines = f.readlines()
			for line in lines:
				if flag == 0:
					try:
						json.loads(line)['height']
						flag=1
					except:
						flag=0
						pass
				else:
					try:
						json.loads(line)['result']['data']
						ok = ok + 1
					except:
						errflag=1
						pass
					finally:
						flag=0

					if errflag == 1:
						try:
							json.loads(line)['error']
							err = err + 1
							with open("errors.log", 'a') as er:
								er.write(fileName+' : ' + line)
						except:
							pass
						finally:
							errflag = 0
		i = i + 1
	total = ok + err
	print '{"total":'+str(total)+', "success":'+str(ok)+', "error":'+str(err)+'}'

def checkErr(param):
	inputFile = param[0]
	with open(inputFile, 'r') as f:
		lines = f.readlines()
		for line in lines:
			try:
				print json.loads(line)['error']
				return
			except:
				pass


if __name__ == "__main__":
	if sys.argv[1]=='status':
		status(sys.argv[2])
	elif sys.argv[1]=='balance':
		balance(sys.argv[2])
	elif sys.argv[1]=='nonce':
		nonce(sys.argv[2])
	elif sys.argv[1]=='raw':
		raw(sys.argv[2])
	elif sys.argv[1]=='height':
                height(sys.argv[2])
	elif sys.argv[1]=='nrStart':
		nrStart(sys.argv[2])
	elif sys.argv[1]=='nrEnd':
		nrEnd(sys.argv[2])
	elif sys.argv[1]=='nrid':
		nrid(sys.argv[2])
	elif sys.argv[1]=='getNrId':
		getNrId(sys.argv[2:])
	elif sys.argv[1]=='checkErr':
		getNrId(sys.argv[2])
	elif sys.argv[1]=='checkNrId':
		checkNrIdCompared()
	elif sys.argv[1]=='checkNrResult':
		checkNrResultCompared()
	elif sys.argv[1]=='checkDipNow':
		checkDipNowCompared()
	elif sys.argv[1]=='checkDipRandom':
		checkDipRandomCompared()
	else:
		print 'error'
         
