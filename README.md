# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.ts
```

## 基础准备：V3 的流动性模型

### 1. 恒定乘积公式的变形
Uniswap V3 使用以下形式的恒定乘积公式：
```
x × y = L²
```
其中：
- `x`: token0 的数量
- `y`: token1 的数量  
- `L`: 流动性值

### 2. 价格与平方根价格的关系
在 V3 中，价格 P 定义为：
```
P = y/x
```
而平方根价格为：
```
√P = √(y/x)
```

## 公式推导过程

### 步骤 1: 从恒定乘积公式出发

我们有：
```
x × y = L²
```

用价格 P 表示：
```
x × (P × x) = L²
P × x² = L²
x² = L² / P
x = L / √P
```

**关键公式 1**:
```
x = L / √P
```

### 步骤 2: 考虑价格区间的影响

在价格区间 [P_a, P_b] 内，token0 的数量变化为：
```
Δx = x_at_P_b - x_at_P_current
```

代入公式 1:
```
Δx = (L / √P_b) - (L / √P)
```

### 步骤 3: 提取公因子 L

```
Δx = L × (1/√P_b - 1/√P)
```

由于我们通常关心的是**提供的数量**（正值），调整符号：
```
Δx = L × (1/√P - 1/√P_b)
```

**最终公式**:
```
Δx = L × (1/√P - 1/√P_b)
```

## 几何解释

### 在 xy = k 曲线上的可视化

```
y
│
│    ● 当前点 (x, y) 在 P = y/x
│   /
│  /
│ / 
│/ 
└─────────── x
```

当价格从 P 移动到 P_b 时，我们在曲线上移动，x 坐标的变化量就是 Δx。

### 积分解释

token0 的数量 x 可以看作是流动性 L 对 1/√P 的积分：

```
x = ∫ L × d(1/√P)
```

在离散情况下：
```
Δx = L × Δ(1/√P) = L × (1/√P - 1/√P_b)
```

## 实际计算示例

### 场景设定
- 当前价格: P = 2500 USDC/ETH
- 区间上限: P_b = 2000 USDC/ETH  
- 流动性: L = 1000

### 计算过程
```
√P = √2500 = 50
√P_b = √2000 ≈ 44.721

Δx = 1000 × (1/44.721 - 1/50)
   = 1000 × (0.02236 - 0.02)
   = 1000 × 0.00236
   = 2.36 ETH
```

## 与其他公式的关系

### 对应的 token1 公式
类似地，可以推导出 token1 的公式：
```
Δy = L × (√P - √P_a)
```

### 完整流动性提供公式
当当前价格在区间 [P_a, P_b] 内时：
```
Δx = L × (1/√P - 1/√P_b)
Δy = L × (√P - √P_a)
```

## 数学验证

### 验证 1: 维度检查
- L: 流动性（无单位标量）
- 1/√P: 1/√(token1/token0) = √(token0/token1)
- Δx: token0 数量
- 维度一致 ✓

### 验证 2: 边界情况
- 当 P = P_b 时：Δx = L × (1/√P_b - 1/√P_b) = 0 ✓
- 当 P → ∞ 时：1/√P → 0，Δx = L × (0 - 1/√P_b) = -L/√P_b ✓

## 物理意义

这个公式本质上描述了：
- **流动性密度**: L 衡量了在价格区间内的流动性"浓度"
- **价格敏感性**: 1/√P 项反映了 token0 数量对价格的敏感度
- **区间边界效应**: P_b 作为上限，限制了 token0 的最大需求

这个推导展示了 Uniswap V3 如何将传统的恒定乘积模型扩展为**分段常数流动性**模型，这是其资本效率提升的数学基础。