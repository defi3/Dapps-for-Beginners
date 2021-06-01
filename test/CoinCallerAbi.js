
const MetaCoin = artifacts.require("./MetaCoin.sol");
const CoinCallerAbi = artifacts.require("./CoinCallerAbi.sol");

contract("CoinCallerAbi", (accounts) => {
  it("deploy new contracts", async () => {
    this.coin = await MetaCoin.new(accounts[0]);
    this.caller = await CoinCallerAbi.new(this.coin.address);
  });

  it("check account balance", async () => {
    balance = await this.coin.balanceOf(accounts[0]);
    assert.equal(balance, 10000, "accounts[0]'s balance should be 10000");

    balance = await this.coin.balanceOf(accounts[1]);
    assert.equal(balance, 0, "accounts[1]'s balance should be 0");

    balance = await this.coin.balanceOf(this.caller.address);
    assert.equal(balance, 0, "caller's balance should be 0");
  });

  it("should transfer amount correctly", async () => {
    await this.coin.transfer(this.caller.address, 100, { from: accounts[0] });

    balance = await this.coin.balanceOf(accounts[0]);
    assert.equal(balance, 9900, "accounts[0]'s balance should be 9900");

    balance = await this.coin.balanceOf(accounts[1]);
    assert.equal(balance, 0, "accounts[1]'s balance should be 0");

    balance = await this.coin.balanceOf(this.caller.address);
    assert.equal(balance, 100, "caller's balance should be 100");
  });

  it("should transfer amount correctly", async () => {
    await this.caller.transfer(accounts[1], 10, { from: accounts[0] });

    balance = await this.coin.balanceOf(accounts[0]);
    assert.equal(balance, 9900, "accounts[0]'s balance should be 9900");

    balance = await this.coin.balanceOf(accounts[1]);
    assert.equal(balance, 10, "accounts[1]'s balance should be 10");

    balance = await this.coin.balanceOf(this.caller.address);
    assert.equal(balance, 90, "caller's balance should be 90");
  });

  it("check account allowance", async () => {
    amount = await this.coin.allowance(accounts[0], this.caller.address);
    assert.equal(amount, 0, "accounts[0] approves caller to transfer up to 0");

    amount = await this.coin.allowance(this.caller.address, accounts[0]);
    assert.equal(amount, 0, "caller approves accounts[0] to transfer up to 0");
  });

  it("should approve amount correctly", async () => {
    await this.coin.approve(this.caller.address, 100, { from: accounts[0] });

    amount = await this.coin.allowance(accounts[0], this.caller.address);
    assert.equal(amount, 100, "accounts[0] approves caller to transfer up to 100");
  });

  it("should transferFrom amount correctly", async () => {
    await this.caller.transferFrom(accounts[0], accounts[1], 10, { from: accounts[0] });

    balance = await this.coin.balanceOf(accounts[0]);
    assert.equal(balance, 9890, "accounts[0]'s balance should be 9890");

    balance = await this.coin.balanceOf(accounts[1]);
    assert.equal(balance, 20, "accounts[1]'s balance should be 20");

    balance = await this.coin.balanceOf(this.caller.address);
    assert.equal(balance, 90, "caller's balance should be 90");
  });
});


