/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/test/Market_tests.js
 * 
 *  @Author defi3
 *
 *  tested on local Ganache
 * 
 */

const Token = artifacts.require("./token/ERC20/ERC20Faucet.sol");
const Market = artifacts.require("./lend/ERC20/ERC20MarketFloating.sol");
const Controller = artifacts.require('./lend/ERC20/ERC20ControllerFloating.sol');

contract("ERC20MarketFloating", (accounts) => {
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

  it("deploy contracts", async () => {
    this.token = await Token.new("DAI", "DAI", INIT_AMOUNT * MANTISSA, DECIMALS, { from: alice });
    this.market = await Market.new(this.token.address, 0, 2000 * MANTISSA, ANNUAL_RATE, BLOCKS_PER_YEAR, UTILIZATION_RATE_FRACTION, { from: alice });

    this.token2 = await Token.new("BAT", "BAT", INIT_AMOUNT * MANTISSA, DECIMALS, { from: bob });
    this.market2 = await Market.new(this.token2.address, 0, 2000 * MANTISSA, ANNUAL_RATE, BLOCKS_PER_YEAR, UTILIZATION_RATE_FRACTION, { from: bob });

    this.controller = await Controller.new({ from: alice });
  });

  it("check original state of market", async () => {
    // ERC20MarketFloating
    assert.equal(await this.market.FACTOR(), FACTOR);

    // Controllable
    assert.equal(await this.market.owner(), alice);
    assert.equal(await this.market.controller(), 0);

    // Market
    assert.equal(await this.market.token(), this.token.address);
    assert.equal(await this.token.balanceOf(this.market.address), 0);

    assert.equal(await this.market.totalSupply(), 0);
    assert.equal(await this.market.totalBorrow(), 0);

    // ERC20Market
    assert.equal(await this.market.balance(), 0);

    // ERC20MarketFloating
    assert.equal(await this.market.supplyOf(alice), 0);
    assert.equal(await this.market.borrowBy(alice), 0);

    assert.equal(await this.market.supplyOf(bob), 0);
    assert.equal(await this.market.borrowBy(bob), 0);

    assert.equal(await this.market.supplyRate(0, 0, 0), 0);
    assert.equal(await this.market.supplyRate(1000, 1000, 0), 1 / 2 * (FACTOR / 2 / 1000 + FACTOR / 1000));
    assert.equal(await this.market.supplyRate(2000, 1000, 1000), 1 / 2 * (FACTOR / 2 / 1000 + FACTOR / 1000));

    assert.equal(await this.market.borrowRate(0, 0, 0), FACTOR / 1000);
    assert.equal(await this.market.borrowRate(1000, 1000, 0), FACTOR / 2 / 1000 + FACTOR / 1000);
    assert.equal(await this.market.borrowRate(2000, 1000, 1000), FACTOR / 2 / 1000 + FACTOR / 1000);

    assert.equal(await this.market.utilizationRate(0, 0, 0), 0);
    assert.equal(await this.market.utilizationRate(1000, 1000, 0), FACTOR / 2);
    assert.equal(await this.market.utilizationRate(2000, 1000, 1000), FACTOR / 2);
  });

  it("check original state of market 2", async () => {
    // ERC20MarketFloating
    assert.equal(await this.market2.FACTOR(), FACTOR);

    // Controllable
    assert.equal(await this.market2.owner(), bob);
    assert.equal(await this.market2.controller(), 0);

    // Market
    assert.equal(await this.market2.token(), this.token2.address);
    assert.equal(await this.token2.balanceOf(this.market2.address), 0);

    assert.equal(await this.market2.totalSupply(), 0);
    assert.equal(await this.market2.totalBorrow(), 0);

    // ERC20Market
    assert.equal(await this.market2.balance(), 0);

    // ERC20MarketFloating
    assert.equal(await this.market2.supplyOf(alice), 0);
    assert.equal(await this.market2.borrowBy(alice), 0);

    assert.equal(await this.market2.supplyOf(bob), 0);
    assert.equal(await this.market2.borrowBy(bob), 0);

    assert.equal(await this.market2.supplyRate(0, 0, 0), 0);
    assert.equal(await this.market2.supplyRate(1000, 1000, 0), 1 / 2 * (FACTOR / 2 / 1000 + FACTOR / 1000));
    assert.equal(await this.market2.supplyRate(2000, 1000, 1000), 1 / 2 * (FACTOR / 2 / 1000 + FACTOR / 1000));

    assert.equal(await this.market2.borrowRate(0, 0, 0), FACTOR / 1000);
    assert.equal(await this.market2.borrowRate(1000, 1000, 0), FACTOR / 2 / 1000 + FACTOR / 1000);
    assert.equal(await this.market2.borrowRate(2000, 1000, 1000), FACTOR / 2 / 1000 + FACTOR / 1000);

    assert.equal(await this.market2.utilizationRate(0, 0, 0), 0);
    assert.equal(await this.market2.utilizationRate(1000, 1000, 0), FACTOR / 2);
    assert.equal(await this.market2.utilizationRate(2000, 1000, 1000), FACTOR / 2);
  });

  it("set controller", async () => {
    // Controller 
    await this.controller.setCollateralFactor(1 * MANTISSA, { from: alice });
    await this.controller.setLiquidationFactor(MANTISSA / 2, { from: alice });

    assert.equal(await this.controller.collateralFactor(), 1 * MANTISSA);
    assert.equal(await this.controller.liquidationFactor(), MANTISSA / 2);

    // Controllable
    await this.market.setController(this.controller.address, { from: alice });
    await this.market2.setController(this.controller.address, { from: bob });

    assert.equal(await this.market.controller(), this.controller.address);
    assert.equal(await this.market2.controller(), this.controller.address);

    // Controller
    await this.controller.addMarket(this.market.address, { from: alice });
    await this.controller.addMarket(this.market2.address, { from: alice });

    assert.equal(await this.controller.size(), 2);

    assert.equal(await this.controller.marketOf(this.token.address), this.market.address);
    assert.equal(await this.controller.marketOf(this.token2.address), this.market2.address);

    // ERC20Controller
    await this.controller.setPrice(this.market.address, 1, { from: alice });
    await this.controller.setPrice(this.market2.address, 2, { from: alice });

    assert.equal(await this.controller.priceOf(this.market.address), 1);
    assert.equal(await this.controller.priceOf(this.market2.address), 2);
  });

  it("check initial state of market", async () => {
    // Market
    assert.equal(await this.token.balanceOf(this.market.address), 0);

    assert.equal(await this.market.totalSupply(), 0);
    assert.equal(await this.market.totalBorrow(), 0);

    // ERC20Market
    assert.equal(await this.market.balance(), 0);

    // ERC20MarketFloating
    assert.equal(await this.market.supplyIndex(), FACTOR);
    assert.equal(await this.market.borrowIndex(), FACTOR);

    assert.equal(await this.market.baseBorrowRate(), FACTOR / 1000);
    assert.equal(await this.market.borrowRatePerBlock(), FACTOR / 1000);
    assert.equal(await this.market.supplyRatePerBlock(), 0);

    assert.equal(await this.market.supplyOf(alice), 0);
    assert.equal(await this.market.supplyOf(bob), 0);
    assert.equal(await this.market.supplyOf(charlie), 0);

    assert.equal(await this.market.borrowBy(alice), 0);
    assert.equal(await this.market.borrowBy(bob), 0);
    assert.equal(await this.market.borrowBy(charlie), 0);

    assert.ok((await this.market.accrualBlockNumber()) > 0);

    assert.equal(await this.market.updatedBorrowBy(alice), 0);
    assert.equal(await this.market.updatedBorrowBy(bob), 0);
    assert.equal(await this.market.updatedBorrowBy(charlie), 0);

    console.log("accrual block number end", (await this.market.accrualBlockNumber()).toNumber());
    console.log("current block number end", (await this.market.blockNumber()).toNumber());
  });

  it("check initial state of market 2", async () => {
    // Market
    assert.equal(await this.token2.balanceOf(this.market2.address), 0);

    assert.equal(await this.market2.totalSupply(), 0);
    assert.equal(await this.market2.totalBorrow(), 0);

    // ERC20Market
    assert.equal(await this.market2.balance(), 0);

    // ERC20MarketFloating
    assert.equal(await this.market2.supplyIndex(), FACTOR);
    assert.equal(await this.market2.borrowIndex(), FACTOR);

    assert.equal(await this.market2.baseBorrowRate(), FACTOR / 1000);
    assert.equal(await this.market2.borrowRatePerBlock(), FACTOR / 1000);
    assert.equal(await this.market2.supplyRatePerBlock(), 0);

    assert.equal(await this.market2.supplyOf(alice), 0);
    assert.equal(await this.market2.supplyOf(bob), 0);
    assert.equal(await this.market2.supplyOf(charlie), 0);

    assert.equal(await this.market2.borrowBy(alice), 0);
    assert.equal(await this.market2.borrowBy(bob), 0);
    assert.equal(await this.market2.borrowBy(charlie), 0);

    assert.ok((await this.market2.accrualBlockNumber()) > 0);

    assert.equal(await this.market2.borrowBy(alice), 0);
    assert.equal(await this.market2.borrowBy(bob), 0);
    assert.equal(await this.market2.borrowBy(charlie), 0);

    assert.equal(await this.market2.updatedBorrowBy(alice), 0);
    assert.equal(await this.market2.updatedBorrowBy(bob), 0);
    assert.equal(await this.market2.updatedBorrowBy(charlie), 0);

    console.log("accrual block number end", (await this.market2.accrualBlockNumber()).toNumber());
    console.log("current block number end", (await this.market2.blockNumber()).toNumber());
  });

  it('alice supply 1000 token', async () => {
    console.log("accrual block number begin", (await this.market.accrualBlockNumber()).toNumber());
    console.log("current block number begin", (await this.market.blockNumber()).toNumber());

    await this.token.approve(this.market.address, 1000 * FACTOR, { from: alice });


    console.log("accrual block number before supply", (await this.market.accrualBlockNumber()).toNumber());
    console.log("current block number before supply", (await this.market.blockNumber()).toNumber());

    const supplyResult = await this.market.supply(1000 * FACTOR, { from: alice });

    assert.ok(supplyResult);
    assert.ok(supplyResult.logs);
    assert.equal(supplyResult.logs.length, 1);
    // console.log(supplyResult.logs[0]);
    assert.equal(supplyResult.logs[0].event, 'Supply');
    assert.equal(supplyResult.logs[0].address, this.market.address);
    assert.equal(supplyResult.logs[0].args.user, alice);
    assert.equal(supplyResult.logs[0].args.amount, 1000 * FACTOR);

    console.log("accrual block number after supply", (await this.market.accrualBlockNumber()).toNumber());
    console.log("current block number after supply", (await this.market.blockNumber()).toNumber());


    balance = await this.token.balanceOf(alice);
    assert.equal(balance, (1e6 - 1000) * FACTOR);

    supply = await this.market.supplyOf(alice);
    assert.equal(supply, 1000 * FACTOR);

    updatedSupply = await this.market.updatedSupplyOf(alice);
    // console.log('updatedSupply', updatedSupply.toNumber());
    assert.equal(updatedSupply, 1000 * FACTOR);


    const totalSupply = await this.market.totalSupply();
    assert.equal(totalSupply, 1000 * FACTOR);

    balance = await this.token.balanceOf(this.market.address);
    assert.equal(balance, 1000 * FACTOR);

    balance = await this.market.balance();
    assert.equal(balance, 1000 * FACTOR);

    console.log("accrual block number end", (await this.market.accrualBlockNumber()).toNumber());
    console.log("current block number end", (await this.market.blockNumber()).toNumber());
  });

  it('alice redeem 500 token', async () => {
    console.log("accrual block number begin", (await this.market.accrualBlockNumber()).toNumber());
    console.log("current block number begin", (await this.market.blockNumber()).toNumber());

    const redeemResult = await this.market.redeem(500 * FACTOR, { from: alice });

    assert.ok(redeemResult);
    assert.ok(redeemResult.logs);
    assert.equal(redeemResult.logs.length, 1);
    assert.equal(redeemResult.logs[0].event, 'Redeem');
    assert.equal(redeemResult.logs[0].address, this.market.address);
    assert.equal(redeemResult.logs[0].args.user, alice);
    assert.equal(redeemResult.logs[0].args.amount, 500 * FACTOR);

    console.log("accrual block number after redeem", (await this.market.accrualBlockNumber()).toNumber());
    console.log("current block number after redeem", (await this.market.blockNumber()).toNumber());


    balance = await this.token.balanceOf(alice);
    assert.equal(balance, (1e6 - 1000 + 500) * FACTOR);

    supply = await this.market.supplyOf(alice);
    assert.equal(supply, (1000 - 500) * FACTOR);

    updatedSupply = await this.market.updatedSupplyOf(alice);
    console.log('updatedSupply', updatedSupply.toNumber() / FACTOR);
    // assert.equal(updatedSupply, 1000 * FACTOR);


    const totalSupply = await this.market.totalSupply();
    assert.equal(totalSupply, (1000 - 500) * FACTOR);

    balance = await this.token.balanceOf(this.market.address);
    assert.equal(balance, (1000 - 500) * FACTOR);

    balance = await this.market.balance();
    assert.equal(balance, (1000 - 500) * FACTOR);

    console.log("accrual block number end", (await this.market.accrualBlockNumber()).toNumber());
    console.log("current block number end", (await this.market.blockNumber()).toNumber());
  });

  it('bob supply 1000 token2', async () => {
    console.log("accrual block number begin", (await this.market2.accrualBlockNumber()).toNumber());
    console.log("current block number begin", (await this.market2.blockNumber()).toNumber());

    await this.token2.approve(this.market2.address, 1000 * FACTOR, { from: bob });


    console.log("accrual block number before supply", (await this.market2.accrualBlockNumber()).toNumber());
    console.log("current block number before supply", (await this.market2.blockNumber()).toNumber());

    const supplyResult = await this.market2.supply(1000 * FACTOR, { from: bob });

    assert.ok(supplyResult);
    assert.ok(supplyResult.logs);
    assert.equal(supplyResult.logs.length, 1);
    assert.equal(supplyResult.logs[0].event, 'Supply');
    assert.equal(supplyResult.logs[0].address, this.market2.address);
    assert.equal(supplyResult.logs[0].args.user, bob);
    assert.equal(supplyResult.logs[0].args.amount, 1000 * FACTOR);

    console.log("accrual block number after supply", (await this.market2.accrualBlockNumber()).toNumber());
    console.log("current block number after supply", (await this.market2.blockNumber()).toNumber());


    balance = await this.token2.balanceOf(bob);
    assert.equal(balance, (1e6 - 1000) * FACTOR);

    supply = await this.market2.supplyOf(bob);
    assert.equal(supply, 1000 * FACTOR);

    updatedSupply = await this.market2.updatedSupplyOf(bob);
    // console.log("bob's updatedSupply", updatedSupply.toNumber());
    assert.equal(updatedSupply, 1000 * FACTOR);


    const totalSupply = await this.market2.totalSupply();
    assert.equal(totalSupply, 1000 * FACTOR);

    balance = await this.token2.balanceOf(this.market2.address);
    assert.equal(balance, 1000 * FACTOR);

    balance = await this.market2.balance();
    assert.equal(balance, 1000 * FACTOR);

    console.log("accrual block number end" + (await this.market2.accrualBlockNumber()).toNumber());
    console.log("current block number end", (await this.market2.blockNumber()).toNumber());
  });

  it('bob redeem 300 token2', async () => {
    console.log("accrual block number begin", (await this.market2.accrualBlockNumber()).toNumber());
    console.log("current block number begin", (await this.market2.blockNumber()).toNumber());

    const redeemResult = await this.market2.redeem(300 * FACTOR, { from: bob });

    assert.ok(redeemResult);
    assert.ok(redeemResult.logs);
    assert.equal(redeemResult.logs.length, 1);
    assert.equal(redeemResult.logs[0].event, 'Redeem');
    assert.equal(redeemResult.logs[0].address, this.market2.address);
    assert.equal(redeemResult.logs[0].args.user, bob);
    assert.equal(redeemResult.logs[0].args.amount, 300 * FACTOR);

    console.log("accrual block number after redeem", (await this.market2.accrualBlockNumber()).toNumber());
    console.log("current block number after redeem", (await this.market2.blockNumber()).toNumber());


    balance = await this.token2.balanceOf(bob);
    assert.equal(balance, (1e6 - 1000 + 300) * FACTOR);

    supply = await this.market2.supplyOf(bob);
    assert.equal(supply, (1000 - 300) * FACTOR);

    updatedSupply = await this.market2.updatedSupplyOf(bob);
    // console.log("bob's updatedSupply", updatedSupply.toNumber());
    assert.equal(updatedSupply, (1000 - 300) * FACTOR);


    const totalSupply = await this.market2.totalSupply();
    assert.equal(totalSupply, (1000 - 300) * FACTOR);

    balance = await this.token2.balanceOf(this.market2.address);
    assert.equal(balance, (1000 - 300) * FACTOR);

    balance = await this.market2.balance();
    assert.equal(balance, (1000 - 300) * FACTOR);

    console.log("accrual block number end", (await this.market2.accrualBlockNumber()).toNumber());
    console.log("current block number end", (await this.market2.blockNumber()).toNumber());
  });

  it('alice borrow 100 token2', async () => {
    console.log("accrual block number begin", (await this.market2.accrualBlockNumber()).toNumber());
    console.log("current block number begin", (await this.market2.blockNumber()).toNumber());

    const borrowResult = await this.market2.borrow(100 * FACTOR, { from: alice });

    assert.ok(borrowResult);
    assert.ok(borrowResult.logs);
    assert.ok(borrowResult.logs.length);
    assert.equal(borrowResult.logs[0].event, 'Borrow');
    assert.equal(borrowResult.logs[0].address, this.market2.address);
    assert.equal(borrowResult.logs[0].args.user, alice);
    assert.equal(borrowResult.logs[0].args.amount, 100 * FACTOR);

    console.log("accrual block number after borrow" + (await this.market2.accrualBlockNumber()).toNumber());
    console.log("current block number after borrow", (await this.market2.blockNumber()).toNumber());


    const totalBorrow = await this.market2.totalBorrow();
    assert.equal(totalBorrow, 100 * FACTOR);

    const totalSupply = await this.market2.totalSupply();
    // console.log(totalSupply);
    assert.equal(totalSupply, (1000 - 300) * FACTOR);

    balance = await this.market2.balance();
    assert.equal(balance, totalSupply - totalBorrow);			// 1000 - 300 - 100

    balance = await this.token2.balanceOf(this.market2.address);
    assert.equal(balance, totalSupply - totalBorrow);			// 1000 - 300 - 100


    const borrowed = await this.market2.borrowBy(alice);
    assert.equal(borrowed, 100 * FACTOR);

    balance = await this.token2.balanceOf(alice);
    assert.equal(balance, 100 * FACTOR);


    balance = await this.token2.balanceOf(bob);
    assert.equal(balance, (1e6 - 1000 + 300) * FACTOR);

    supply = await this.market2.supplyOf(bob);
    assert.equal(supply, (1000 - 300) * FACTOR);

    updatedSupply = await this.market2.updatedSupplyOf(bob);
    // console.log("bob's updatedSupply", updatedSupply.toNumber());
    assert.equal(updatedSupply, (1000 - 300) * FACTOR);

    console.log("accrual block number end", (await this.market2.accrualBlockNumber()).toNumber());
    console.log("current block number end", (await this.market2.blockNumber()).toNumber());
  });

  it('alice pay borrow 50 token2', async () => {
    console.log("accrual block number begin", (await this.market2.accrualBlockNumber()).toNumber());
    console.log("current block number begin", (await this.market2.blockNumber()).toNumber());

    await this.token2.approve(this.market2.address, 100 * FACTOR, { from: alice });


    console.log("accrual block number before payBorrow", (await this.market2.accrualBlockNumber()).toNumber());
    console.log("current block number before payBorrow", (await this.market2.blockNumber()).toNumber());

    const result = await this.market2.payBorrow(50 * FACTOR, { from: alice });

    assert.ok(result);
    assert.ok(result.logs);
    assert.ok(result.logs.length);
    assert.equal(result.logs[0].event, 'PayBorrow');
    assert.equal(result.logs[0].address, this.market2.address);
    assert.equal(result.logs[0].args.user, alice);
    assert.equal(result.logs[0].args.amount, 50 * FACTOR);

    console.log("accrual block number after payBorrow", (await this.market2.accrualBlockNumber()).toNumber());
    console.log("current block number after payBorrow", (await this.market2.blockNumber()).toNumber());


    const totalBorrow = await this.market2.totalBorrow();
    console.log("total borrow: " + totalBorrow.toNumber() / FACTOR);
    assert.ok(totalBorrow > (100 - 50) * FACTOR);

    const totalSupply = await this.market2.totalSupply();
    console.log("total supply: " + totalSupply.toNumber() / FACTOR);
    assert.ok(totalSupply > (1000 - 300) * FACTOR);

    balance = await this.market2.balance();
    console.log("market 2's balance: " + balance.toNumber() / FACTOR);
    // assert.equal(balance, totalSupply - totalBorrow);		

    balance = await this.token2.balanceOf(this.market2.address);
    console.log("market 2's balance: " + balance.toNumber() / FACTOR);
    // assert.equal(balance, totalSupply - totalBorrow);		

    const borrowed = await this.market2.borrowBy(alice);
    console.log("borrowed by alice: " + borrowed.toNumber() / FACTOR);
    // assert.ok(borrowed > (100 - 50) * FACTOR);

    balance = await this.token2.balanceOf(alice);
    console.log("alice's balance: " + balance.toNumber() / FACTOR);
    // assert.ok(balance > (100 - 50) * FACTOR);

    console.log("accrual block number end", (await this.market2.accrualBlockNumber()).toNumber());
    console.log("current block number end", (await this.market2.blockNumber()).toNumber());
  });

  it('accrue interest in market', async () => {
    console.log("total borrow: " + (await this.market.totalBorrow()).toNumber() / FACTOR);
    console.log("borrow index: " + (await this.market.borrowIndex()).toNumber() / FACTOR);
    console.log("borrow rate: " + (await this.market.borrowRatePerBlock()).toNumber() / FACTOR);

    console.log("current block number before", (await this.market.blockNumber()).toNumber());
    console.log("accrual block number before", (await this.market.blockNumber()).toNumber());

    await this.market.accrueInterest();

    console.log("current block number after", (await this.market.blockNumber()).toNumber());
    console.log("accrual block number after", (await this.market.accrualBlockNumber()).toNumber());

    console.log("total borrow: ", (await this.market.totalBorrow()).toNumber() / FACTOR);
    console.log("borrow index: ", (await this.market.borrowIndex()).toNumber() / FACTOR);
    console.log("borrow rate: ", (await this.market.borrowRatePerBlock()).toNumber() / FACTOR);

    totalBorrow = (await this.market.totalBorrow()).toNumber() / FACTOR;
    borrowRate = (await this.market.borrowRatePerBlock()).toNumber() / FACTOR;
    simpleInterestFactor = borrowRate * 1;
    interestAccumulated = Math.floor(simpleInterestFactor * totalBorrow);
    console.log("totalBorrow: " + totalBorrow + "\tborrowRate: " + borrowRate + "\tsimpleInterestFactor: " + simpleInterestFactor + "\tinterestAccumulated: " + interestAccumulated);
  });

  it('accrue interest in market 2', async () => {
    console.log("total borrow: ", (await this.market2.totalBorrow()).toNumber() / FACTOR);
    console.log("borrow index: ", (await this.market2.borrowIndex()).toNumber() / FACTOR);
    console.log("borrow rate: ", (await this.market2.borrowRatePerBlock()).toNumber() / FACTOR);

    console.log("current block number before", (await this.market2.blockNumber()).toNumber());
    console.log("accrual block number before", (await this.market2.accrualBlockNumber()).toNumber());

    await this.market2.accrueInterest();

    console.log("current block number after", (await this.market2.blockNumber()).toNumber());
    console.log("accrual block number after", (await this.market2.accrualBlockNumber()).toNumber());

    console.log("total borrow: ", (await this.market2.totalBorrow()).toNumber() / FACTOR);
    console.log("borrow index: ", (await this.market2.borrowIndex()).toNumber() / FACTOR);
    console.log("borrow rate: ", (await this.market2.borrowRatePerBlock()).toNumber() / FACTOR);

    totalBorrow = (await this.market2.totalBorrow()).toNumber() / FACTOR;
    borrowRate = (await this.market2.borrowRatePerBlock()).toNumber() / FACTOR;
    simpleInterestFactor = borrowRate * 1;
    interestAccumulated = Math.floor(simpleInterestFactor * totalBorrow);
    console.log("totalBorrow: " + totalBorrow + "\tborrowRate: " + borrowRate + "\tsimpleInterestFactor: " + simpleInterestFactor + "\tinterestAccumulated: " + interestAccumulated);
  });

  it("alice liquidate bob's borrow", async () => {
    // TO-DO
  });

});


