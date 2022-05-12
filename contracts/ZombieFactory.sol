// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/access/Ownable.sol";

contract ZombieFactory is Ownable {
  event NewZombie(uint256 zombieId, string name, uint256 dna);

  uint256 public dnaDigits = 16;
  uint256 public dnaModulus = 10**dnaDigits;
  uint256 public cooldownTime = 1 days;

  struct Zombie {
    string name;
    uint256 dna;
    uint32 level;
    uint32 readyTime;
  }

  Zombie[] public zombies;

  mapping(uint256 => address) public zombieToOwner;
  mapping(address => uint256) public ownerToZombieCount;

  /**
   * @dev Creates a new zombie with the given name and DNA.
   * @param _name The name of the zombie.
   * @param _dna The DNA of the zombie.
   */
  function _createZombie(string memory _name, uint256 _dna) internal {
    zombies.push(
      Zombie(_name, _dna, 1, uint32(block.timestamp + cooldownTime))
    );
    zombieToOwner[zombies.length - 1] = msg.sender;
    ownerToZombieCount[msg.sender]++;

    emit NewZombie(zombies.length - 1, _name, _dna);
  }

  function getZombies() public view returns (Zombie[] memory) {
    return zombies;
  }

  /**
   * @dev Generates a semi-random DNA from a given string.
   * @param _str The string to generate a DNA from.
   */
  function _generateRandomDna(string memory _str)
    private
    view
    returns (uint256)
  {
    uint256 rand = uint256(keccak256(abi.encode(_str)));

    return rand % dnaModulus;
  }

  /**
   * @dev Creates a new zombie with the given name.
   * @param _name The name of the zombie.
   */
  function createRandomZombie(string memory _name) public {
    require(ownerToZombieCount[msg.sender] == 0, "You already have a zombie");

    uint256 randDna = _generateRandomDna(_name);
    _createZombie(_name, randDna);
  }
}
