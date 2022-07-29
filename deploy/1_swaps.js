module.exports = async ({getNamedAccounts, deployments}) => {
    const {deploy} = deployments;
    const {account0} = await getNamedAccounts();
    await deploy('Swaps', {
      from: account0,
    //   args: ,
      log: true,
    });
};