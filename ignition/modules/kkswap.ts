import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const kkswapModule = buildModule("kkswap", (m) => {
    const poolManager = m.contract("PoolManager");
    const swapRouter = m.contract("SwapRouter", [poolManager]);
    const positionManager = m.contract("PositionManager", [poolManager]);

    return { poolManager, swapRouter, positionManager };
});

export default kkswapModule;