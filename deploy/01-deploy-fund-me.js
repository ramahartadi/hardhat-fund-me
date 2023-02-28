// import

// function deployFunc() {
//     console.log("Hi")
// }

// module.exports.default = deployFunc

// module.exports = async (hre) => {
//     const { deployments, getNamedAccounts } = hre
const { networkConfig, developmentChains } = require("../helper-hardhat-config")
const { network } = require("hardhat")
const { verify } = require("../utils/verify")

module.exports = async ({ deployments, getNamedAccounts }) => {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    // const ethUsdPriceFeedAddress = networkConfig[chainId].ethUsdPriceFeed

    let ethUsdPriceFeedAddress
    if (developmentChains.includes(network.name)) {
        const MockV3Aggregator = await deployments.get("MockV3Aggregator")
        ethUsdPriceFeedAddress = MockV3Aggregator.address
    } else {
        ethUsdPriceFeedAddress = networkConfig[chainId].ethUsdPriceFeed
    }

    const args = [ethUsdPriceFeedAddress]
    const fundMe = await deploy("FundMe", {
        from: deployer,
        args: args,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        await verify(fundMe.address, args)
    }
    log("------------------------------------------")
}

module.exports.tags = ["all", "fundme"]
