/**
 *  Reference: https://github.com/ajlopez/DeFiProt/blob/master/test/Market_tests.js
 * 
 *  @Author defi3
 *
 *  tested on local Ganache
 * 
 */

const Token = artifacts.require("./token/ERC20/ERC20Faucet.sol");
const Market = artifacts.require("./lend/ERC20/SimpleERC20Market.sol");
const Controller = artifacts.require('./lend/ERC20/SimpleERC20Controller.sol');

contract("SimpleERC20Market", (accounts) => {
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
    this.market2 = await Market.new(this.token2.address, 0, 2000 * MANTISSA, { from: bob });

    this.controller = await Controller.new({ from: alice });
  });

  after(async () => {
    await this.controller.terminate({ from: alice });

    await this.market.terminate({ from: alice });
    await this.token.terminate({ from: alice });

    await this.market2.terminate({ from: bob });
    await this.token2.terminate({ from: bob });
  });

  it("check original state of market", async () => {
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

    // SimpleERC20Market
    assert.equal(await this.market.supplyOf(alice), 0);
    assert.equal(await this.market.borrowBy(alice), 0);

    assert.equal(await this.market.supplyOf(bob), 0);
    assert.equal(await this.market.borrowBy(bob), 0);
  });

  it("check original state of market2", async () => {
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

    // SimpleERC20Market
    assert.equal(await this.market2.supplyOf(alice), 0);
    assert.equal(await this.market2.borrowBy(alice), 0);

    assert.equal(await this.market2.supplyOf(bob), 0);
    assert.equal(await this.market2.borrowBy(bob), 0);
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

    // SimpleERC20Market
    assert.equal(await this.market.supplyOf(alice), 0);
    assert.equal(await this.market.borrowBy(alice), 0);

    assert.equal(await this.market.supplyOf(bob), 0);
    assert.equal(await this.market.borrowBy(bob), 0);
  });

  it("check initial state of market 2", async () => {
    // Market
    assert.equal(await this.token2.balanceOf(this.market2.address), 0);

    assert.equal(await this.market2.totalSupply(), 0);
    assert.equal(await this.market2.totalBorrow(), 0);

    // ERC20Market
    assert.equal(await this.market2.balance(), 0);

    // SimpleERC20Market
    assert.equal(await this.market2.supplyOf(alice), 0);
    assert.equal(await this.market2.borrowBy(alice), 0);

    assert.equal(await this.market2.supplyOf(bob), 0);
    assert.equal(await this.market2.borrowBy(bob), 0);
  });

  it('alice supply 1000 token', async () => {
    await this.token.approve(this.market.address, 1000 * MANTISSA, { from: alice });

    const supplyResult = await this.market.supply(1000 * MANTISSA, { from: alice });

    assert.ok(supplyResult);
    assert.ok(supplyResult.logs);
    assert.equal(supplyResult.logs.length, 1);
    // console.log(supplyResult.logs[0]);
    assert.equal(supplyResult.logs[0].event, 'Supply');
    assert.equal(supplyResult.logs[0].address, this.market.address);
    assert.equal(supplyResult.logs[0].args.user, alice);
    assert.equal(supplyResult.logs[0].args.amount, 1000 * MANTISSA);

    balanceOfAlice = await this.token.balanceOf(alice);
    assert.equal(balanceOfAlice, (INIT_AMOUNT - 1000) * MANTISSA);

    supplyOfAlice = await this.market.supplyOf(alice);
    assert.equal(supplyOfAlice, 1000 * MANTISSA);

    totalSupply = await this.market.totalSupply();
    assert.equal(totalSupply, 1000 * MANTISSA);

    balanceOfMarket = await this.token.balanceOf(this.market.address);
    assert.equal(balanceOfMarket, 1000 * MANTISSA);

    balanceOfMarket = await this.market.balance();
    assert.equal(balanceOfMarket, 1000 * MANTISSA);

    assert.equal(balanceOfAlice / MANTISSA + balanceOfMarket / MANTISSA, INIT_AMOUNT);
  });

  it('alice redeem 500 token', async () => {
    const redeemResult = await this.market.redeem(500 * MANTISSA, { from: alice });

    assert.ok(redeemResult);
    assert.ok(redeemResult.logs);
    assert.equal(redeemResult.logs.length, 1);
    assert.equal(redeemResult.logs[0].event, 'Redeem');
    assert.equal(redeemResult.logs[0].address, this.market.address);
    assert.equal(redeemResult.logs[0].args.user, alice);
    assert.equal(redeemResult.logs[0].args.amount, 500 * MANTISSA);

    balanceOfAlice = await this.token.balanceOf(alice);
    assert.equal(balanceOfAlice, (INIT_AMOUNT - 1000 + 500) * MANTISSA);

    supplyOfAlice = await this.market.supplyOf(alice);
    assert.equal(supplyOfAlice, (1000 - 500) * MANTISSA);

    totalSupply = await this.market.totalSupply();
    assert.equal(totalSupply, (1000 - 500) * MANTISSA);

    balanceOfMarket = await this.token.balanceOf(this.market.address);
    assert.equal(balanceOfMarket, (1000 - 500) * MANTISSA);

    balanceOfMarket = await this.market.balance();
    assert.equal(balanceOfMarket, (1000 - 500) * MANTISSA);

    assert.equal(balanceOfAlice / MANTISSA + balanceOfMarket / MANTISSA, INIT_AMOUNT);
  });

  it('bob supply 1000 token2', async () => {
    await this.token2.approve(this.market2.address, 1000 * MANTISSA, { from: bob });

    const supplyResult = await this.market2.supply(1000 * MANTISSA, { from: bob });

    assert.ok(supplyResult);
    assert.ok(supplyResult.logs);
    assert.equal(supplyResult.logs.length, 1);
    assert.equal(supplyResult.logs[0].event, 'Supply');
    assert.equal(supplyResult.logs[0].address, this.market2.address);
    assert.equal(supplyResult.logs[0].args.user, bob);
    assert.equal(supplyResult.logs[0].args.amount, 1000 * MANTISSA);

    balanceOfBob = await this.token2.balanceOf(bob);
    assert.equal(balanceOfBob, (INIT_AMOUNT - 1000) * MANTISSA);

    supplyOfBob = await this.market2.supplyOf(bob);
    assert.equal(supplyOfBob, 1000 * MANTISSA);

    totalSupply = await this.market2.totalSupply();
    assert.equal(totalSupply, 1000 * MANTISSA);

    balanceOfMarket2 = await this.token2.balanceOf(this.market2.address);
    assert.equal(balanceOfMarket2, 1000 * MANTISSA);

    balanceOfMarket2 = await this.market2.balance();
    assert.equal(balanceOfMarket2, 1000 * MANTISSA);

    assert.equal(balanceOfBob / MANTISSA + balanceOfMarket2 / MANTISSA, INIT_AMOUNT);
  });

  it('bob redeem 300 token2', async () => {
    const redeemResult = await this.market2.redeem(300 * MANTISSA, { from: bob });

    assert.ok(redeemResult);
    assert.ok(redeemResult.logs);
    assert.equal(redeemResult.logs.length, 1);
    assert.equal(redeemResult.logs[0].event, 'Redeem');
    assert.equal(redeemResult.logs[0].address, this.market2.address);
    assert.equal(redeemResult.logs[0].args.user, bob);
    assert.equal(redeemResult.logs[0].args.amount, 300 * MANTISSA);

    balanceOfBob = await this.token2.balanceOf(bob);
    assert.equal(balanceOfBob, (INIT_AMOUNT - 1000 + 300) * MANTISSA);

    supplyOfBob = await this.market2.supplyOf(bob);
    assert.equal(supplyOfBob, (1000 - 300) * MANTISSA);

    totalSupply = await this.market2.totalSupply();
    assert.equal(totalSupply, (1000 - 300) * MANTISSA);

    balanceOfMarket2 = await this.token2.balanceOf(this.market2.address);
    assert.equal(balanceOfMarket2, (1000 - 300) * MANTISSA);

    balanceOfMarket2 = await this.market2.balance();
    assert.equal(balanceOfMarket2, (1000 - 300) * MANTISSA);

    assert.equal(balanceOfBob / MANTISSA + balanceOfMarket2 / MANTISSA, INIT_AMOUNT);
  });

  it('alice borrow 100 token2', async () => {
    const borrowResult = await this.market2.borrow(100 * MANTISSA, { from: alice });

    assert.ok(borrowResult);
    assert.ok(borrowResult.logs);
    assert.ok(borrowResult.logs.length);
    assert.equal(borrowResult.logs[0].event, 'Borrow');
    assert.equal(borrowResult.logs[0].address, this.market2.address);
    assert.equal(borrowResult.logs[0].args.user, alice);
    assert.equal(borrowResult.logs[0].args.amount, 100 * MANTISSA);

    totalBorrow = await this.market2.totalBorrow();
    assert.equal(totalBorrow, 100 * MANTISSA);

    totalSupply = await this.market2.totalSupply();
    // console.log(totalSupply);
    assert.equal(totalSupply, (1000 - 300) * MANTISSA);

    balanceOfMarket2 = await this.market2.balance();
    assert.equal(balanceOfMarket2, totalSupply - totalBorrow);		// 1000 - 300 - 100

    balanceOfMarket2 = await this.token2.balanceOf(this.market2.address);
    assert.equal(balanceOfMarket2, totalSupply - totalBorrow);		// 1000 - 300 - 100


    borrowByAlice = await this.market2.borrowBy(alice);
    assert.equal(borrowByAlice, 100 * MANTISSA);

    balanceOfAlice = await this.token2.balanceOf(alice);
    assert.equal(balanceOfAlice, 100 * MANTISSA);


    balanceOfBob = await this.token2.balanceOf(bob);
    assert.equal(balanceOfBob, (INIT_AMOUNT - 1000 + 300) * MANTISSA);

    supplyOfBob = await this.market2.supplyOf(bob);
    assert.equal(supplyOfBob, (1000 - 300) * MANTISSA);


    assert.equal(balanceOfBob / MANTISSA + balanceOfMarket2 / MANTISSA + balanceOfAlice / MANTISSA, INIT_AMOUNT);
  });

  it('alice pay borrow 50 token2', async () => {
    await this.token2.approve(this.market2.address, 100 * MANTISSA, { from: alice });

    const result = await this.market2.payBorrow(50 * MANTISSA, { from: alice });

    assert.ok(result);
    assert.ok(result.logs);
    assert.ok(result.logs.length);
    assert.equal(result.logs[0].event, 'PayBorrow');
    assert.equal(result.logs[0].address, this.market2.address);
    assert.equal(result.logs[0].args.user, alice);
    assert.equal(result.logs[0].args.amount, 50 * MANTISSA);

    totalBorrow = await this.market2.totalBorrow();
    // console.log("total borrow: " + totalBorrow.toNumber() / MANTISSA);
    assert.equal(totalBorrow, (100 - 50) * MANTISSA);

    totalSupply = await this.market2.totalSupply();
    // console.log("total supply: " + totalSupply.toNumber() / MANTISSA);
    assert.equal(totalSupply, (1000 - 300) * MANTISSA);

    balanceOfMarket2 = await this.market2.balance();
    // console.log("market 2's balance: " + balanceOfMarket2.toNumber() / MANTISSA);
    assert.equal(balanceOfMarket2, totalSupply - totalBorrow);		

    balanceOfMarket2 = await this.token2.balanceOf(this.market2.address);
    // console.log("market 2's balance: " + balanceOfMarket2.toNumber() / MANTISSA);
    assert.equal(balanceOfMarket2, totalSupply - totalBorrow);		


    borrowByAlice = await this.market2.borrowBy(alice);
    // console.log("borrowed by alice: " + borrowByAlice.toNumber() / MANTISSA);
    assert.equal(borrowByAlice, (100 - 50) * MANTISSA);

    balanceOfAlice = await this.token2.balanceOf(alice);
    // console.log("alice's balance: " + balanceOfAlice.toNumber() / MANTISSA);
    assert.equal(balanceOfAlice, (100 - 50) * MANTISSA);


    balanceOfBob = await this.token2.balanceOf(bob);
    assert.equal(balanceOfBob, (INIT_AMOUNT - 1000 + 300) * MANTISSA);

    supplyOfBob = await this.market2.supplyOf(bob);
    assert.equal(supplyOfBob, (1000 - 300) * MANTISSA);


    assert.equal(balanceOfBob / MANTISSA + balanceOfMarket2 / MANTISSA + balanceOfAlice / MANTISSA, INIT_AMOUNT);
  });
});


