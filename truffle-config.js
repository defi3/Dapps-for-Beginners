module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // for more about customizing your Truffle configuration!
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*", // Match any network id
      websockets: true
    }
  },

  // Configure your compilers
  compilers: {
    solc: {
      version: "0.8.0",
    }
  }
};
