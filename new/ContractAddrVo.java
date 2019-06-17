package io.nebulas.explorer.model.vo;

import io.nebulas.explorer.domain.NebAddress;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.ToString;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

/**
 * Address View
 *
 * @author zgy
 * @version 1.0
 * @since 2019-06-17
 */
@Data
@ToString
public class ContractAddrVo implements Serializable {
    private String hash;
    private String alias;
    private String balance;
    private Integer type;
    private Date createdAt;

    public ContractAddrVo() {
    }
    public ContractAddrVo(String hash) {
        this.hash = hash;
    }

    public ContractAddrVo build(NebAddress address) {
        this.hash = address.getHash();
        this.alias = address.getAlias();
        this.balance = address.getCurrentBalance().toPlainString();
        this.type = address.getType();
        this.createdAt = new Date(address.getCreatedAt().getTime());

        return this;
    }
}

