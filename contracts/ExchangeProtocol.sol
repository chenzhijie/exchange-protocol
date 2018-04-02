pragma solidity ^0.4.16;


library Math {
    function max64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a >= b ? a : b;
    }

    function min64(uint64 a, uint64 b) internal pure returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}


contract ERC20Basic {
    using Math for uint256;
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract ExchangeProtocol {
    struct Token {
        address contractAddress;
        uint256 value;
    }

    struct Exchange {
        bytes32 fromId;
        bytes32 toId;
        address receiver;
        bytes32 lockKey;
        uint256 value;
        Token token;
    }
    
    // mapping user address to exchange count every block; to-do: empty mapping
    mapping (address => mapping (uint256 => uint64)) private countPerBlock;
    mapping (address => Exchange[]) private userExchanges;

    event Deposit(address sender, uint amount, bytes32 exchangeId);
    event Withdraw(string tag, address receiver, uint amount, bytes32 exchangeId);
    event Log(string tag, address receiver, bytes32 exchangeId, bytes32 toExchangeId);

    function () public payable {
        depositEth();
    }

    // deposit eth to contract
    function depositEth() public payable {
        require(msg.value > 0);
        Exchange memory ex;
        ex.fromId = genExchangeId();
        ex.value = msg.value;
        userExchanges[msg.sender].push(ex);
        Deposit(msg.sender, msg.value, ex.fromId);
    }

    // @params(_tokenAddr): token contract address
    function depositToken(address _tokenAddr, uint256 _tokenAmount) public returns(bytes32) {
        ERC20 token = ERC20(_tokenAddr);
        require(_tokenAmount > 0 && token.balanceOf(msg.sender) >= _tokenAmount);
        require(token.approve(this, _tokenAmount));
        require(token.transferFrom(msg.sender, this, _tokenAmount));
        // save the exchange 
        Exchange memory ex;
        ex.fromId = genExchangeId();
        ex.token = Token(_tokenAddr, _tokenAmount);
        userExchanges[msg.sender].push(ex);
        Deposit(msg.sender, _tokenAmount, ex.fromId);
        return ex.fromId;
    }
    
    // make pair of (fromId, toId), add lockKey
    function updateExchange(bytes32 _fromId, address _receiver, bytes32 _toId, string _lockKey) public {
        Exchange[] storage exs = userExchanges[msg.sender];
        for (uint i = exs.length - 1; i >= 0; i--) {
            Exchange storage ex = exs[i];
            if (ex.fromId == _fromId) {
                ex.toId = _toId;
                ex.receiver = _receiver;
                ex.lockKey = getEncryptKey(_lockKey);
                break;
            }
        }
        Log("0", ex.receiver, ex.fromId, ex.toId);
    }

    function withdraw(bytes32 _fromId, string _withdrawKey) public {
        require((bytes(_withdrawKey)).length > 0);
        Exchange[] storage exs = userExchanges[msg.sender];
        uint exchangeIndex;
        for (uint i = exs.length - 1; i >= 0; i--) {
            if (exs[i].fromId == _fromId) {
                exchangeIndex = i;
                break;
            }
        }
        Exchange storage myEx = exs[exchangeIndex];
        bytes32 encryptedKey = getEncryptKey(_withdrawKey);
        if (myEx.lockKey == encryptedKey) {
            withdrawFund(myEx, false);
            delete exs[exchangeIndex];
        } else {
            Exchange[] storage toExs = userExchanges[myEx.receiver];
            uint toExchangeIndex;
            for (uint j = toExs.length - 1; j >= 0; j--) {
                if (toExs[j].toId == _fromId && toExs[j].fromId == myEx.toId && encryptedKey == toExs[j].lockKey) {
                    toExchangeIndex = j;
                    break;
                }
            }
            withdrawFund(myEx, true);
            delete exs[exchangeIndex];
            Exchange storage toEx = exs[toExchangeIndex];
            withdrawFund(toEx, true);
            delete toExs[toExchangeIndex];
        }
    }

    function withdrawFund(Exchange _ex, bool isExchange) private {
        if (_ex.value > 0) {
            //withdraw eth
            address ethReceiver = isExchange ? _ex.receiver : msg.sender;
            ethReceiver.transfer(_ex.value);
            Withdraw("1", ethReceiver, _ex.value, _ex.fromId);
        } else if (_ex.token.value > 0) {
            //withdraw token
            address tokenReceiver = isExchange ? _ex.receiver : msg.sender;
            ERC20 token = ERC20(_ex.token.contractAddress);
            require(token.approve(tokenReceiver, _ex.token.value));
            require(token.transfer(tokenReceiver, _ex.token.value));
            Withdraw("2", tokenReceiver, _ex.token.value, _ex.fromId);
        }
    }

    function getEncryptKey(string _rawKey) private returns (bytes32) {
        return sha256(_rawKey);
    }

    function genExchangeId() private returns (bytes32) {
        uint64 count = countPerBlock[msg.sender][now];
        bytes32 exchangeId = sha256(msg.sender, now, count);
        require(containsId(exchangeId) == false);
        countPerBlock[msg.sender][now] = count++;
        return exchangeId;
    }

    function containsId (bytes32 _exchangeId) private view returns (bool) {
        Exchange[] storage exchanges = userExchanges[msg.sender];
        for (uint i = 0; i < exchanges.length; i++) {
            if (exchanges[i].fromId == _exchangeId) {
                return true;
            }
        }
        return false;
    }
  
}