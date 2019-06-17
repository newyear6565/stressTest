package io.nebulas.explorer.jobs;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import io.nebulas.explorer.config.YAMLConfig;
import io.nebulas.explorer.domain.BlockSyncRecord;
import io.nebulas.explorer.domain.NasAccount;
import io.nebulas.explorer.domain.NebAddress;
import io.nebulas.explorer.domain.NebBlock;
import io.nebulas.explorer.domain.NebTransaction;
import io.nebulas.explorer.enums.NebAddressTypeEnum;
import io.nebulas.explorer.enums.NebTransactionTypeEnum;
import io.nebulas.explorer.service.blockchain.*;
import io.nebulas.explorer.service.thirdpart.nebulas.NebApiServiceWrapper;
import io.nebulas.explorer.service.thirdpart.nebulas.bean.Block;
import io.nebulas.explorer.service.thirdpart.nebulas.bean.NebState;
import io.nebulas.explorer.service.thirdpart.nebulas.bean.Transaction;
import io.nebulas.explorer.util.BlockHelper;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.Base64;
import java.util.Date;
import java.util.Calendar;
import java.util.List;
import java.util.concurrent.TimeUnit;

import static com.alibaba.fastjson.JSON.toJSONString;

@Slf4j
@AllArgsConstructor
@Component
public class UpdataAddressInfo {
    private final NasAccountService nasAccountService;
    private final NebAddressService nebAddressService;
    private static final long i = 5;
    private static long k = 0;

    @Scheduled(cron = "55 59 23 * * ?")
    public void updataNasAccountInfo() {
        Calendar cal = Calendar.getInstance();
        cal.set(cal.get(Calendar.YEAR), cal.get(Calendar.MONTH), cal.get(Calendar.DAY_OF_MONTH), 0, 0, 0);
	cal.add(Calendar.DAY_OF_MONTH, 1);
        Date date = cal.getTime();

        NasAccount nasAccount = new NasAccount();
        nasAccount.setAddressCount((int)nebAddressService.countTotalAddressCnt());
        nasAccount.setContractCount((int)nebAddressService.countTotalContractAddrCnt());
        nasAccount.setTimestamp(date);
        nasAccount.setCreatedAt(date);
        nasAccount.setUpdatedAt(date);
        nasAccount.setAddressIncrement(0);
        nasAccount.setContractIncrement(0);
        nasAccountService.setNasAccountRecord(nasAccount);
        log.warn("## updata count");
    }
}
