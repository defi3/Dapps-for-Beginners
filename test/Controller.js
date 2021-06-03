/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/test/Controller_tests.js
 * 
 *  @Author defi3
 * 
 */

const Token = artifacts.require("./token/FaucetToken.sol");
const Market = artifacts.require("./lend/Market.sol");
const Controller = artifacts.require('./lend/Controller.sol');

contract("Controller", (accounts) => {
  const alice = accounts[0];
  const bob = accounts[1];
  const charlie = accounts[2];

  const MANTISSA = 1e6;
  const FACTOR = 1e18;
  const BLOCKS_PER_YEAR = 1e6;
  const ANNUAL_RATE = "1000000000000000000000";	// FACTOR / 1000 * BLOCKS_PER_YEAR = 1e21
  const UTILIZATION_RATE_FRACTION = "1000000000000000000000";	// FACTOR / 1000 * BLOCKS_PER_YEAR = 1e21

  it("deploy contracts", async () => {
    this.token = await Token.new("DAI", "DAI", 1e6, 0, { from: alice });
    this.market = await Market.new(this.token.address, ANNUAL_RATE, BLOCKS_PER_YEAR, UTILIZATION_RATE_FRACTION, { from: alice });

    this.token2 = await Token.new("BAT", "BAT", 1e6, 0, { from: bob });
    this.market2 = await Market.new(this.token2.address, ANNUAL_RATE, BLOCKS_PER_YEAR, UTILIZATION_RATE_FRACTION, { from: bob });

    this.controller = await Controller.new({ from: alice });
  });

  it("check original state", async () => {
    assert.equal(await this.controller.MANTISSA(), MANTISSA);

    const owner = await this.controller.owner();
    // console.log(owner);
    assert.equal(owner, alice);

    const size = (await this.controller.marketListSize()).toNumber();
    // console.log(size);
    assert.equal(size, 0);


    const added = await this.controller.markets(this.market.address);
    // console.log(added);
    assert.ok(!added);

    const added2 = await this.controller.markets(this.market2.address);
    assert.ok(!added2);


    const marketAddress = await this.controller.marketsByToken(this.token.address);
    assert.equal(marketAddress, 0);

    const marketAddress2 = await this.controller.marketsByToken(this.token2.address);
    assert.equal(marketAddress2, 0);


    const price = await this.controller.prices(this.token.address);
    assert.equal(price, 0);

    const price2 = await this.controller.prices(this.token2.address);
    assert.equal(price2, 0);


    const controller = await this.market.controller();
    assert.equal(controller, 0);

    const controller2 = await this.market2.controller();
    assert.equal(controller2, 0);
  });

  it("initialize controller", async () => {
    await this.controller.setCollateralFactor(1 * MANTISSA);
    await this.controller.setLiquidationFactor(MANTISSA / 2);

    await this.controller.addMarket(this.market.address);
    await this.controller.addMarket(this.market2.address);

    await this.controller.setPrice(this.market.address, 1);
    await this.controller.setPrice(this.market2.address, 2);
  });

  it("set controller", async () => {
    try {
      await this.market.setController(this.controller.address, { from: bob });
    } catch (err) {
      console.log(err)
    }

    try {
      await this.market2.setController(this.controller.address, { from: alice });
    } catch (err) {
      console.log(err)
    }

    await this.market.setController(this.controller.address, { from: alice });

    const controller = await this.market.controller();
    assert.equal(controller, this.controller.address);

    await this.market2.setController(this.controller.address, { from: bob });

    const controller2 = await this.market2.controller();
    assert.equal(controller2, this.controller.address);
  });

  it("check initial state", async () => {
    const controller = await this.market.controller();
    assert.equal(controller, this.controller.address);

    const controller2 = await this.market2.controller();
    assert.equal(controller2, this.controller.address);

    const price = (await this.controller.prices(this.market.address)).toNumber();
    // console.log(price);
    assert.equal(price, 1);

    const price2 = (await this.controller.prices(this.market2.address)).toNumber();
    // console.log(price2);
    assert.equal(price2, 2);
  });
});


