module.exports = async ({getNamedAccounts, deployments}) => {
    const {deploy} = deployments;
    const {account0} = await getNamedAccounts();
    const BordToken = await deploy('BoardwalkToken', {
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

    await deploy("Setup",{
        from: account0,
        args: [TestToken1.address, BordToken.address, TestToken3.address],
        log: true,
    })

};