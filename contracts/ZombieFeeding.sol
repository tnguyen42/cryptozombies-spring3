// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "./ZombieFactory.sol";

interface KittyInterface {
  function getKitty(uint256 _id)
    external
    view
    returns (
      bool isGestating,
      bool isReady,
      uint256 cooldownIndex,
      uint256 nextActionAt,
      uint256 siringWithId,
      uint256 birthTime,
      uint256 matronId,
      uint256 sireId,
      uint256 generation,
      uint256 genes
    );
}

contract ZombieFeeding is ZombieFactory {
  address public ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
  KittyInterface public kittyInterface = KittyInterface(ckAddress);

  /**
   * @dev Creates a new zombie from the zombieId and the DNA of a target
   * @param _zombieId The ID of the zombie that feeds on the target.
   * @param _targetDna The ID of the target that is being fed on.
   */
  function feedAndMultiply(
    uint256 _zombieId,
    uint256 _targetDna,
    string memory _species
  ) public {
    require(
      msg.sender == zombieToOwner[_zombieId],
      "You don't own this zombie"
    );

    Zombie storage myZombie = zombies[_zombieId];
    _targetDna = _targetDna % dnaModulus;
    uint256 newDna = (myZombie.dna + _targetDna) / 2;

    // uint256 newDna = zombies[_zombieId].dna % dnaModulus;

    if (keccak256(abi.encode(_species)) == keccak256(abi.encode("kitty"))) {
      newDna = newDna - (newDna % 100) + 99;
    }

    _createZombie("No name", newDna);
  }

  /**
   * @dev A function that allows a zombie to feed on a kitty, accessing its DNA.
   * @param _zombieId The ID of the zombie that feeds on the kitty.
   * @param _kittyId The ID of the kitty that is being fed on.
   */
  function feedOnKitty(uint256 _zombieId, uint256 _kittyId) public {
    uint256 kittyDna;

    (, , , , , , , , , kittyDna) = kittyInterface.getKitty(_kittyId);

    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }
}
