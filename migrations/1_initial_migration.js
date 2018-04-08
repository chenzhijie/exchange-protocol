var Migrations = artifacts.require("./Migrations.sol");
var ExchangeProtocol = artifacts.require("./ExchangeProtocol.sol");
// var TestToken = artifacts.require("./TestToken.sol");
module.exports = function(deployer) {
  deployer.deploy(Migrations);
  deployer.deploy(ExchangeProtocol);
  // deployer.deploy(TestToken);
};
