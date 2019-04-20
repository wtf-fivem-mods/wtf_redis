wtf_redis.js: redis/redis.js
	cd redis && npm run-script build
	-robocopy . //fivem.sszt.ml/server-data/resources/[wtf]/wtf_redis /MIR /FFT /Z /XA:H /W:5 \
		/XD .git \
			redis