/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/test/Controller_tests.js
 * 
 *  @Author defi3
 *
 *  tested on local Ganache
 * 
 */

const Token = artifacts.require("./token/ERC20/ERC20Faucet.sol");
const Market = artifacts.require("./lend/ERC20/ERC20MarketFloating.sol");
const Controller = artifacts.require('./lend/ERC20/ERC20ControllerFloating.sol');

contract("ERC20ControllerFloating", (accounts) => {
  const alice = accounts[0];
  const bob = accounts[1];
  const charlie = accounts[2];

  const DECIMALS = 6;
  const MANTISSA = 1e6;
  const FACTOR = 1e6;
  const INIT_AMOUNT = 1e6;

  const BLOCKS_PER_YEAR = 1e6;
  const ANNUAL_RATE = 1e9;			// FACTOR / 1000 * BLOCKS_PER_YEAR = 1e9
  const UTILIZATION_RATE_FRACTION = 1e9;	// FACTOR / 1000 * BLOCKS_PER_YEAR = 1e9

  before(async () => {
    this.token = await Token.new("DAI", "DAI", INIT_AMOUNT * MANTISSA, DECIMALS, { from: alice });
    this.market = await Market.new(this.token.address, 0, 2000 * MANTISSA, ANNUAL_RATE, BLOCKS_PER_YEAR, UTILIZATION_RATE_FRACTION, { from: alice });

    this.token2 = await Token.new("BAT", "BAT", INIT_AMOUNT * MANTISSA, DECIMALS, { from: bob });
    this.market2 = await Market.new(this.token2.address, 0, 2000 * MANTISSA, ANNUAL_RATE, BLOCKS_PER_YEAR, UTILIZATION_RATE_FRACTION, { from: alice });

    this.controller = await Controller.new({ from: alice });
  });

  after(async () => {
    await this.controller.terminate({ from: alice });

    await this.market.terminate({ from: alice });
    await this.token.terminate({ from: alice });

    await this.market2.terminate({ from: alice });
    await this.token2.terminate({ from: bob });
  });

  it("check original state", async () => {
    // Controller
    assert.equal(await this.controller.owner(), alice);

    assert.equal(await this.controller.collateralFactor(), 0);
    assert.equal(await this.controller.liquidationFactor(), 0);

    assert.equal(await this.controller.size(), 0);
    assert.equal(await this.controller.marketOf(this.token.address), 0);
    assert.equal(await this.controller.marketOf(this.token2.address), 0);

    // console.log(await this.controller.include(this.market.address));
    // assert.equal((await this.controller.include(this.market.address)).toBool(), false);
    // assert.equal((await this.controller.include(this.market2.address)).toBool(), false);

    // ERC20Controller
    assert.equal(await this.controller.MANTISSA(), MANTISSA);

    // Controllable
    assert.equal(await this.market.controller(), 0);
    assert.equal(await this.market2.controller(), 0);

    // ERC20Market
    assert.equal(await this.market.price(), 0);
    assert.equal(await this.market2.price(), 0);
  });

  it("initialize controller", async () => {
    try {
      await this.controller.setCollateralFactor(1 * MANTISSA, { from: bob });
    } catch (err) {
      console.log("only owner can set collateral factor");
    }

    await this.controller.setCollateralFactor(1 * MANTISSA, { from: alice });

    assert.equal(await this.controller.collateralFactor(), 1 * MANTISSA);


    try {
      await this.controller.setLiquidationFactor(MANTISSA / 2, { from: bob });
    } catch (err) {
      console.log("only owner can set liquidation factor");
    }

    await this.controller.setLiquidationFactor(MANTISSA / 2, { from: alice });

    assert.equal(await this.controller.liquidationFactor(), MANTISSA / 2);
  });

  it("set controller", async () => {
    try {
      await this.market.transferControllership(this.controller.address, { from: bob });
    } catch (err) {
      console.log("only owner can set controller");
    }

    try {
      await this.market2.transferControllership(this.controller.address, { from: bob });
    } catch (err) {
      console.log("only owner can set controller");
    }

    await this.market.transferControllership(this.controller.address, { from: alice });

    assert.equal(await this.market.controller(), this.controller.address);

    await this.market2.transferControllership(this.controller.address, { from: alice });

    assert.equal(await this.market2.controller(), this.controller.address);
  });

  it("add market", async () => {
    try {
      await this.controller.addMarket(this.market.address, { from: bob });
    } catch (err) {
      console.log("only owner can add market");
    }

    try {
      await this.controller.addMarket(this.market2.address, { from: bob });
    } catch (err) {
      console.log("only owner can add market");
    }


    await this.controller.addMarket(this.market.address, { from: alice });

    assert.equal(await this.controller.size(), 1);

    await this.controller.addMarket(this.market2.address, { from: alice });

    assert.equal(await this.controller.size(), 2);


    try {
      await this.controller.removeMarket(this.market.address, { from: bob });
    } catch (err) {
      console.log("only owner can remove market");
    }

    try {
      await this.controller.removeMarket(this.market2.address, { from: bob });
    } catch (err) {
      console.log("only owner can remove market 2");
    }

    
    await this.controller.removeMarket(this.market2.address, { from: alice });

    assert.equal(await this.controller.size(), 1);

    await this.controller.addMarket(this.market2.address, { from: alice });

    assert.equal(await this.controller.size(), 2);


    // ERC20Market
    await this.market.setPrice(1, { from: alice });
    assert.equal(await this.market.price(), 1);

    await this.market2.setPrice(2, { from: alice });
    assert.equal(await this.market2.price(), 2);
  });

  it("check initial accounts", async () => {
    values = await this.controller.accountValues(alice);
    assert.equal(values.supplyValue, 0);
    assert.equal(values.borrowValue, 0);

    values2 = await this.controller.accountValues(bob);
    assert.equal(values2.supplyValue, 0);
    assert.equal(values2.borrowValue, 0);

    res = await this.controller.accountHealth(alice);
    console.log("alice's health status: " + res.status + "\talice's health index: " + res.index);
    // assert.equal(await this.controller.accountHealth(alice), 0);

    res = await this.controller.accountHealth(bob);
    console.log("bob's health status: " + res.status + "\tbob's health index: " + res.index);
    // assert.equal(await this.controller.accountHealth(bob), 0);

    res = await this.controller.accountLiquidity(alice, this.market.address, 0);
    console.log("alice's liquidity status: " + res.status + "\talice's liquidity: " + res.liquidity_);
    
    res = await this.controller.accountLiquidity(bob, this.market2.address, 0);
    console.log("bob's liquidity status: " + res.status + "\tbob's liquidity: " + res.liquidity_);
  });

  it("check accounts after supply and borrow", async () => {
    await this.token.approve(this.market.address, 100 * FACTOR, { from: alice });
    await this.market.supply(100 * FACTOR, { from: alice });

    await this.token2.approve(this.market2.address, 1000 * FACTOR, { from: bob });
    await this.market2.supply(1000 * FACTOR, { from: bob });

    await this.market2.borrow(10 * FACTOR, { from: alice });

    values = await this.controller.accountValues(alice);
    console.log("alice's supply value: " + values.supplyValue.toNumber() + "\tborrowValue: " + values.borrowValue.toNumber());
    // assert.equal(values.supplyValue, 0);
    // assert.equal(values.borrowValue, 0);

    values2 = await this.controller.accountValues(bob);
    console.log("bob's supply value: " + values2.supplyValue.toNumber() + "\tborrowValue: " + values2.borrowValue.toNumber());
    // assert.equal(values2.supplyValue, 0);
    // assert.equal(values2.borrowValue, 0);

    res = await this.controller.accountHealth(alice);
    console.log("alice's health status: " + res.status + "\talice's health index: " + res.index);
    // assert.equal(await this.controller.accountHealth(alice), 0);

    res = await this.controller.accountHealth(bob);
    console.log("bob's health status: " + res.status + "\tbob's health index: " + res.index);
    // assert.equal(await this.controller.accountHealth(bob), 0);

    res = await this.controller.accountLiquidity(alice, this.market.address, 0);
    console.log("alice's liquidity status: " + res.status + "\talice's liquidity: " + res.liquidity_);
    
    res = await this.controller.accountLiquidity(bob, this.market2.address, 0);
    console.log("bob's liquidity status: " + res.status + "\tbob's liquidity: " + res.liquidity_);
  });
});


