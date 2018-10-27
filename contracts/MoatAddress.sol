// addresses name - address, asset, resolver, moatkyber, moatmaker, admin

pragma solidity ^0.4.24;


contract AddressRegistry {

    event AddressChanged(string name, address addr);
    event ResolverApproved(address user, address addr);
    event ResolverDisapproved(address user, address addr);

    // Addresses managing the protocol governance
    mapping(address => bool) governors;

    // Address registry of connected smart contracts
    mapping(bytes32 => address) registry;

    // Contract addresses having rights to perform tasks, approved by users
    // Resolver Contract >> User >> Approved
    mapping(address => mapping(address => bool)) resolvers;

}


contract Governance is AddressRegistry {

    function dummyfunction() public pure returns(bool) {
        return true;
    }

    // governance code goes here to update the admin in "registry" mapping

}


contract ManageRegistry is Governance {

    function setAddr(string name, address newAddr) public onlyAdmin {
        registry[keccak256(name)] = newAddr;
        emit AddressChanged(name, newAddr);
    }

    function getAddr(string name) public view returns(address addr) {
        addr = registry[keccak256(name)];
        require(addr != address(0), "Not a valid address.");
    }

    modifier onlyAdmin() {
        require(
            msg.sender == getAddr("admin"),
            "Permission Denied"
        );
        _;
    }

}


contract ManageResolvers is ManageRegistry {

    function approveResolver() public {
        resolvers[getAddr("resolver")][msg.sender] = true;
        emit ResolverApproved(msg.sender, getAddr("resolver"));
    }

    function disapproveResolver() public {
        resolvers[getAddr("resolver")][msg.sender] = false;
        emit ResolverDisapproved(msg.sender, getAddr("resolver"));
    }

    function isApprovedResolver(address user) public view returns(bool) {
        return resolvers[getAddr("resolver")][user];
    }

}


contract InitRegistry is ManageResolvers {

    constructor() public {
        registry[keccak256("admin")] = msg.sender;
    }

}