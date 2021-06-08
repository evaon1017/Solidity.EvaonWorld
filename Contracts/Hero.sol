// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./EvaonWorld.sol";

enum EvaWorldMemberType {
    Hero,
    Town,
    TownSection
}

contract EvaWorld is Owner {
    mapping(EvaWorldMemberType => address) public members;
    
    function addMember(EvaWorldMemberType _type, address _addr) public {
        require(Owner(_addr).owner() == owner, "owner not the same");
        members[_type] = _addr;
    }
}

contract EvaWorldMember is Owner {
    address private _worldAddress;
    EvaWorldMemberType private _memberType;
    bool private _isLinked = false;
    constructor(EvaWorldMemberType __memberType, address __worldAddress) {
        _worldAddress = __worldAddress;
        _memberType = __memberType;
    }
    
    function linkWorld() public {
        require(_isLinked == false, "already linked");
        
        EvaWorld(_worldAddress).addMember(_memberType, address(this));
        _isLinked = true;
    }
}

library MiscTool {
    function random(uint seed) internal view returns (uint) {
        uint _seed = seed == 0 ? block.number : seed;
        uint blockNumber = block.number;
        
        uint mysticNumber = uint(blockhash(blockNumber)) + uint(blockhash(blockNumber - 1));
        return uint(keccak256(abi.encodePacked(_seed, block.difficulty, mysticNumber)));
    }
}

contract EvaHero is Context, EvaWorldMember, ERC721 {
    using MiscTool for uint;
    uint private tokenIdPointer = 0;
    constructor(string memory name, string memory symbol, address _worldAddr) ERC721(name, symbol) EvaWorldMember(EvaWorldMemberType.Hero, _worldAddr) { }
    
    mapping(uint => EvaHeroStruct) private _tokenMetas;
    mapping(uint => uint) private _tokenRandom;
    
    function Mint(string memory _name) public {
        uint _tokenId = ++tokenIdPointer;
        _tokenMetas[_tokenId] = EvaHeroStruct({
            name: _name
        });
        _tokenRandom[_tokenId] = uint(0).random();
        _mint(_msgSender(), _tokenId);
    }
    
    function _baseURI() internal pure override returns(string memory) {
        return "http://www.google.com.tw/";
    }
    
    function getTokenMeta(uint _tokenId) public view returns(EvaHeroStruct memory) {
        return _tokenMetas[_tokenId];
    }
}

struct EvaHeroStruct {
    string name;
}

contract EvaTown is Context, ERC721 {
    using MiscTool for uint;
    uint private tokenIdPointer = 0;
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {
        
    }
    
    mapping(uint => EvaTownStruct) private _tokenMetas;
    mapping(uint => uint) private _tokenRandom;
    mapping(uint => uint[]) private _tokenDistrictions;
    mapping(uint => uint[]) public neighborhoodTowns;
    
    function Mint(string memory _name, uint _fromTown) public {
        uint _tokenId = ++tokenIdPointer;
        _tokenMetas[_tokenId] = EvaTownStruct({
            name: _name,
            fromTown: _fromTown
        });
        _tokenRandom[_tokenId] = uint(0).random();
        if (_fromTown != 0) {
            neighborhoodTowns[_tokenId].push(_fromTown);
            neighborhoodTowns[_fromTown].push(_tokenId);
        }
        
        _mint(_msgSender(), _tokenId);
    }
}

struct EvaTownStruct {
    string name;
    uint fromTown;
}

contract EvaTownSection is Context, ERC721 {
    using MiscTool for uint;
    uint private tokenIdPointer = 0;
    constructor(string memory name, string memory symbol) ERC721(name, symbol) { }
    
    mapping(uint => EvaTownSectionStruct) private _tokenMetas;
    mapping(uint => uint) private _tokenRandom;
    
    function Mint(string memory _name) public {
        uint _tokenId = ++tokenIdPointer;
        _tokenMetas[_tokenId] = EvaTownSectionStruct({
            name: _name
        });
        _tokenRandom[_tokenId] = uint(0).random();
        _mint(_msgSender(), _tokenId);
    }
    
    function MintForSender(string memory _name) public {
        uint _tokenId = ++tokenIdPointer;
        _tokenMetas[_tokenId] = EvaTownSectionStruct({
            name: _name
        });
        _tokenRandom[_tokenId] = uint(0).random();
        _mint(_msgSender(), _tokenId);
    }
}

struct EvaTownSectionStruct {
    string name;
}