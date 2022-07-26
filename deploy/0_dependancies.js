module.exports = async ({getNamedAccounts, deployments}) => {
    const {deploy} = deployments;
    const {account0, account1} = await getNamedAccounts();
    await deploy('BoardwalkToken', {
      from: account0,
      args: [],
      log: true,
    });

    const TestToken1 = await deploy('StableCoin', {
        from: account0,
        args: ["USDC","USDC"],
        log: true,
        contract: "TestToken"
    });

    const TestToken2 = await deploy('StreamCoin', {
        from: account0,
        args: ["xUSDC","xUSDC"],
        log: true,
        contract: "TestToken"
    });

    const TestToken3 = await deploy('Asset', {
        from: account0,
        args: ["Asset","WETH"],
        log: true,
        contract: "TestToken"
    });

};