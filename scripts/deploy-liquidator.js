/**
 * @dev Interactive script to deploy a Liquidator contract
 */

const Liquidator = artifacts.require("Liquidator");
const IERC20 = artifacts.require("IERC20");

module.exports = async (callback) => {
  try {
    console.log(`Deploying Liquidator Contract...`);
    let LiquidatorC = await Liquidator.new();

    console.log(`\nLiquidator deployed at: ${LiquidatorC.address}\n`);

    callback();
  } catch (err) {
    callback(err);
  }
};
