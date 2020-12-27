pragma solidity ^0.6.0;

import "../token/ERC20/ERC20.sol";

contract SaleContract {
    address owner;
    uint256 RecvedEther;
    uint256 SendedEther;
    uint256 public TokenRatio;

    // TokenWalletAddress must be holds ERC20 deployed wallet address
    address public TokenWalletAddress;
    // TokenContractAddress must be holds ERC20 deployed address
    address public TokenContractAddress;

    IERC20 Token;

    constructor(address WalletAddress, address ContractAddress) public {
        owner = msg.sender;
        RecvedEther = 0;
        SendedEther = 0;
        TokenRatio = 1;

        TokenWalletAddress = WalletAddress;
        TokenContractAddress = ContractAddress;
        Token = IERC20(TokenContractAddress);
    }

    uint256 public AllowedAmount = 0;

    function IsOwner() private view returns (bool) {
        if (msg.sender == owner) {
            return true;
        } else {
            return false;
        }
    }

    function TokenTransferFrom(
        address Sender,
        address Recver,
        uint256 TokenCount
    ) private {
        Token.transferFrom(Sender, Recver, TokenCount);
    }

    function GetAllowedAmount() public returns (uint256) {
        AllowedAmount = Token.allowance(msg.sender, address(this));

        return AllowedAmount;
    }

    mapping(address => uint256) CurrentRecvEther;

    // move token in the admin wallet to buyer
    function EtherToToken(address recver) public payable {
        require(Token.balanceOf(TokenWalletAddress) >= msg.value * TokenRatio);

        CurrentRecvEther[msg.sender] += msg.value;

        require(CurrentRecvEther[msg.sender] < 20000000000000000000);
        require(msg.value != 0);
        require(GetAllowedAmount() > SendedEther);

        RecvedEther += msg.value;
        SendedEther += msg.value * TokenRatio;

        TokenTransferFrom(TokenWalletAddress, recver, msg.value * TokenRatio);
    }

    //for admin

    // move contract holds ether to admin wallet
    function TokenToEther() public payable {
        require(IsOwner() == true);
        msg.sender.transfer(RecvedEther);
    }

    // change roken ratio
    function SetTokenRatio(uint256 NewTokenRatio) public {
        require(IsOwner() == true);
        TokenRatio = NewTokenRatio;
    }

    function SetAdminInformation(address WalletAddress, address ContractAddress)
        public
    {
        require(IsOwner() == true);

        TokenWalletAddress = WalletAddress;
        TokenContractAddress = ContractAddress;
        Token = IERC20(TokenContractAddress);
    }
}
