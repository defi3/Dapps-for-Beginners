
const Token = artifacts.require("./token/FaucetToken.sol");
const Market = artifacts.require("./lend/Market.sol");
const Controller = artifacts.require('./lend/Controller.sol');

contract("Market", (accounts) => {
  const alice = accounts[0];
  const bob = accounts[1];
  const charlie = accounts[2];

  const MANTISSA = 1000000;
  const FACTOR = 1000000000000000000;
  const BLOCKS_PER_YEAR = 1000000;
  const ANNUAL_RATE = "1000000000000000000000"; // FACTOR / 1000 * BLOCKS_PER_YEAR
  const UTILIZATION_RATE_FRACTION = "1000000000000000000000"; // FACTOR / 1000 * BLOCKS_PER_YEAR

  it("initialize state", async () => {
    this.token = await Token.new("DAI", "DAI", 1000000, 0, { from: alice });
    this.market = await Market.new(this.token.address, ANNUAL_RATE, BLOCKS_PER_YEAR, UTILIZATION_RATE_FRACTION);

    this.token2 = await Token.new("BAT", "BAT", 1000000, 0, { from: bob });
    this.market2 = await Market.new(this.token2.address, ANNUAL_RATE, BLOCKS_PER_YEAR, UTILIZATION_RATE_FRACTION);

    this.controller = await Controller.new({ from: alice });
    await this.controller.setCollateralFactor(1 * MANTISSA);
    await this.controller.setLiquidationFactor(MANTISSA / 2);

    await this.controller.addMarket(this.market.address);
    await this.controller.addMarket(this.market2.address);
    await this.controller.setPrice(this.market.address, 1);
    await this.controller.setPrice(this.market2.address, 2);
  });
});


