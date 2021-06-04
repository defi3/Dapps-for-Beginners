/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/test/Market_tests.js
 * 
 *  @Author defi3
 * 
 */

const Token = artifacts.require("./token/FaucetToken.sol");
const Market = artifacts.require("./lend/Market.sol");
const Controller = artifacts.require('./lend/Controller.sol');

contract("Market", (accounts) => {
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

  it("check original state of market", async () => {
    assert.equal(await this.market.FACTOR(), 1e18);

    assert.equal(await this.market.owner(), alice);

    assert.equal(await this.market.utilizationRate(0, 0, 0), 0);
    assert.equal(await this.market.utilizationRate(1000, 1000, 0), FACTOR / 2);
    assert.equal(await this.market.utilizationRate(2000, 1000, 1000), FACTOR / 2);
  });

  it("check original state of market 2", async () => {
    assert.equal(await this.market2.FACTOR(), 1e18);

    assert.equal(await this.market2.owner(), bob);

    assert.equal(await this.market2.utilizationRate(0, 0, 0), 0);
    assert.equal(await this.market2.utilizationRate(1000, 1000, 0), FACTOR / 2);
    assert.equal(await this.market2.utilizationRate(2000, 1000, 1000), FACTOR / 2);
  });

  it("set controller", async () => {
    await this.controller.setCollateralFactor(1 * MANTISSA, { from: alice });
    await this.controller.setLiquidationFactor(MANTISSA / 2, { from: alice });

    await this.market.setController(this.controller.address, { from: alice });
    await this.market2.setController(this.controller.address, { from: bob });

    await this.controller.addMarket(this.market.address, { from: alice });
    await this.controller.addMarket(this.market2.address, { from: alice });

    await this.controller.setPrice(this.market.address, 1, { from: alice });
    await this.controller.setPrice(this.market2.address, 2, { from: alice });
  });

  it("check initial state of market", async () => {
    assert.equal(await this.market.supplyOf(alice), 0);
    assert.equal(await this.market.supplyOf(bob), 0);
    assert.equal(await this.market.supplyOf(charlie), 0);

    assert.equal(await this.market.borrowBy(alice), 0);
    assert.equal(await this.market.borrowBy(bob), 0);
    assert.equal(await this.market.borrowBy(charlie), 0);

    assert.equal(await this.token.balanceOf(this.market.address), 0);
    assert.equal(await this.market.totalSupply(), 0);
    assert.equal(await this.market.balance(), 0);

    assert.equal(await this.market.supplyIndex(), FACTOR);
    assert.equal(await this.market.borrowIndex(), FACTOR);

    assert.equal(await this.market.baseBorrowRate(), FACTOR / 1000);
    assert.equal(await this.market.borrowRatePerBlock(), FACTOR / 1000);
    assert.equal(await this.market.supplyRatePerBlock(), 0);

    assert.ok((await this.market.accrualBlockNumber()) > 0);

    assert.equal(await this.market.borrowBy(alice), 0);
    assert.equal(await this.market.borrowBy(bob), 0);
    assert.equal(await this.market.borrowBy(charlie), 0);

    assert.equal(await this.market.updatedBorrowBy(alice), 0);
    assert.equal(await this.market.updatedBorrowBy(bob), 0);
    assert.equal(await this.market.updatedBorrowBy(charlie), 0);
  });

  it("check initial state of market 2", async () => {
    assert.equal(await this.market2.supplyOf(alice), 0);
    assert.equal(await this.market2.supplyOf(bob), 0);
    assert.equal(await this.market2.supplyOf(charlie), 0);

    assert.equal(await this.market2.borrowBy(alice), 0);
    assert.equal(await this.market2.borrowBy(bob), 0);
    assert.equal(await this.market2.borrowBy(charlie), 0);

    assert.equal(await this.token2.balanceOf(this.market2.address), 0);
    assert.equal(await this.market2.totalSupply(), 0);
    assert.equal(await this.market2.balance(), 0);

    assert.equal(await this.market2.supplyIndex(), FACTOR);
    assert.equal(await this.market2.borrowIndex(), FACTOR);

    assert.equal(await this.market2.baseBorrowRate(), FACTOR / 1000);
    assert.equal(await this.market2.borrowRatePerBlock(), FACTOR / 1000);
    assert.equal(await this.market2.supplyRatePerBlock(), 0);

    assert.ok((await this.market2.accrualBlockNumber()) > 0);

    assert.equal(await this.market2.borrowBy(alice), 0);
    assert.equal(await this.market2.borrowBy(bob), 0);
    assert.equal(await this.market2.borrowBy(charlie), 0);

    assert.equal(await this.market2.updatedBorrowBy(alice), 0);
    assert.equal(await this.market2.updatedBorrowBy(bob), 0);
    assert.equal(await this.market2.updatedBorrowBy(charlie), 0);
  });

  it('alice supply token', async () => {
    await this.token.approve(this.market.address, 1000, { from: alice });
    const supplyResult = await this.market.supply(1000, { from: alice });

    assert.ok(supplyResult);
    assert.ok(supplyResult.logs);
    assert.equal(supplyResult.logs.length, 1);

    // console.log(supplyResult.logs[0]);

    assert.equal(supplyResult.logs[0].event, 'Supply');
    assert.equal(supplyResult.logs[0].address, this.market.address);
    assert.equal(supplyResult.logs[0].args.user, alice);
    assert.equal(supplyResult.logs[0].args.amount, 1000);

    const supply = await this.market.supplyOf(alice);
    assert.equal(supply, 1000);

    const totalSupply = await this.market.totalSupply();
    assert.equal(totalSupply, 1000);

    balance = await this.token.balanceOf(alice);
    assert.equal(balance, 1e6 - 1000);

    balance = await this.token.balanceOf(this.market.address);
    assert.equal(balance, 1000);

    balance = await this.market.balance();
    assert.equal(balance, 1000);
  });

  it('alice redeem token', async () => {
    const redeemResult = await this.market.redeem(500, { from: alice });

    assert.ok(redeemResult);
    assert.ok(redeemResult.logs);
    assert.equal(redeemResult.logs.length, 1);
    assert.equal(redeemResult.logs[0].event, 'Redeem');
    assert.equal(redeemResult.logs[0].address, this.market.address);
    assert.equal(redeemResult.logs[0].args.user, alice);
    assert.equal(redeemResult.logs[0].args.amount, 500);

    const supply = await this.market.supplyOf(alice);
    assert.equal(supply, 1000 - 500);

    const totalSupply = await this.market.totalSupply();
    assert.equal(totalSupply, 1000 - 500);

    balance = await this.token.balanceOf(alice);
    assert.equal(balance, 1e6 - 1000 + 500);

    balance = await this.token.balanceOf(this.market.address);
    assert.equal(balance, 1000 - 500);

    balance = await this.market.balance();
    assert.equal(balance, 1000 - 500);
  });

  it('bob supply token2', async () => {
    await this.token2.approve(this.market2.address, 1000, { from: bob });
    const supplyResult = await this.market2.supply(1000, { from: bob });

    assert.ok(supplyResult);
    assert.ok(supplyResult.logs);
    assert.equal(supplyResult.logs.length, 1);
    assert.equal(supplyResult.logs[0].event, 'Supply');
    assert.equal(supplyResult.logs[0].address, this.market2.address);
    assert.equal(supplyResult.logs[0].args.user, bob);
    assert.equal(supplyResult.logs[0].args.amount, 1000);

    const supply = await this.market2.supplyOf(bob);
    assert.equal(supply, 1000);

    const totalSupply = await this.market2.totalSupply();
    assert.equal(totalSupply, 1000);

    balance = await this.token2.balanceOf(bob);
    assert.equal(balance, 1e6 - 1000);

    balance = await this.token2.balanceOf(this.market2.address);
    assert.equal(balance, 1000);

    balance = await this.market2.balance();
    assert.equal(balance, 1000);
  });

  it('bob redeem token2', async () => {
    const redeemResult = await this.market2.redeem(300, { from: bob });

    assert.ok(redeemResult);
    assert.ok(redeemResult.logs);
    assert.equal(redeemResult.logs.length, 1);
    assert.equal(redeemResult.logs[0].event, 'Redeem');
    assert.equal(redeemResult.logs[0].address, this.market2.address);
    assert.equal(redeemResult.logs[0].args.user, bob);
    assert.equal(redeemResult.logs[0].args.amount, 300);

    const supply = await this.market2.supplyOf(bob);
    assert.equal(supply, 1000 - 300);

    const totalSupply = await this.market2.totalSupply();
    assert.equal(totalSupply, 1000 - 300);

    balance = await this.token2.balanceOf(bob);
    assert.equal(balance, 1e6 - 1000 + 300);

    balance = await this.token2.balanceOf(this.market2.address);
    assert.equal(balance, 1000 - 300);

    balance = await this.market2.balance();
    assert.equal(balance, 1000 - 300);
  });

  it('alice borrow token2', async () => {
    const borrowResult = await this.market2.borrow(100, { from: alice });

    assert.ok(borrowResult);
    assert.ok(borrowResult.logs);
    assert.ok(borrowResult.logs.length);
    assert.equal(borrowResult.logs[0].event, 'Borrow');
    assert.equal(borrowResult.logs[0].address, this.market2.address);
    assert.equal(borrowResult.logs[0].args.user, alice);
    assert.equal(borrowResult.logs[0].args.amount, 100);


    const totalBorrow = await this.market2.totalBorrow();
    assert.equal(totalBorrow, 100);

    const totalSupply = await this.market2.totalSupply();
    // console.log(totalSupply);
    assert.equal(totalSupply, 1000 - 300);

    balance = await this.market2.balance();
    assert.equal(balance, totalSupply - totalBorrow);			// 1000 - 300 - 100

    balance = await this.token2.balanceOf(this.market2.address);
    assert.equal(balance, totalSupply - totalBorrow);			// 1000 - 300 - 100


    const borrowed = await this.market2.borrowBy(alice);
    assert.equal(borrowed, 100);

    balance = await this.token2.balanceOf(alice);
    assert.equal(balance, 100);
  });
});


