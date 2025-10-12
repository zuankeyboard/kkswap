// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.24;
pragma abicoder v2;

import "./Factory.sol";
import "./interfaces/IPool.sol";
import "./interfaces/IPoolManager.sol";

contract PoolManager is Factory, IPoolManager {
    Pair[] public pairs;

    function getPairs() external view override returns (Pair[] memory) {
        // 返回有哪些交易对，DApp 和 getAllPools 会用到
        return pairs;
    }

    function getAllPools()
        external
        view
        override
        returns (PoolInfo[] memory poolsInfo)
    {
        // 遍历 pairs，获取当前有的所有的交易对
        // 然后调用 Factory 的 getPools 获取每个交易对的所有 pool
        // 然后获取每个 pool 的信息
        // 然后返回
        // 先 mock
        uint32 length = 0;
        // 先算一下大小，从 pools 获取
        for (uint32 i = 0; i < pairs.length; i++) {
            length += uint32(pools[pairs[i].token0][pairs[i].token1].length);
        }

        // 再填充数据
        poolsInfo = new PoolInfo[](length);
        uint256 index
        for (uint32 i = 0; i < pairs.length; i++) {
            address[] memory addresses = pools[pairs[i].token0][pairs[i].token1];
            for (uint32 j = 0; j < addresses.length; j++) {
                IPool pool = IPool(addresses[j]);
                poolsInfo[index] = PoolInfo({
                    token0: pool.token0(),
                    token1: pool.token1(),
                    index: j,
                    fee: pool.fee(),
                    feeProtocol: 0,
                    tickLower: pool.tickLower(),
                    tickUpper: pool.tickUpper(),
                    tick: pool.tick(),
                    sqrtPriceX96: pool.sqrtPriceX96()
                });
                index++;
            }
        }
        return poolsInfo;
    }

    function createAndInitializePoolIfNecessary(
        CreateAndInitializeParams calldata params
    ) external payable override returns (address poolAddress) {
        // 如果没有对应的 Pool 就创建一个 Pool
        // 创建成功后记录到 pairs 中
        require(params.token0 < params.token1);

        poolAddress = this.createPool(
            params.token0,
            params.token1,
            params.tickLower,
            params.tickUpper,
            params.fee
        );

        // 获取池子合约
        IPool pool = IPool(poolAddress);

        // 获取同一交易对的数量
        uint256 index = pools[pool.token0()][pool.token1()].length;

        // 新创建的池子，没有初始化价格，需要初始化价格
        if (pool.sqrtPriceX96() == 0) {
            pool.initialize(params.sqrtPriceX96);

            if (index == 1) {
                // 如果是第一次添加该交易对，需要记录下来
                pairs.push(
                    Pair({token0: pool.token0(), token1: pool.token1()})
                );
            }
        }
    }
}
