// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

import "./EvaonWorld.sol";

enum EvaWorldMemberType {
    Hero,
    Town,
    TownSection
}

interface IEvaWorld {
    function addMember(EvaWorldMemberType _type) external;
    function getMember(EvaWorldMemberType _type) view external returns(address);
}

contract EvaWorld is Owner {
    mapping(EvaWorldMemberType => address) private _members;
    
    function getMember(EvaWorldMemberType _type) view public returns(address) {
        return _members[_type];
    }
    
    function link(EvaWorldMemberType _type, address _memberAddr) public {
        require(Owner(_memberAddr).owner() == owner, "Owner not the same");
        _members[_type] = _memberAddr;
        EvaWorldMember(_memberAddr).joinWorld(address(this));
    }
}

contract EvaWorldMember is Owner {
    address internal _worldAddress;
    function joinWorld(address __worldAddress) public {
        require(_worldAddress == address(0), "already join a world");
        _worldAddress = __worldAddress;
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
    constructor(address _worldAddr) 
        ERC721(string("Evaon World Hero"), string("HERO"))  { }
    
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

contract EvaTown is Context, EvaWorldMember, ERC721 {
    using MiscTool for uint;
    uint private tokenIdPointer = 0;
    constructor(address _worldAddr) ERC721(string("Evaon World Town"), string("TOWN")) {  }
    
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
        
        IEvaTownSection(IEvaWorld(_worldAddress).getMember(EvaWorldMemberType.TownSection)).Mint(string("Default"));
    }
}

struct EvaTownStruct {
    string name;
    uint fromTown;
}

interface IEvaTownSection {
    function Mint(string memory _name) external;
}

contract EvaTownSection is Context, EvaWorldMember, ERC721, IEvaTownSection {
    using MiscTool for uint;
    uint private tokenIdPointer = 0;
    constructor(address _worldAddr) ERC721(string("Evaon World Town Section"), string("SECTION")) { }
    
    mapping(uint => EvaTownSectionStruct) private _tokenMetas;
    mapping(uint => uint) private _tokenRandom;
    
    function Mint(string memory _name) public override {
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