/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/test/Controller_tests.js
 * 
 *  @Author defi3
 *
 *  tested on local Ganache
 * 
 */

const Token = artifacts.require("./token/ERC20/ERC20Faucet.sol");
const Market = artifacts.require("./lend/ERC20/SimpleERC20Market.sol");
const Controller = artifacts.require('./lend/ERC20/SimpleERC20Controller.sol');

contract("SimpleERC20Controller", (accounts) => {
  const alice = accounts[0];
  const bob = accounts[1];
  const charlie = accounts[2];

  const DECIMALS = 6;
  const MANTISSA = 1e6;
  const FACTOR = 1e6;
  const INIT_AMOUNT = 1e6;

  before(async () => {
    this.token = await Token.new("DAI", "DAI", INIT_AMOUNT * MANTISSA, DECIMALS, { from: alice });
    this.market = await Market.new(this.token.address, 0, 2000 * MANTISSA, { from: alice });

    this.token2 = await Token.new("BAT", "BAT", INIT_AMOUNT * MANTISSA, DECIMALS, { from: bob });
    this.market2 = await Market.new(this.token2.address, 0, 2000 * MANTISSA, { from: alice });

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

    assert.equal(await this.controller.MANTISSA(), MANTISSA);

    assert.equal(await this.controller.collateralFactor(), 0);
    assert.equal(await this.controller.liquidationFactor(), 0);

    assert.equal(await this.controller.size(), 0);
    assert.equal(await this.controller.marketOf(this.token.address), 0);
    assert.equal(await this.controller.marketOf(this.token2.address), 0);

    // Controllable
    assert.equal(await this.market.controller(), 0);
    assert.equal(await this.market2.controller(), 0);

    // ERC20Market
    assert.equal(await this.market.price(), 0);
    assert.equal(await this.market2.price(), 0);
  });

  it("initialize controller", async () => {
    // Controller
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
    // Market
    try {
      await this.market.setController(this.controller.address, { from: bob });
    } catch (err) {
      console.log("only owner can set controller");
    }

    try {
      await this.market2.setController(this.controller.address, { from: bob });
    } catch (err) {
      console.log("only owner can set controller");
    }

    await this.market.setController(this.controller.address, { from: alice });

    assert.equal(await this.market.controller(), this.controller.address);

    await this.market2.setController(this.controller.address, { from: alice });

    assert.equal(await this.market2.controller(), this.controller.address);
  });

  it("add market", async () => {
    // Controller
    try {
      await this.controller.addMarket(this.market.address, { from: bob });
    } catch (err) {
      console.log("only owner can add market");
    }

    try {
      await this.controller.addMarket(this.market2.address, { from: bob });
    } catch (err) {
      console.log("only owner can add market 2");
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
    try {
      await this.market.setPrice(1, { from: bob });
    } catch (err) {
      console.log("only owner can set price");
    }

    await this.market.setPrice(1, { from: alice });

    assert.equal(await this.market.price(), 1);


    try {
      await this.market2.setPrice(2, { from: bob });
    } catch (err) {
      console.log("only owner can set price");
    }

    await this.market2.setPrice(2, { from: alice });

    assert.equal(await this.market2.price(), 2);
  });

  it("check initial accounts", async () => {
    valuesOfAlice = await this.controller.accountValues(alice);
    assert.equal(valuesOfAlice.supplyValue, 0);
    assert.equal(valuesOfAlice.borrowValue, 0);

    valuesOfBob = await this.controller.accountValues(bob);
    assert.equal(valuesOfBob.supplyValue, 0);
    assert.equal(valuesOfBob.borrowValue, 0);

    healthOfAlice = await this.controller.accountHealth(alice);
    assert.equal(healthOfAlice.status, true);
    assert.equal(healthOfAlice.index, 0);

    healthOfBob = await this.controller.accountHealth(bob);
    assert.equal(healthOfBob.status, true);
    assert.equal(healthOfBob.index, 0);

    liquidityOfAlice = await this.controller.accountLiquidity(alice, this.market.address, 0);
    // console.log(liquidityOfAlice);
    assert.equal(liquidityOfAlice.status, true);
    assert.equal(liquidityOfAlice.liquidity_, 0);

    liquidityOfBob = await this.controller.accountLiquidity(bob, this.market2.address, 0);
    assert.equal(liquidityOfBob.status, true);
    assert.equal(liquidityOfBob.liquidity_, 0);
  });

  it("check accounts after supply and borrow", async () => {
    await this.token.approve(this.market.address, 100 * MANTISSA, { from: alice });
    await this.market.supply(100 * MANTISSA, { from: alice });

    await this.token2.approve(this.market2.address, 1000 * MANTISSA, { from: bob });
    await this.market2.supply(1000 * MANTISSA, { from: bob });

    await this.market2.borrow(10 * MANTISSA, { from: alice });

    valuesOfAlice = await this.controller.accountValues(alice);
    console.log("alice's supply value: " + (valuesOfAlice.supplyValue.toNumber() / MANTISSA) + "\tborrowValue: " + (valuesOfAlice.borrowValue.toNumber() / MANTISSA));
    // assert.equal(valuesOfAlice.supplyValue, 0);
    // assert.equal(valuesOfAlice.borrowValue, 0);

    valuesOfBob = await this.controller.accountValues(bob);
    console.log("bob's supply value: " + (valuesOfBob.supplyValue.toNumber() / MANTISSA) + "\tborrowValue: " + (valuesOfBob.borrowValue.toNumber() / MANTISSA));
    // assert.equal(valuesOfBob.supplyValue, 0);
    // assert.equal(valuesOfBob.borrowValue, 0);

    healthOfAlice = await this.controller.accountHealth(alice);
    console.log("alice's health status: " + healthOfAlice.status + "\thealth index: " + healthOfAlice.index / MANTISSA);
    // assert.equal(healthOfAlice.status, true);
    // assert.equal(healthOfAlice.index, 0);

    healthOfBob = await this.controller.accountHealth(bob);
    console.log("bob's health status: " + healthOfBob.status + "\thealth index: " + healthOfBob.index / MANTISSA);


    liquidityOfAlice = await this.controller.accountLiquidity(alice, this.market2.address, 30 * MANTISSA);
    console.log("alice's liquidity status: " + liquidityOfAlice.status + "\tliquidity: " + liquidityOfAlice.liquidity_ / MANTISSA);
    // assert.equal(liquidityOfAlice.status, true);
    // assert.equal(liquidityOfAlice.liquidity_, 0);

    liquidityOfBob = await this.controller.accountLiquidity(bob, this.market2.address, 1000 * MANTISSA);
    console.log("bob's liquidity status: " + liquidityOfBob.status + "\tliquidity: " + liquidityOfBob.liquidity_ / MANTISSA);
    // assert.equal(liquidityOfBob.status, true);
    // assert.equal(liquidityOfBob.liquidity_, 0);
  });
});


