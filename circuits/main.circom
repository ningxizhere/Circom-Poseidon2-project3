pragma circom 2.1.5;

include "poseidon2.circom";

// 本模板用于证明一个 Poseidon2 哈希原像的知识
template Main() {
    // --- 输入信号 ---
    // 私有输入: 需要被哈希的值
    signal input preimage;
    // 公开输入: 期望得到的哈希结果
    signal input publicHash;

    // --- 组件实例化 ---
    // 实例化 Poseidon2 哈希器。
    // 注意：所有参数 (t, R_F, R_P) 现已在 poseidon2.circom 内部硬编码。
    component hasher = Poseidon2();

    // --- 逻辑与约束 ---
    // 1. 准备哈希器的输入。
    // 对于单个元素的输入，状态为 [preimage, 0, 0]。
    hasher.input[0] <== preimage;
    hasher.input[1] <== 0;
    hasher.input[2] <== 0;

    // 2. 添加核心约束。
    // 约束计算出的哈希值（hasher的第一个输出）必须等于公开的哈希值。
    publicHash === hasher.output[0];
}

// 实例化主组件，并声明 publicHash 是一个公开输入。
component main { public [ publicHash ] } = Main();